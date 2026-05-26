#!/usr/bin/env python3
"""
Extract 5 new web-fuzzer hot-patch templates and inject them into:
  - yakit HTTPFuzzerPage.ts (HotPatchTempDefault array)
  - yakit zh/webFuzzer.json (HTTPFuzzerHotPatch section)
  - yakit en/webFuzzer.json

Idempotent: skips items whose i18n key already exists.
"""
import json
import re
from pathlib import Path

REPO_ROOT = Path("/Users/v1ll4n/Projects/yaklang-ai-training-materials")
TEMPLATES_DIR = REPO_ROOT / "library-usage/web-fuzzer-hot-patch-templates"
YAKIT_ROOT = Path("/Users/v1ll4n/Projects/yakit")
TS_PATH = (
    YAKIT_ROOT
    / "app/renderer/src/main/src/defaultConstants/HTTPFuzzerPage.ts"
)
ZH_I18N = (
    YAKIT_ROOT / "app/renderer/src/main/public/locales/zh/webFuzzer.json"
)
EN_I18N = (
    YAKIT_ROOT / "app/renderer/src/main/public/locales/en/webFuzzer.json"
)

# (filename, zh_name, key, en_name)
NEW_TEMPLATES = [
    (
        "20-challenge-response-sign.yak",
        "[挑战] 动态 Challenge + HMAC 签名注入",
        "challenge_response_sign",
        "[Challenge] Dynamic Challenge + HMAC Sign Injection",
    ),
    (
        "21-bootstrap-session-pipeline.yak",
        "[会话] Bootstrap 动态会话 + 多 Header 签名 + 响应解密",
        "bootstrap_session_pipeline",
        "[Session] Bootstrap Dynamic Session + Multi-Header Sign + Response Decrypt",
    ),
    (
        "22-aes-cbc-key-iv-envelope.yak",
        "[AES] 自带 key/iv 信封协议双向加解密",
        "aes_cbc_key_iv_envelope",
        "[AES] Random key/iv Envelope Bidirectional Encrypt/Decrypt",
    ),
    (
        "23-mitm-hijack-save-decrypt.yak",
        "[MITM] hijackSaveHTTPFlow 数据库存储明文",
        "mitm_hijack_save_decrypt",
        "[MITM] hijackSaveHTTPFlow Store Plaintext in DB",
    ),
    (
        "24-mock-http-offline-response.yak",
        "[Mock] mockHTTPRequest 离线响应模拟",
        "mock_http_offline_response",
        "[Mock] mockHTTPRequest Offline Response Simulation",
    ),
]


def extract_body(yak_path: Path) -> str:
    """Extract code between HOT PATCH TEMPLATE START/END markers."""
    text = yak_path.read_text(encoding="utf-8")
    m = re.search(
        r"// ===== HOT PATCH TEMPLATE START =====\n(.*?)\n// ===== HOT PATCH TEMPLATE END =====",
        text,
        re.DOTALL,
    )
    if not m:
        raise ValueError(f"missing markers in {yak_path}")
    return m.group(1).rstrip()


def escape_ts_template(code: str) -> str:
    """Escape backticks and ${ for use inside JS/TS template literal."""
    # NB: backslash first to avoid double-escaping subsequently introduced backslashes
    code = code.replace("\\", "\\\\")
    code = code.replace("`", "\\`")
    code = code.replace("${", "\\${")
    return code


def patch_ts(ts_path: Path):
    text = ts_path.read_text(encoding="utf-8")
    new_blocks = []
    for fname, zh_name, key, _en in NEW_TEMPLATES:
        i18n_key = f"HTTPFuzzerHotPatch.{key}"
        if i18n_key in text:
            print(f"[skip] {i18n_key} already in HTTPFuzzerPage.ts")
            continue
        body = extract_body(TEMPLATES_DIR / fname)
        escaped = escape_ts_template(body)
        block = (
            f"  {{\n"
            f"    name: '{zh_name}',\n"
            f"    nameUi: '{i18n_key}',\n"
            f"    temp: `{escaped}`,\n"
            f"    isDefault: true,\n"
            f"  }},\n"
        )
        new_blocks.append(block)

    if not new_blocks:
        print("[ts] nothing to inject")
        return

    insertion = "".join(new_blocks)
    # Locate the closing bracket of HotPatchTempDefault array.
    pattern = re.compile(
        r"(export const HotPatchTempDefault = \[[\s\S]*?)(\n\]\n)",
        re.MULTILINE,
    )
    match = pattern.search(text)
    if not match:
        raise RuntimeError("could not locate HotPatchTempDefault closing ]")
    new_text = (
        text[: match.end(1)]
        + insertion.rstrip("\n")
        + match.group(2)
        + text[match.end(2) :]
    )
    ts_path.write_text(new_text, encoding="utf-8")
    print(f"[ts] injected {len(new_blocks)} templates")


def patch_i18n(json_path: Path, name_field: str):
    """
    Surgically insert new keys right before "source" line in HTTPFuzzerHotPatch
    so the rest of the file's formatting (2-space indent, key order, line breaks)
    is preserved.
    """
    text = json_path.read_text(encoding="utf-8")
    # Validate JSON is parseable first.
    data = json.loads(text)
    hp = data.get("HTTPFuzzerHotPatch")
    if hp is None:
        raise RuntimeError(f"HTTPFuzzerHotPatch section missing in {json_path}")

    lines = text.splitlines(keepends=True)
    # Find the index of `"source":` line that belongs to the HTTPFuzzerHotPatch block.
    in_block = False
    source_idx = -1
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('"HTTPFuzzerHotPatch"'):
            in_block = True
            continue
        if in_block and stripped.startswith('"source"'):
            source_idx = i
            break
    if source_idx < 0:
        raise RuntimeError(
            f'cannot locate "source" key inside HTTPFuzzerHotPatch in {json_path}'
        )

    added = 0
    new_lines = []
    for fname, zh_name, key, en_name in NEW_TEMPLATES:
        if key in hp:
            print(f"[skip] {key} already in {json_path.name}")
            continue
        value = zh_name if name_field == "zh" else en_name
        value_json = json.dumps(value, ensure_ascii=False)
        new_lines.append(f'    "{key}": {value_json},\n')
        added += 1
    if not added:
        print(f"[i18n] {json_path.name} nothing to inject")
        return

    out = lines[:source_idx] + new_lines + lines[source_idx:]
    json_path.write_text("".join(out), encoding="utf-8")
    # Validate again that the rendered file is still valid JSON.
    json.loads(json_path.read_text(encoding="utf-8"))
    print(f"[i18n] {json_path.name} injected {added} keys")


def main():
    patch_ts(TS_PATH)
    patch_i18n(ZH_I18N, "zh")
    patch_i18n(EN_I18N, "en")


if __name__ == "__main__":
    main()
