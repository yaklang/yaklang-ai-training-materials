#!/usr/bin/env python3
"""
Extract the 5 newly injected templates from the yakit HTTPFuzzerPage.ts and run
them through `yak` standalone to make sure the round-trip (yak file → ts string →
extracted back → run) still passes the self test.
"""
import re
import subprocess
import sys
import tempfile
from pathlib import Path

YAKIT_TS = Path(
    "/Users/v1ll4n/Projects/yakit/app/renderer/src/main/src/defaultConstants/HTTPFuzzerPage.ts"
)
KEYS = [
    ("challenge_response_sign", "challenge response sign self test passed"),
    ("bootstrap_session_pipeline", "bootstrap session pipeline self test passed"),
    ("aes_cbc_key_iv_envelope", "aes cbc key/iv envelope self test passed"),
    ("mitm_hijack_save_decrypt", "hijack save http flow self test passed"),
    ("mock_http_offline_response", "mock http request self test passed"),
]


def unescape_ts_template(s: str) -> str:
    """Reverse of escape_ts_template: \\` → `, \\${ → ${, \\\\ → \\."""
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
                # could be \${
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


def extract_template(ts_text: str, key: str) -> str:
    needle = f"'HTTPFuzzerHotPatch.{key}'"
    idx = ts_text.find(needle)
    if idx < 0:
        raise RuntimeError(f"key {key} not found in ts file")
    # Find the `temp: \`` start after nameUi.
    temp_open = ts_text.find("temp: `", idx)
    if temp_open < 0:
        raise RuntimeError(f"temp open backtick not found near {key}")
    start = temp_open + len("temp: `")
    # Walk forward to find the closing unescaped backtick.
    i = start
    while i < len(ts_text):
        c = ts_text[i]
        if c == "\\":
            i += 2
            continue
        if c == "`":
            end = i
            break
        i += 1
    else:
        raise RuntimeError(f"closing backtick not found for {key}")
    return unescape_ts_template(ts_text[start:end])


def main():
    ts_text = YAKIT_TS.read_text(encoding="utf-8")
    failed = []
    for key, expected_log in KEYS:
        code = extract_template(ts_text, key)
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
                    timeout=8,
                )
                stdout = result.stdout
                stderr = result.stderr
            except subprocess.TimeoutExpired as te:
                # G1-G4 may hold httpserver goroutines past the self-test;
                # killed-by-timeout is fine as long as the expected log appeared.
                stdout = (te.stdout or b"").decode("utf-8", errors="ignore") if isinstance(te.stdout, (bytes, bytearray)) else (te.stdout or "")
                stderr = (te.stderr or b"").decode("utf-8", errors="ignore") if isinstance(te.stderr, (bytes, bytearray)) else (te.stderr or "")
        finally:
            Path(tmp_path).unlink(missing_ok=True)
        if expected_log not in stdout + stderr:
            print(
                f"FAIL {key}: expected '{expected_log}' not in output:\n"
                f"stdout: {stdout[-500:]}\n"
                f"stderr: {stderr[-500:]}"
            )
            failed.append(key)
        else:
            print(f"PASS {key}: round-trip from yakit ts → run → '{expected_log}'")
    if failed:
        sys.exit(f"FAILED: {failed}")
    print("\nAll round-trip checks passed (5/5)")


if __name__ == "__main__":
    main()
