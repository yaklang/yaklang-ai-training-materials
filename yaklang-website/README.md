# Yaklang Website Snapshot

本目录是 [yaklang.github.io](https://github.com/yaklang/yaklang.github.io) (yaklang.com)
官网内容的自动同步快照, 用作 Yaklang AI 训练材料。

快照来自 yaklang.github.io 的 `static/site-packages.json` 中最新一期 zip 包,
包含 docs / products / blog 三部分源文件 (不含 Yaklab)。

## 本期元信息

- Snapshot ID: `2026-06-21-1`
- 站点生成时间 (zip 内 generatedAt): `2026-06-21T03:07:10.764Z`
- 同步到本仓时间: `2026-06-21T03:25:40.076Z`
- 条目数: `523`
- 来源 zip URL: <https://aliyun-oss.yaklang.com/yak/docs/2026-06-21/yaklang-com-docs-2026-06-21-1.zip>
- 来源记账文件: yaklang.github.io `static/site-packages.json`

## 目录结构

```
yaklang-website/
  README.md            # 本文件
  LAST_SYNC.txt        # 上次同步 id<TAB>date<TAB>url<TAB>count
  .snapshot-id         # 一行 id (脚本内部记账, 用于版本探测)
  INDEX.json           # 从 zip 原样拷贝 (权威索引, 含 url/path 映射)
  INDEX.ndjson         # 从 zip 原样拷贝
  MANIFEST.txt         # 从 zip 原样拷贝
  docs/                # 官网 docs 源
  products/            # 官网 products 源 (Yakit 手册)
  blog/                # 官网 blog 源
```

## 如何从文件名恢复 URL

最权威的方式是直接查 `INDEX.json` / `INDEX.ndjson` 的 `url` 字段。

也可按 Docusaurus 路由规则手算:

- `docs/<relPath>` -> `https://yaklang.com/docs/<relPath 去扩展名>`, 末尾 `/index` 去掉。
- `products/<relPath>` -> `https://yaklang.com/products/<relPath 去扩展名>`, 末尾 `/index` 去掉。
- `blog/<file>` -> `https://yaklang.com/blog/<file 去扩展名 去掉 YYYY-MM-DD- 前缀>`。
- 若 entry 含 `slug` 字段, 则以其覆盖。

## 同步机制

由 `.github/workflows/sync-website-snapshot.yml` 每天定时轮询 site-packages.json,
id 变化时下载新包并重建本目录。脚本: `scripts/sync-website-snapshot.js`。
