# Web Fuzzer 热加载模版库

本目录提供 Yakit Web Fuzzer 热加载（Hot Patch）功能的 24 个新增模版。
重点覆盖"内网环境下的加密对抗"场景：国密、AES 多模式、签名/JWT、会话维护、fuzz tag 工具、响应/重试高级处理。

最新一批（G 类）针对公众号 009 (2026-03-18 全局热加载) / 084 (2024-12-05 前端加密) 等文章场景做了专项补强：动态挑战应答、Bootstrap 多 Header 签名 pipeline、随机 key/iv 信封协议、`hijackSaveHTTPFlow` 入库改写、`mockHTTPRequest` 离线响应。

## 模版列表

### A 类 国密体系（内网必备）

| 编号 | 文件 | 名称 | 关键 Hook |
|------|------|------|-----------|
| A1 | `01-guomi-sm4-cbc-response-decrypt.yak` | [国密] 响应解密 SM4-CBC/Base64 | afterRequest |
| A2 | `02-guomi-sm4-cbc-bidirectional.yak` | [国密] 请求&响应 SM4-CBC 双向加解密 | beforeRequest + afterRequest |
| A3 | `03-guomi-sm4-cbc-bruteforce.yak` | [国密-爆破] SM4-CBC 字典加密爆破 | fuzz tag |
| A4 | `04-guomi-sm2-bruteforce.yak` | [国密-爆破] SM2 公钥加密字典爆破 | fuzz tag |

### B 类 AES 模式扩展

| 编号 | 文件 | 名称 | 关键 Hook |
|------|------|------|-----------|
| B1 | `05-aes-gcm-response-decrypt.yak` | [AES] 响应解密 AES-GCM/Base64 | afterRequest |
| B2 | `06-aes-ecb-response-decrypt.yak` | [AES] 响应解密 AES-ECB/Base64 | afterRequest |
| B3 | `07-aes-cbc-bidirectional.yak` | [AES] 请求&响应 AES-CBC 双向加解密 | beforeRequest + afterRequest |

### C 类 签名 / 认证补充

| 编号 | 文件 | 名称 | 关键 Hook |
|------|------|------|-----------|
| C1 | `08-sign-hmac-md5-bruteforce.yak` | [签名-爆破] HMAC-MD5 签名 | fuzz tag |
| C2 | `09-sign-appkey-timestamp-nonce.yak` | [签名] AppKey+Timestamp+Nonce 三方签名生成 | beforeRequest |
| C3 | `10-sign-body-md5-sm3.yak` | [签名] Body MD5/SM3 防篡改签名 | beforeRequest |
| C4 | `11-jwt-hs256-resign.yak` | [JWT] HS256 重签名 | beforeRequest |

### D 类 会话 / Token 维护

| 编号 | 文件 | 名称 | 关键 Hook |
|------|------|------|-----------|
| D1 | `12-session-auto-login-token.yak` | [会话] 自动登录注入 Authorization Token | beforeRequest |

### E 类 fuzz tag 工具集

| 编号 | 文件 | 名称 | 关键 Hook |
|------|------|------|-----------|
| E1 | `13-tool-hash-fuzztag.yak` | [工具] Hash fuzz tag (MD5/SHA1/SHA256/SM3) | fuzz tag |
| E2 | `14-tool-timestamp-fuzztag.yak` | [工具] 时间戳 fuzz tag | fuzz tag |
| E3 | `15-tool-uuid-fuzztag.yak` | [工具] UUID fuzz tag | fuzz tag |
| E4 | `16-tool-randstr-fuzztag.yak` | [工具] 随机字符串 fuzz tag | fuzz tag |

### F 类 响应 / 重试高级处理

| 编号 | 文件 | 名称 | 关键 Hook |
|------|------|------|-----------|
| F1 | `17-response-custom-failure-checker.yak` | [响应] customFailureChecker 自定义失败检查 | customFailureChecker |
| F2 | `18-retry-smart-retry.yak` | [重试] retryHandler 智能重试 | retryHandler |
| F3 | `19-mirror-flow-extract-chain.yak` | [流处理] mirrorHTTPFlow 提取参数链 | mirrorHTTPFlow |

### G 类 公众号场景专项补强（2026 新增）

| 编号 | 文件 | 名称 | 关键 Hook | 对应文章 |
|------|------|------|-----------|---------|
| G1 | `20-challenge-response-sign.yak` | [挑战] 动态 Challenge + HMAC 签名注入 | beforeRequest + 主动发包 | 009 (2026-03-18) |
| G2 | `21-bootstrap-session-pipeline.yak` | [会话] Bootstrap 动态会话 + 多 Header 签名 + 响应解密 | beforeRequest + afterRequest + session 缓存 | 009 (2026-03-18) |
| G3 | `22-aes-cbc-key-iv-envelope.yak` | [AES] 自带 key/iv 信封协议双向加解密 | beforeRequest + afterRequest | 084 (2024-12-05) |
| G4 | `23-mitm-hijack-save-decrypt.yak` | [MITM] hijackSaveHTTPFlow 数据库存储明文 | hijackSaveHTTPFlow | 009 / 084 |
| G5 | `24-mock-http-offline-response.yak` | [Mock] mockHTTPRequest 离线响应模拟 | mockHTTPRequest | yaklang 引擎能力补全 |

