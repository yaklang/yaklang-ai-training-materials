# 全局热加载模版库

本目录提供 Yakit 全局热加载（Global Hot Patch）功能的 5 个新增模板。
全局热加载是 MITM / Web Fuzzer 共享的全系统级 hook，**执行顺序：全局 HotPatch → 模块 HotPatch**。

## 全局 vs 模块 pipeline

| 维度 | 全局热加载 | 模块（MITM / WebFuzzer）热加载 |
|------|----------|----------------------------|
| 入口 | 配置管理 → 全局模板 | MITM 配置 / Fuzzer Hot Patch 窗口 |
| 作用范围 | 全系统所有 MITM/Fuzzer 流量 | 仅当前 MITM 任务或 Fuzzer Tab |
| 执行顺序 | 先于模块 hook 执行 | 后于全局 hook 执行 |
| 适合场景 | 协议归一化、统一签名、全站染色、危险操作护栏 | 单任务/单接口的特化处理 |
| 启用方式 | 同时只能启用 1 个 | 每个 MITM/Tab 独立 |

## 模板列表

| 编号 | 文件 | 名称（中文）| 主 Hook |
|------|------|----------|---------|
| G'1 | `g01-global-sm4-transparent.yak` | [全局] 内网 SM4-CBC 透明加解密 + 入库明文 | beforeRequest + afterRequest + hijackSaveHTTPFlow |
| G'2 | `g02-global-challenge-sign-pipeline.yak` | [全局] 动态 Challenge + HMAC 签名注入 pipeline | beforeRequest |
| G'3 | `g03-global-auto-bearer-token.yak` | [全局] 默认 Authorization Bearer 自动注入 | beforeRequest + hijackHTTPRequest |
| G'4 | `g04-global-flow-tag-coloring.yak` | [全局] 流量染色 + tag（敏感关键字/状态码）| hijackSaveHTTPFlow |
| G'5 | `g05-global-danger-mock-protect.yak` | [全局] 危险操作 Mock 保护（DELETE/PUT 自动 mock）| mockHTTPRequest |

## i18n（仅本目录有）

全局热加载模板与 yakit i18n 集成，模板中带 `对应 i18n key: GlobalHotPatch.xxx`。
i18n 键集中在 `yakit/app/renderer/src/main/public/locales/{zh,en}/webFuzzer.json` 的 `GlobalHotPatch` 节。

## YAK_MAIN 调试机制

每个模板都遵循 `if YAK_MAIN { runSelfTest() }` 守卫：
- `yak xxx.yak` 命令行运行：`YAK_MAIN = true`，运行 `runSelfTest()`
- yakit 全局热加载窗口加载：`YAK_MAIN = false`，自测块不执行
- 完整模板（含自测块）粘贴到 yakit 是绝对安全的

## 验证

```
cd /Users/v1ll4n/Projects/yaklang-ai-training-materials/library-usage/global-hot-patch-templates
for f in *.yak; do echo "=== $f ==="; yak "$f" 2>&1 | tail -3; done
```

## 与 yakit 集成

全局热加载的种入机制不同于 MITM / Fuzzer 默认模板数组（直接渲染 UI 列表），它通过
`pages/configManagement/ConfigManagement.tsx` 第 314-350 行的 `loadGlobalTemplateList` 在用户首次访问页面时调用
`CreateHotPatchTemplate` gRPC 接口将模板写入数据库。

本目录配套的 yakit 改造：
- `store/globalHotPatch.ts` 升级为 `DEFAULT_GLOBAL_TEMPLATES` 数组（保留兼容导出 `DEFAULT_GLOBAL_TEMPLATE_*`）
- `ConfigManagement.tsx` 把"只种入 1 个默认模板"循环化成"种入所有缺失模板"

## 关键词索引

全局热加载, GlobalHotPatch, SM4-CBC, Challenge, Bearer, 自动登录, 染色, AddTag, 危险操作保护,
beforeRequest, afterRequest, hijackHTTPRequest, hijackSaveHTTPFlow, mockHTTPRequest,
内网对抗, 协议归一化, 统一签名, 全站脱敏, 公众号 009
