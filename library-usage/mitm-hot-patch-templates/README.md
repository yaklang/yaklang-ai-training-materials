# MITM 热加载模版库

本目录提供 Yakit MITM（中间人代理）热加载（Hot Patch）功能的 13 个新增模板。
覆盖 yakit MITM 引擎暴露的 6 类 Hook：

| 类别 | Hook 函数 | 本目录覆盖模板 |
|------|----------|--------------|
| 请求劫持 | `hijackHTTPRequest` | M1 / M2 / M3 |
| 响应劫持 | `hijackHTTPResponseEx` | M4 / M5 |
| 镜像类 | `mirrorHTTPFlow` / `mirrorFilteredHTTPFlow` / `mirrorNewWebsite` / `mirrorNewWebsitePath` | M6 / M7 / M8 / M9 |
| 入库前 | `hijackSaveHTTPFlow` | M10 / M11 |
| Mock | `mockHTTPRequest` | M12 / M13 |

## 模版列表

| 编号 | 文件 | 名称 | 主 Hook |
|------|------|------|---------|
| M1 | `m01-hijack-modify-json-field.yak` | [请求] hijackHTTPRequest 改 JSON 字段（金额/折扣演示） | hijackHTTPRequest |
| M2 | `m02-hijack-inject-token-header.yak` | [请求] hijackHTTPRequest 注入 X-Auth-Token / Cookie | hijackHTTPRequest |
| M3 | `m03-hijack-drop-blacklist.yak` | [请求] hijackHTTPRequest 黑名单 drop 静态资源/敏感 host | hijackHTTPRequest + drop |
| M4 | `m04-hijack-response-strip-js.yak` | [响应] hijackHTTPResponseEx 删除阻断 JS (alert / location.href) | hijackHTTPResponseEx |
| M5 | `m05-hijack-response-rewrite-security-headers.yak` | [响应] hijackHTTPResponseEx 宽松 CORS / 删 CSP / 去 HttpOnly | hijackHTTPResponseEx |
| M6 | `m06-mirror-color-by-status.yak` | [镜像] mirrorHTTPFlow 按状态码自动染色 | mirrorHTTPFlow |
| M7 | `m07-mirror-filtered-extract-secrets.yak` | [镜像] mirrorFilteredHTTPFlow 流式提取手机号/邮箱/JWT | mirrorFilteredHTTPFlow |
| M8 | `m08-mirror-new-website-fingerprint.yak` | [镜像] mirrorNewWebsite 新域名自动指纹识别 | mirrorNewWebsite |
| M9 | `m09-mirror-new-path-nuclei.yak` | [镜像] mirrorNewWebsitePath 新路径自动 nuclei 扫描 | mirrorNewWebsitePath |
| M10 | `m10-save-tag-sensitive-keywords.yak` | [入库] hijackSaveHTTPFlow 敏感关键字染色 + tag | hijackSaveHTTPFlow |
| M11 | `m11-save-pii-redaction.yak` | [入库] hijackSaveHTTPFlow PII 脱敏入库 | hijackSaveHTTPFlow |
| M12 | `m12-mock-danger-protect.yak` | [Mock] mockHTTPRequest 危险操作保护（DELETE/PUT 强制 mock） | mockHTTPRequest |
| M13 | `m13-mock-vuln-virtual-range.yak` | [Mock] mockHTTPRequest 虚拟靶场（SQLi/RCE/SSRF） | mockHTTPRequest |

## 文件结构

每个 .yak 文件采用 "模板 + 自测块" 结构，模板边界标记 `===== HOT PATCH TEMPLATE START/END =====` 内包含两部分：

1. **模板纯代码** — 注册 hook 函数（`hijackHTTPRequest` / `hijackSaveHTTPFlow` / `mockHTTPRequest` 等）。
2. **自测块** — `if YAK_MAIN { runSelfTest() }` 守卫的本地验证代码。

## `YAK_MAIN` 调试机制

- `YAK_MAIN` 是 yaklang 引擎内置注入的全局布尔变量
- `yak xxx.yak` 命令行直接执行：`YAK_MAIN = true`，调用 `runSelfTest()` 做 mock 自测
- yakit MITM 热加载窗口加载：`YAK_MAIN = false`，下方测试代码不会执行
- 因此把完整模板（含自测块）粘贴到 yakit 热加载窗口是绝对安全的

## MITM Hook self test mock 模式

| Hook | self test 验证方式 |
|------|------------------|
| `hijackHTTPRequest(isHttps, url, req, forward, drop)` | 自定义 `forward`/`drop` callback，调用后断言被捕获的请求内容 |
| `hijackHTTPResponseEx(isHttps, url, req, rsp, forward, drop)` | 同上，断言修改后的响应内容 |
| `mirrorHTTPFlow / mirrorFilteredHTTPFlow` | 直接调用 hook，断言外层状态变更（map / slice append / flow 染色字段） |
| `mirrorNewWebsite / mirrorNewWebsitePath` | 同 mirror，验证副作用 |
| `hijackSaveHTTPFlow` | 用 map 模拟 `flow = {Request, Response, ...}`，验证 modify(flow) 被调用且字段被改写 |
| `mockHTTPRequest` | 自定义 `mockResponse` callback，验证目标 URL 触发了响应、非目标未触发 |

## 验证

### 单文件验证

```
cd /Users/v1ll4n/Projects/yaklang-ai-training-materials/library-usage/mitm-hot-patch-templates
yak m01-hijack-modify-json-field.yak
```

### 批量验证

```
for f in *.yak; do
  echo "=== $f ==="
  yak "$f" 2>&1 | tail -3
done
```

所有脚本应当：
- 8 秒内执行完成
- 所有 assert 通过
- log 输出全部为英文
- 最终出现 `xxx self test passed`

## 与 Yakit 默认模版库的对应关系

13 个模板会追加到 yakit 的 MITM 默认热加载数组 `MITMHotPatchTempDefault`（文件 `app/renderer/src/main/src/defaultConstants/mitm.ts`）中，结构 `{name, temp, isDefault: true}`。

## 关键词索引

MITM, 中间人代理, hijackHTTPRequest, hijackHTTPResponse, hijackHTTPResponseEx,
mirrorHTTPFlow, mirrorFilteredHTTPFlow, mirrorNewWebsite, mirrorNewWebsitePath,
hijackSaveHTTPFlow, mockHTTPRequest, 请求劫持, 响应劫持, 流量染色, 入库改写,
危险操作保护, 虚拟靶场, 敏感数据脱敏
