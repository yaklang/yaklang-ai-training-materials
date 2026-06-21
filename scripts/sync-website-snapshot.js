#!/usr/bin/env node
/*
Sync Website Snapshot
=====================
将 yaklang.github.io (yaklang.com) 的官网内容快照同步到本仓 yaklang-website/ 目录。

数据源: yaklang.github.io 仓的 static/site-packages.json (公开),
        其中第一个元素是最新一期 zip 包 (docs + products + blog, 不含 Yaklab)。

zip 包结构:
  INDEX.json / INDEX.ndjson / MANIFEST.txt (顶层元文件)
  docs/...  products/...  blog/...

输出结构 (yaklang-website/):
  README.md            自动生成: 说明来源 id/日期/条目数/zip URL
  LAST_SYNC.txt        上次同步的 id<TAB>date<TAB>url<TAB>count
  .snapshot-id         仅一行 id (脚本内部记账)
  INDEX.json           从 zip 原样拷贝
  INDEX.ndjson         从 zip 原样拷贝
  MANIFEST.txt         从 zip 原样拷贝
  docs/ products/ blog/  官网源 (原样)

零第三方依赖, 仅用 Node 内置模块。
参考: scripts/diff-zip.yak 等同仓脚本的风格。
关键词: website snapshot, site-packages.json, yaklang.github.io, training materials
*/

// 关键词: node sync script, website snapshot
"use strict";

const fs = require("fs");
const fsp = require("fs").promises;
const path = require("path");
const https = require("https");
const http = require("http");
const { execFileSync } = require("child_process");
const os = require("os");

// ---------- 路径常量 ----------
// DEST_DIR / 记账文件的具体路径在 main() 里根据 --dest 计算 (使脚本可指向任意目标目录)。
const REPO_ROOT = path.resolve(__dirname, "..");
const DEFAULT_DEST_DIR = path.join(REPO_ROOT, "yaklang-website");

// 默认数据源: yaklang.github.io 的 static/site-packages.json (raw 最稳)
const SITE_PACKAGES_URL =
  "https://raw.githubusercontent.com/yaklang/yaklang.github.io/master/static/site-packages.json";

// 清空目录时要保留的元文件 (相对 DEST_DIR 的 basename)
const PRESERVE_FILES = new Set([
  "LAST_SYNC.txt",
  ".snapshot-id",
  // .gitkeep 之类也保留, 防止目录意外丢失
  ".gitkeep",
]);

// ---------- argv 解析 ----------
function parseArgs(argv) {
  const opts = {
    zip: null, // 直接指定 zip URL, 覆盖自动探测
    packageJsonUrl: SITE_PACKAGES_URL,
    dest: DEFAULT_DEST_DIR,
    keepOld: false, // 仅做增量统计对比, 不实际清空 (调试用)
    help: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--zip" || a === "-z") opts.zip = argv[++i];
    else if (a === "--package-json-url") opts.packageJsonUrl = argv[++i];
    else if (a === "--dest") opts.dest = path.resolve(argv[++i]);
    else if (a === "--keep-old") opts.keepOld = true;
    else if (a === "--help" || a === "-h") opts.help = true;
  }
  return opts;
}

function usage() {
  return [
    "Usage: sync-website-snapshot.js [options]",
    "",
    "Options:",
    "  --zip <url>               Use this zip URL directly (skip site-packages.json probe).",
    "  --package-json-url <url>  Override site-packages.json URL.",
    "  --dest <dir>              Destination directory (default: yaklang-website/).",
    "  --keep-old                Keep old snapshot files for diff (debug).",
    "  --help, -h                Show this help.",
    "",
    "Environment:",
    "  SKIP_DOWNLOAD=1           Reuse previously downloaded zip in OS tmp (debug).",
  ].join("\n");
}