> G 类与 A-F 类的差别：
> - **G1 / G2** 把"先发副请求拿凭据再签名注入"流程沉淀下来，相比 D1（一次性登录拿 token）覆盖了挑战应答 / 引导会话两种更复杂的协议
> - **G3** 是"每次随机 key/iv 一起下发"的信封协议，与 B3（固定 key/iv）互补
> - **G4** 是 19 个模板中**唯一**演示 `hijackSaveHTTPFlow` 的样例，专为 MITM 入库改写场景
> - **G5** 是 19 个模板中**唯一**演示 `mockHTTPRequest` 的样例，用于离线协议调试和无服务联通时反复试错

## 文件结构

每个 .yak 文件采用统一的 "模板 + 自测块" 结构。模板边界标记 `===== HOT PATCH TEMPLATE START/END =====` 内包含两部分：

1. **模板纯代码** — 注册 `beforeRequest` / `afterRequest` / `mirrorHTTPFlow` 等 hook 函数，或定义 fuzz tag 函数（如 `decodeSm4` / `hash` 等）。
2. **自测块** — 用内置变量 `YAK_MAIN` 守卫的本地验证代码。

两部分整体（包括边界注释外的 `func runSelfTest()` 函数定义和 `if YAK_MAIN { runSelfTest() }` 调用）都属于"可复制到 yakit 的安全模板"。

## `YAK_MAIN` 调试机制（重要）

每个模板末尾都有形如：

```
/*
========== 模板自测块（YAK_MAIN 守卫）==========
说明：
  - 用 `yak xxx.yak` 命令行运行时，YAK_MAIN = true，会调用 runSelfTest() 做 mock 自测
  - 当本模板被复制到 yakit Fuzzer 热加载使用时，YAK_MAIN = false，下方测试代码不会执行
  - 修改模板后用 `yak xxx.yak` 一键自测，安全调试不影响 yakit 实际使用
*/

func runSelfTest() {
    // 用 mock 数据 + assert 验证 hook 函数的行为
    ...
}

if YAK_MAIN {
    runSelfTest()
}
```

### 工作原理

- `YAK_MAIN` 是 yaklang 引擎内置注入的全局布尔变量
- 通过 `yak xxx.yak` 命令行直接执行（`ExecuteMain`）时：`YAK_MAIN = true`
- 通过 yakit Web Fuzzer 热加载（`ExecuteEx` / `dyn.Eval`）时：`YAK_MAIN = false`（默认值）
- 因此：把完整模板（含自测块）粘贴到 yakit 热加载窗口是**绝对安全的** — yakit 加载时只会注册 hook 函数，不会跑 mock 数据

### 调试流程

1. 在 yakit 中选中某个模板（如 `[国密] 响应解密 SM4-CBC/Base64`），点击"复制代码"或导出全部代码
2. 把代码粘到本地 `.yak` 文件（例如 `my-template.yak`）
3. 修改 key / iv / 字典 / 解密逻辑等
4. 命令行执行 `yak my-template.yak` 一键自测
5. 看到 `xxx self test passed` 即可放心粘回 yakit 使用

## 验证方法

### 单文件验证

```
cd /Users/v1ll4n/Projects/yaklang-ai-training-materials/library-usage/web-fuzzer-hot-patch-templates
yak 01-guomi-sm4-cbc-response-decrypt.yak
```

### 批量验证

```
for f in *.yak; do
  echo "=== $f ==="
  yak "$f" 2>&1 | tail -5
done
```

所有脚本应当：
- 10 秒内执行完成
- 所有 assert 通过
- log 输出全部为英文
- 最终出现 `xxx self test passed`

## 与 Yakit 默认模版库的对应关系

24 个模版会追加到 yakit 的默认热加载模版数组 `HotPatchTempDefault` 中。
i18n key 统一前缀为 `HTTPFuzzerHotPatch.`，命名 snake_case，与现有 6 个内置模版保持一致。

## 关键词索引

国密, SM4, SM2, SM3, AES-CBC, AES-GCM, AES-ECB, HMAC, MD5, SHA256, JWT,
beforeRequest, afterRequest, mirrorHTTPFlow, retryHandler, customFailureChecker,
hijackSaveHTTPFlow, mockHTTPRequest,
fuzz tag, 响应解密, 请求加密, 签名生成, 签名爆破, 会话维护, 自动登录,
Token 注入, 挑战应答, Bootstrap Session, 信封协议, 双向加解密,
MITM 入库, 离线 Mock, 验证码绕过, 内网对抗
