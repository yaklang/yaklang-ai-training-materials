#!/usr/bin/env python3
"""
Round-trip verification: extract M1-M13 / A1-A4 / G'1-G'5 templates from yakit
files (mitm.ts / globalHotPatch.ts), then run each extracted .yak via the yak engine
and assert the expected "self test passed" log appears.

Templates may keep goroutines (httpserver / file handles) alive past the self-test
log, so we tolerate timeout as long as the expected log line was emitted in stdout
or stderr.
"""
from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path

YAKIT_MITM_TS = Path(
    "/Users/v1ll4n/Projects/yakit/app/renderer/src/main/src/defaultConstants/mitm.ts"
)
YAKIT_GLOBAL_TS = Path(
    "/Users/v1ll4n/Projects/yakit/app/renderer/src/main/src/store/globalHotPatch.ts"
)

# (yakit display name, expected log line)
MITM_KEYS: list[tuple[str, str]] = [
    ("[请求] hijackHTTPRequest 改 JSON 字段（金额/折扣演示）", "hijack modify json field self test passed"),
    ("[请求] hijackHTTPRequest 注入 X-Auth-Token / Cookie", "hijack inject token header self test passed"),
    ("[请求] hijackHTTPRequest 黑名单 drop 静态资源/敏感 host", "hijack drop blacklist self test passed"),
    ("[响应] hijackHTTPResponseEx 删除阻断 JS (alert / location.href)", "hijack response strip js self test passed"),
    ("[响应] hijackHTTPResponseEx 宽松 CORS / 删 CSP / 去 HttpOnly", "hijack response rewrite security headers self test passed"),
    ("[镜像] mirrorHTTPFlow 按状态码统计 + 5xx 告警", "mirror color by status self test passed"),
    ("[镜像] mirrorFilteredHTTPFlow 流式提取手机号/邮箱/JWT", "mirror filtered extract secrets self test passed"),
    ("[镜像] mirrorNewWebsite 新域名自动指纹识别", "mirror new website fingerprint self test passed"),
    ("[镜像] mirrorNewWebsitePath 新路径自动 nuclei 扫描", "mirror new path nuclei self test passed"),
    ("[入库] hijackSaveHTTPFlow 敏感关键字染色 + tag", "save tag sensitive keywords self test passed"),
    ("[入库] hijackSaveHTTPFlow PII 脱敏入库", "save pii redaction self test passed"),
    ("[Mock] mockHTTPRequest 危险操作保护 (DELETE/PUT 强制 mock)", "mock danger protect self test passed"),
    ("[Mock] mockHTTPRequest 虚拟靶场 (SQLi/RCE/SSRF)", "mock vuln virtual range self test passed"),
]

ANALYZE_KEYS: list[tuple[str, str]] = [
    ("[分析] 敏感数据全量提取（手机号/JWT/Authorization）+ JSON 报告", "extract phones tokens self test passed"),
    ("[分析] 主机访问次数统计", "host stats self test passed"),
    ("[分析] 自动分类（登录/上传/后台）+ tag + 染色", "classify by path self test passed"),
    ("[分析] 异常状态码报告（4xx/5xx 饼图 + 表格）", "abnormal status report self test passed"),
]

GLOBAL_KEYS: list[tuple[str, str]] = [
    ("[全局] 内网 SM4-CBC 透明加解密 + 入库明文", "global sm4 transparent self test passed"),
    ("[全局] 动态 Challenge + HMAC 签名注入 pipeline", "global challenge sign pipeline self test passed"),
    ("[全局] 默认 Authorization Bearer 自动注入", "global auto bearer token self test passed"),
    ("[全局] 流量染色 + tag（敏感关键字/状态码）", "global flow tag coloring self test passed"),
    ("[全局] 危险操作 Mock 保护（DELETE/PUT 自动 mock）", "global danger mock protect self test passed"),
]


def unescape_ts_template(s: str) -> str:
    out = []
    i = 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            nxt = s[i + 1]
            if nxt == "`":
                out.append("`")
                i += 2
                continue
            if nxt == "$":
                if i + 2 < len(s) and s[i + 2] == "{":
                    out.append("${")
                    i += 3
                    continue
                out.append("$")
                i += 2
                continue
            if nxt == "\\":
                out.append("\\")
                i += 2
                continue
        out.append(c)
        i += 1
    return "".join(out)


def extract_template(ts_text: str, name: str, field: str) -> str:
    """Find `name: 'NAME'` then locate the following `<field>: `` (backtick template literal)."""
    needle = "name: '" + name + "'"
    idx = ts_text.find(needle)
    if idx < 0:
        raise RuntimeError(f"display name not found: {name}")
    field_marker = field + ": `"
    open_idx = ts_text.find(field_marker, idx)
    if open_idx < 0:
        raise RuntimeError(f"field {field} not found after name {name}")
    start = open_idx + len(field_marker)
    i = start
    while i < len(ts_text):
        c = ts_text[i]
        if c == "\\":
            i += 2
            continue
        if c == "`":
            return unescape_ts_template(ts_text[start:i])
        i += 1
    raise RuntimeError(f"closing backtick not found for {name}")


def run_yak_and_check(code: str, expected: str, label: str) -> bool:
    with tempfile.NamedTemporaryFile(
        "w", suffix=".yak", delete=False, encoding="utf-8"
    ) as f:
        f.write(code)
        tmp_path = f.name
    stdout = ""
    stderr = ""
    try:
        try:
            result = subprocess.run(
                ["yak", tmp_path],
                capture_output=True,
                text=True,
                timeout=10,
            )
            stdout = result.stdout
            stderr = result.stderr
        except subprocess.TimeoutExpired as te:
            stdout = (te.stdout or "") if isinstance(te.stdout, str) else (te.stdout or b"").decode("utf-8", errors="ignore")
            stderr = (te.stderr or "") if isinstance(te.stderr, str) else (te.stderr or b"").decode("utf-8", errors="ignore")
    finally:
        Path(tmp_path).unlink(missing_ok=True)
    if expected in stdout + stderr:
        print(f"PASS {label}: round-trip yakit -> yak -> '{expected}'")
        return True
    print(
        f"FAIL {label}: expected '{expected}' missing\nstdout(tail):\n{stdout[-600:]}\nstderr(tail):\n{stderr[-600:]}"
    )
    return False


def main():
    mitm_text = YAKIT_MITM_TS.read_text(encoding="utf-8")
    global_text = YAKIT_GLOBAL_TS.read_text(encoding="utf-8")
    failed: list[str] = []

    for name, expected in MITM_KEYS + ANALYZE_KEYS:
        code = extract_template(mitm_text, name, "temp")
        if not run_yak_and_check(code, expected, name):
            failed.append(name)

    for name, expected in GLOBAL_KEYS:
        code = extract_template(global_text, name, "content")
        if not run_yak_and_check(code, expected, name):
            failed.append(name)

    if failed:
        sys.exit(f"FAILED: {failed}")
    total = len(MITM_KEYS) + len(ANALYZE_KEYS) + len(GLOBAL_KEYS)
    print(f"\nAll round-trip checks passed ({total}/{total})")


if __name__ == "__main__":
    main()
