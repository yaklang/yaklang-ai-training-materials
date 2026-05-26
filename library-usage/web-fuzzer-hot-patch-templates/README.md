# Web Fuzzer 热加载模版库

本目录提供 Yakit Web Fuzzer 热加载（Hot Patch）功能的 19 个新增模版。
重点覆盖"内网环境下的加密对抗"场景：国密、AES 多模式、签名/JWT、会话维护、fuzz tag 工具、响应/重试高级处理。

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

## 文件结构

每个 .yak 文件分为两部分：

1. 模版纯代码（在 `===== HOT PATCH TEMPLATE START =====` 和 `===== HOT PATCH TEMPLATE END =====` 之间），这部分会被原样复制到 Yakit 的内置热加载模版库中
2. 本地验证代码（`main()` 函数），用 mock 数据 + assert 校验模版逻辑正确，不会进入 yakit 模版库

## 验证方法

```
cd /Users/v1ll4n/Projects/yaklang-ai-training-materials/library-usage/web-fuzzer-hot-patch-templates
yak 01-guomi-sm4-cbc-response-decrypt.yak
```

所有脚本应当：
- 10 秒内执行完成
- 所有 assert 通过
- log 输出全部为英文

## 与 Yakit 默认模版库的对应关系

19 个模版会追加到 yakit 的默认热加载模版数组 `HotPatchTempDefault` 中。
i18n key 统一前缀为 `HTTPFuzzerHotPatch.`，命名 snake_case，与现有 6 个内置模版保持一致。

## 关键词索引

国密, SM4, SM2, SM3, AES-CBC, AES-GCM, AES-ECB, HMAC, MD5, SHA256, JWT,
beforeRequest, afterRequest, mirrorHTTPFlow, retryHandler, customFailureChecker,
fuzz tag, 响应解密, 请求加密, 签名生成, 签名爆破, 会话维护, 自动登录,
Token 注入, 验证码绕过, 双向通信, 内网对抗