// ---------- HTTP 下载 (Buffer, 跟随重定向) ----------
function httpGetBuffer(url, redirectsLeft = 5) {
  return new Promise((resolve, reject) => {
    if (redirectsLeft < 0) return reject(new Error(`too many redirects: ${url}`));
    const client = url.startsWith("http://") ? http : https;
    const req = client.get(
      url,
      {
        headers: {
          // 模拟浏览器, 避免部分 CDN 拒绝
          "User-Agent": "yaklang-ai-training-materials/sync-website-snapshot",
          Accept: "*/*",
        },
      },
      (res) => {
        const status = res.statusCode || 0;
        if (status >= 300 && status < 400 && res.headers.location) {
          // 重定向
          const next = new URL(res.headers.location, url).toString();
          res.resume();
          return resolve(httpGetBuffer(next, redirectsLeft - 1));
        }
        if (status !== 200) {
          res.resume();
          return reject(new Error(`HTTP ${status} for ${url}`));
        }
        const chunks = [];
        res.on("data", (c) => chunks.push(c));
        res.on("end", () => resolve(Buffer.concat(chunks)));
        res.on("error", reject);
      },
    );
    req.on("error", reject);
    req.setTimeout(60_000, () => req.destroy(new Error(`timeout: ${url}`)));
  });
}

async function httpGetJSON(url) {
  const buf = await httpGetBuffer(url);
  try {
    return JSON.parse(buf.toString("utf8"));
  } catch (e) {
    throw new Error(`invalid JSON from ${url}: ${e.message}`);
  }
}

// ---------- 解压 ----------
function unzipTo(zipPath, destDir) {
  // 优先使用系统 unzip (CI ubuntu 自带, macOS 也有), 比 Node 实现更稳。
  fs.mkdirSync(destDir, { recursive: true });
  execFileSync("unzip", ["-o", "-q", zipPath, "-d", destDir], { stdio: "inherit" });
}

// ---------- 文件操作 ----------
async function rmrf(dir) {
  await fsp.rm(dir, { recursive: true, force: true });
}

async function clearDirKeepMeta(destDir) {
  // 清空目标目录, 但保留 PRESERVE_FILES 中列出的元文件
  if (!fs.existsSync(destDir)) {
    await fsp.mkdir(destDir, { recursive: true });
    return;
  }
  const entries = await fsp.readdir(destDir, { withFileTypes: true });
  for (const e of entries) {
    if (PRESERVE_FILES.has(e.name)) continue;
    const full = path.join(destDir, e.name);
    await fsp.rm(full, { recursive: true, force: true });
  }
}

function writeText(file, content) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content, "utf8");
}

// 读旧 snapshot id (记账)
function readSnapshotId(snapshotIdFile) {
  if (!fs.existsSync(snapshotIdFile)) return null;
  const v = fs.readFileSync(snapshotIdFile, "utf8").trim();
  return v || null;
}

// ---------- URL 恢复 (用于 README 抽查说明) ----------
// 规则与 MANIFEST.txt / zip INDEX.json 一致; entry.slug 若存在则覆盖。
function deriveUrlFromRelPath(source, relPath, slug) {
  // docs/products: /<source>/<relPath 去扩展名> 去掉 /index
  // blog: /blog/<filename 去扩展名 去掉 YYYY-MM-DD- 前缀>
  const base = "https://yaklang.com";
  if (source === "docs" || source === "products") {
    let p = relPath.replace(/\.(md|mdx)$/i, "");
    p = p.replace(/\/index$/, "");
    return `${base}/${source}/${slug || p}`;
  }
  if (source === "blog") {
    let p = path.basename(relPath).replace(/\.(md|mdx)$/i, "");
    p = p.replace(/^\d{4}-\d{2}-\d{2}-/, "");
    return `${base}/blog/${slug || p}`;
  }
  return null;
}

