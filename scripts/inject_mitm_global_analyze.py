#!/usr/bin/env python3
"""
把 MITM(M1-M13) / 分析(A1-A4) / 全局(G'1-G'5) 模板注入 yakit 默认数组。

操作分三步:
  1. 注入 M1-M13 到 mitm.ts 的 MITMHotPatchTempDefault 数组末尾
  2. 注入 A1-A4 到 mitm.ts 的 AnalyzeHotPatchTempDefault 数组末尾
  3. 全局模板: 把内容存到磁盘 const map，等手工/单独脚本接入 globalHotPatch.ts

只追加，不修改既有 entry; 已存在的 name 跳过。
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MITM_DIR = ROOT / "library-usage/mitm-hot-patch-templates"
ANALYZE_DIR = ROOT / "library-usage/httpflow-analyze-hot-patch-templates"
GLOBAL_DIR = ROOT / "library-usage/global-hot-patch-templates"
YAKIT_MITM_TS = Path(
    "/Users/v1ll4n/Projects/yakit/app/renderer/src/main/src/defaultConstants/mitm.ts"
)

# (filename, display_name)
MITM_TEMPLATES = [
    ("m01-hijack-modify-json-field.yak", "[请求] hijackHTTPRequest 改 JSON 字段（金额/折扣演示）"),
    ("m02-hijack-inject-token-header.yak", "[请求] hijackHTTPRequest 注入 X-Auth-Token / Cookie"),
    ("m03-hijack-drop-blacklist.yak", "[请求] hijackHTTPRequest 黑名单 drop 静态资源/敏感 host"),
    ("m04-hijack-response-strip-js.yak", "[响应] hijackHTTPResponseEx 删除阻断 JS (alert / location.href)"),
    ("m05-hijack-response-rewrite-security-headers.yak", "[响应] hijackHTTPResponseEx 宽松 CORS / 删 CSP / 去 HttpOnly"),
    ("m06-mirror-color-by-status.yak", "[镜像] mirrorHTTPFlow 按状态码统计 + 5xx 告警"),
    ("m07-mirror-filtered-extract-secrets.yak", "[镜像] mirrorFilteredHTTPFlow 流式提取手机号/邮箱/JWT"),
    ("m08-mirror-new-website-fingerprint.yak", "[镜像] mirrorNewWebsite 新域名自动指纹识别"),
    ("m09-mirror-new-path-nuclei.yak", "[镜像] mirrorNewWebsitePath 新路径自动 nuclei 扫描"),
    ("m10-save-tag-sensitive-keywords.yak", "[入库] hijackSaveHTTPFlow 敏感关键字染色 + tag"),
    ("m11-save-pii-redaction.yak", "[入库] hijackSaveHTTPFlow PII 脱敏入库"),
    ("m12-mock-danger-protect.yak", "[Mock] mockHTTPRequest 危险操作保护 (DELETE/PUT 强制 mock)"),
    ("m13-mock-vuln-virtual-range.yak", "[Mock] mockHTTPRequest 虚拟靶场 (SQLi/RCE/SSRF)"),
]

ANALYZE_TEMPLATES = [
    ("a01-extract-phones-tokens.yak", "[分析] 敏感数据全量提取（手机号/JWT/Authorization）+ JSON 报告"),
    ("a02-host-stats.yak", "[分析] 主机访问次数统计"),
    ("a03-classify-by-path.yak", "[分析] 自动分类（登录/上传/后台）+ tag + 染色"),
    ("a04-abnormal-status-report.yak", "[分析] 异常状态码报告（4xx/5xx 饼图 + 表格）"),
]


def escape_ts_template(s: str) -> str:
    """Escape for TS template literal: ` -> \\`, ${ -> \\${, \\ -> \\\\."""
    out = []
    i = 0
    while i < len(s):
        c = s[i]
        if c == "\\":
            out.append("\\\\")
        elif c == "`":
            out.append("\\`")
        elif c == "$" and i + 1 < len(s) and s[i + 1] == "{":
            out.append("\\${")
            i += 1
        else:
            out.append(c)
        i += 1
    return "".join(out)


def ts_single_quote(s: str) -> str:
    """Single-quoted TS string. Caller ensures s contains no single quote."""
    if "'" in s:
        raise RuntimeError(f"name must not contain single quote: {s!r}")
    return "'" + s + "'"


def build_entry(name: str, code: str) -> str:
    return (
        f"  {{\n"
        f"    name: {ts_single_quote(name)},\n"
        f"    temp: `{escape_ts_template(code)}`,\n"
        f"    isDefault: true,\n"
        f"  }},\n"
    )


def find_array_end(text: str, array_name: str) -> int:
    """Return the index of the closing `]` of `export const ARRAY = [ ... ]`."""
    decl_re = re.compile(rf"export\s+const\s+{re.escape(array_name)}\s*=\s*\[")
    m = decl_re.search(text)
    if not m:
        raise RuntimeError(f"cannot find declaration of {array_name}")
    depth = 1
    i = m.end()
    in_string: str | None = None
    while i < len(text):
        c = text[i]
        if in_string:
            if c == "\\" and i + 1 < len(text):
                i += 2
                continue
            if c == in_string:
                in_string = None
            i += 1
            continue
        if c in ("`", "'", '"'):
            in_string = c
            i += 1
            continue
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise RuntimeError(f"closing ] of {array_name} not found")


def already_present(text: str, name: str, array_name: str) -> bool:
    """Quick check whether `name: 'X'` or `name: "X"` already exists in the file."""
    return ("name: '" + name + "'") in text or ('name: "' + name + '"') in text


def inject(text: str, array_name: str, items: list[tuple[str, str, str]]) -> tuple[str, int]:
    """items: list of (filename, display_name, dir_path)."""
    insert_idx = find_array_end(text, array_name)
    new_blocks: list[str] = []
    added = 0
    for fname, display_name, dir_path in items:
        if already_present(text, display_name, array_name):
            print(f"  [skip] {array_name}: '{display_name}' already present")
            continue
        code = (Path(dir_path) / fname).read_text(encoding="utf-8")
        new_blocks.append(build_entry(display_name, code))
        added += 1
    if not new_blocks:
        return text, 0
    insertion = "".join(new_blocks)
    new_text = text[:insert_idx] + insertion + text[insert_idx:]
    return new_text, added


def main():
    text = YAKIT_MITM_TS.read_text(encoding="utf-8")
    original = text

    text, added_mitm = inject(
        text,
        "MITMHotPatchTempDefault",
        [(f, n, MITM_DIR) for (f, n) in MITM_TEMPLATES],
    )
    print(f"injected {added_mitm} MITM templates")

    text, added_analyze = inject(
        text,
        "AnalyzeHotPatchTempDefault",
        [(f, n, ANALYZE_DIR) for (f, n) in ANALYZE_TEMPLATES],
    )
    print(f"injected {added_analyze} analyze templates")

    if text != original:
        YAKIT_MITM_TS.write_text(text, encoding="utf-8")
        print(f"written {YAKIT_MITM_TS}")
    else:
        print("no changes (all entries already present)")


if __name__ == "__main__":
    main()
