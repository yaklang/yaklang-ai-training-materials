#!/usr/bin/env python3
"""
把 G'1-G'5 全局模板注入 yakit 的 globalHotPatch.ts，新增 DEFAULT_GLOBAL_TEMPLATES 数组。

策略：
- 保留 DEFAULT_GLOBAL_TEMPLATE_NAME / DEFAULT_GLOBAL_TEMPLATE_CONTENT（向后兼容）
- 新增 DefaultGlobalTemplate interface 与 DEFAULT_GLOBAL_TEMPLATES 数组
- 数组首项就是原默认模板（zh + en i18n key），其后是 5 个新模板
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GLOBAL_DIR = ROOT / "library-usage/global-hot-patch-templates"
YAKIT_GLOBAL_TS = Path(
    "/Users/v1ll4n/Projects/yakit/app/renderer/src/main/src/store/globalHotPatch.ts"
)

# (filename, nameUi i18n key, display zh name)
GLOBAL_TEMPLATES = [
    ("g01-global-sm4-transparent.yak", "GlobalHotPatch.guomi_sm4_transparent", "[全局] 内网 SM4-CBC 透明加解密 + 入库明文"),
    ("g02-global-challenge-sign-pipeline.yak", "GlobalHotPatch.challenge_sign_pipeline", "[全局] 动态 Challenge + HMAC 签名注入 pipeline"),
    ("g03-global-auto-bearer-token.yak", "GlobalHotPatch.auto_bearer_token", "[全局] 默认 Authorization Bearer 自动注入"),
    ("g04-global-flow-tag-coloring.yak", "GlobalHotPatch.flow_tag_coloring", "[全局] 流量染色 + tag（敏感关键字/状态码）"),
    ("g05-global-danger-mock-protect.yak", "GlobalHotPatch.danger_mock_protect", "[全局] 危险操作 Mock 保护（DELETE/PUT 自动 mock）"),
]

DEFAULT_NAME_UI = "GlobalHotPatch.default"

INTERFACE_DECL = """export interface DefaultGlobalTemplate {
  name: string
  nameUi: string
  content: string
}

"""


def escape_ts_template(s: str) -> str:
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
    if "'" in s:
        raise RuntimeError(f"name must not contain single quote: {s!r}")
    return "'" + s + "'"


def build_array() -> str:
    lines = ["export const DEFAULT_GLOBAL_TEMPLATES: DefaultGlobalTemplate[] = [\n"]
    lines.append(
        "  {\n"
        "    name: DEFAULT_GLOBAL_TEMPLATE_NAME,\n"
        f"    nameUi: {ts_single_quote(DEFAULT_NAME_UI)},\n"
        "    content: DEFAULT_GLOBAL_TEMPLATE_CONTENT,\n"
        "  },\n"
    )
    for fname, name_ui, display in GLOBAL_TEMPLATES:
        code = (GLOBAL_DIR / fname).read_text(encoding="utf-8")
        lines.append(
            "  {\n"
            f"    name: {ts_single_quote(display)},\n"
            f"    nameUi: {ts_single_quote(name_ui)},\n"
            f"    content: `{escape_ts_template(code)}`,\n"
            "  },\n"
        )
    lines.append("]\n\n")
    return "".join(lines)


def main():
    text = YAKIT_GLOBAL_TS.read_text(encoding="utf-8")

    if "DEFAULT_GLOBAL_TEMPLATES" in text:
        print("DEFAULT_GLOBAL_TEMPLATES already exists; skip injection")
        return

    # Insert interface + array immediately after the DEFAULT_GLOBAL_TEMPLATE_CONTENT closing backtick.
    # We anchor on the line that ends with `}\`` (the closing backtick of DEFAULT_GLOBAL_TEMPLATE_CONTENT).
    m = re.search(
        r"(export\s+const\s+DEFAULT_GLOBAL_TEMPLATE_CONTENT\s*=\s*`)",
        text,
    )
    if not m:
        raise RuntimeError("cannot locate DEFAULT_GLOBAL_TEMPLATE_CONTENT")
    # Find the closing backtick for that template literal.
    i = m.end()
    while i < len(text):
        c = text[i]
        if c == "\\" and i + 1 < len(text):
            i += 2
            continue
        if c == "`":
            break
        i += 1
    else:
        raise RuntimeError("cannot find closing backtick of DEFAULT_GLOBAL_TEMPLATE_CONTENT")
    insert_idx = i + 1
    while insert_idx < len(text) and text[insert_idx] in (" ", "\t"):
        insert_idx += 1
    if insert_idx < len(text) and text[insert_idx] == "\n":
        insert_idx += 1

    block = "\n" + INTERFACE_DECL + build_array()
    new_text = text[:insert_idx] + block + text[insert_idx:]
    YAKIT_GLOBAL_TS.write_text(new_text, encoding="utf-8")
    print(f"injected DEFAULT_GLOBAL_TEMPLATES (1 default + {len(GLOBAL_TEMPLATES)} new)")


if __name__ == "__main__":
    main()