// ---------- 主流程 ----------
async function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (opts.help) {
    console.log(usage());
    process.exit(0);
  }

  const destDir = opts.dest;
  const lastSyncFile = path.join(destDir, "LAST_SYNC.txt");
  const snapshotIdFile = path.join(destDir, ".snapshot-id");

  // 1. 解析最新一期 id/url
  let id, date, zipUrl, expectedCount;
  if (opts.zip) {
    // 直接给定 zip URL, 从文件名推断 id
    zipUrl = opts.zip;
    const m = zipUrl.match(/yaklang-com-docs-(\d{4}-\d{2}-\d{2}(?:-\d+)?)/);
    id = m ? m[1] : "unknown-" + Date.now();
    date = new Date().toISOString();
    console.error(`[probe] zip URL provided directly, derived id=${id}`);
  } else {
    console.error(`[probe] fetching ${opts.packageJsonUrl}`);
    const packages = await httpGetJSON(opts.packageJsonUrl);
    if (!Array.isArray(packages) || packages.length === 0) {
      throw new Error("site-packages.json is empty or not an array");
    }
    const latest = packages[0];
    id = latest.id;
    date = latest.date;
    zipUrl = latest.url;
    expectedCount = latest.count;
    console.error(
      `[probe] latest id=${id} date=${date} count=${expectedCount} url=${zipUrl}`,
    );
  }

  // 2. 比较 id (不强制时若一致则跳过)
  const oldId = readSnapshotId(snapshotIdFile);
  const force = process.env.FORCE_SYNC === "1" || process.env.FORCE_SYNC === "true";
  if (oldId && oldId === id && !force) {
    console.log(`ALREADY_UP_TO_DATE id=${id}`);
    console.log(`SUMMARY id=${id} url=${zipUrl} count=0 dest=${path.relative(REPO_ROOT, destDir)}/ status=noop`);
    return;
  }

  // 3. 下载 zip 到 OS 临时目录
  const tmpRoot = path.join(os.tmpdir(), "yaklang-website-sync");
  fs.mkdirSync(tmpRoot, { recursive: true });
  const zipPath = path.join(tmpRoot, `snapshot-${id}.zip`);
  const extractDir = path.join(tmpRoot, `extract-${id}`);

  if (process.env.SKIP_DOWNLOAD === "1" && fs.existsSync(zipPath)) {
    console.error(`[download] SKIP_DOWNLOAD=1, reuse ${zipPath}`);
  } else {
    console.error(`[download] ${zipUrl}`);
    const buf = await httpGetBuffer(zipUrl);
    fs.writeFileSync(zipPath, buf);
    console.error(`[download] saved ${zipPath} (${buf.length} bytes)`);
  }

  // 4. 解压
  if (fs.existsSync(extractDir)) await rmrf(extractDir);
  console.error(`[unzip] -> ${extractDir}`);
  unzipTo(zipPath, extractDir);

  // 5. 读 INDEX.json (权威索引)
  const indexPath = path.join(extractDir, "INDEX.json");
  if (!fs.existsSync(indexPath)) {
    throw new Error(`INDEX.json not found in zip (extracted to ${extractDir})`);
  }
  const index = JSON.parse(fs.readFileSync(indexPath, "utf8"));
  const entries = Array.isArray(index.entries) ? index.entries : [];
  const count = entries.length || expectedCount || 0;
  const generatedAt = index.generatedAt || date;

  // 6. 清空目标目录, 保留元文件
  console.error(`[clear] ${destDir} (keep meta files)`);
  await clearDirKeepMeta(destDir);

  // 7. 拷贝顶层元文件 (INDEX.json/INDEX.ndjson/MANIFEST.txt)
  for (const name of ["INDEX.json", "INDEX.ndjson", "MANIFEST.txt"]) {
    const src = path.join(extractDir, name);
    if (fs.existsSync(src)) {
      fs.copyFileSync(src, path.join(destDir, name));
    }
  }

  // 8. 拷贝 docs/products/blog 子目录
  for (const src of ["docs", "products", "blog"]) {
    const srcDir = path.join(extractDir, src);
    if (!fs.existsSync(srcDir)) continue;
    const destSub = path.join(destDir, src);
    fs.mkdirSync(destSub, { recursive: true });
    copyDirRecursiveSync(srcDir, destSub);
  }

  // 9. 生成 README.md
  const archiveDate = new Date().toISOString();
  const readme = [
    "# Yaklang Website Snapshot",
    "",
    "本目录是 [yaklang.github.io](https://github.com/yaklang/yaklang.github.io) (yaklang.com)",
    "官网内容的自动同步快照, 用作 Yaklang AI 训练材料。",
    "",
    "快照来自 yaklang.github.io 的 `static/site-packages.json` 中最新一期 zip 包,",
    "包含 docs / products / blog 三部分源文件 (不含 Yaklab)。",
    "",
    "## 本期元信息",
    "",
    `- Snapshot ID: \`${id}\``,
    `- 站点生成时间 (zip 内 generatedAt): \`${generatedAt}\``,
    `- 同步到本仓时间: \`${archiveDate}\``,
    `- 条目数: \`${count}\``,
    `- 来源 zip URL: <${zipUrl}>`,
    `- 来源记账文件: yaklang.github.io \`static/site-packages.json\``,
    "",
    "## 目录结构",
    "",
    "```",
    "yaklang-website/",
    "  README.md            # 本文件",
    "  LAST_SYNC.txt        # 上次同步 id<TAB>date<TAB>url<TAB>count",
    "  .snapshot-id         # 一行 id (脚本内部记账, 用于版本探测)",
    "  INDEX.json           # 从 zip 原样拷贝 (权威索引, 含 url/path 映射)",
    "  INDEX.ndjson         # 从 zip 原样拷贝",
    "  MANIFEST.txt         # 从 zip 原样拷贝",
    "  docs/                # 官网 docs 源",
    "  products/            # 官网 products 源 (Yakit 手册)",
    "  blog/                # 官网 blog 源",
    "```",
    "",
    "## 如何从文件名恢复 URL",
    "",
    "最权威的方式是直接查 \`INDEX.json\` / \`INDEX.ndjson\` 的 \`url\` 字段。",
    "",
    "也可按 Docusaurus 路由规则手算:",
    "",
    "- `docs/<relPath>` -> `https://yaklang.com/docs/<relPath 去扩展名>`, 末尾 `/index` 去掉。",
    "- `products/<relPath>` -> `https://yaklang.com/products/<relPath 去扩展名>`, 末尾 `/index` 去掉。",
    "- `blog/<file>` -> `https://yaklang.com/blog/<file 去扩展名 去掉 YYYY-MM-DD- 前缀>`。",
    "- 若 entry 含 `slug` 字段, 则以其覆盖。",
    "",
    "## 同步机制",
    "",
    "由 \`.github/workflows/sync-website-snapshot.yml\` 每天定时轮询 site-packages.json,",
    "id 变化时下载新包并重建本目录。脚本: \`scripts/sync-website-snapshot.js\`。",
    "",
  ].join("\n");
  writeText(path.join(destDir, "README.md"), readme);

  // 10. 写 LAST_SYNC.txt 和 .snapshot-id
  writeText(lastSyncFile, `${id}\t${date}\t${zipUrl}\t${count}\n`);
  writeText(snapshotIdFile, `${id}\n`);

  // 11. 抽查 3 条 entry 的 url 恢复 (用 slug 优先, 与 INDEX.json 一致)
  const samples = entries.slice(0, 3).map((e) => {
    const derived = deriveUrlFromRelPath(e.source, e.relPath, e.slug);
    return {
      source: e.source,
      relPath: e.relPath,
      expected: e.url,
      derived,
      match: derived === e.url,
    };
  });
  console.error("[verify] 3 sample URL recoveries:");
  for (const s of samples) {
    console.error(
      `  ${s.match ? "OK " : "DIFF"} ${s.source}/${s.relPath} -> ${s.derived}` +
        (s.match ? "" : ` (expected ${s.expected})`),
    );
  }

  // 12. 末尾打印结构化摘要 (供 CI 解析)
  console.log(
    `SUMMARY id=${id} url=${zipUrl} count=${count} dest=${path.relative(REPO_ROOT, destDir)}/ status=synced`,
  );
}

function copyDirRecursiveSync(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const e of entries) {
    const s = path.join(src, e.name);
    const d = path.join(dest, e.name);
    if (e.isDirectory()) copyDirRecursiveSync(s, d);
    else if (e.isFile()) fs.copyFileSync(s, d);
    else if (e.isSymbolicLink()) {
      // 解引用符号链接 (避免 CI 跨设备问题)
      const real = fs.realpathSync(s);
      if (fs.statSync(real).isDirectory()) copyDirRecursiveSync(real, d);
      else fs.copyFileSync(real, d);
    }
  }
}

main().catch((err) => {
  console.error("FATAL:", err && err.stack ? err.stack : err);
  process.exit(1);
});
