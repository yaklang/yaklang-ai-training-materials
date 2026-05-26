# HTTP 历史流量分析 热加载模版库

本目录提供 Yakit HTTP 历史流量分析（HTTPFlow Analyze）热加载（Hot Patch）功能的 4 个新增模板。
全部模板来自公众号 030 (2025-10-24) 实战案例落地版本，按统一标准带 `YAK_MAIN` 自测块。

## 涉及的 Hook

| Hook | 作用 |
|------|------|
| `analyzeHTTPFlow(flow, extract)` | 逐条流量回调；接收 `*schema.HTTPFlow` 和 `extract` 函数 |
| `onAnalyzeHTTPFlowFinish(totalCount, matchedCount)` | 分析结束回调；用于汇总、报告、写文件、写日志 |

**关键点**：
- `flow.GetRequest()` / `flow.GetResponse()` 必须用 **方法调用** 拿原文；`flow.Request` / `flow.Response` 是 strconv.Quote 转义后的内容
- `analyzeHTTPFlow` 是 **并发** 调用，操作共享变量需要 `sync.NewMutex()` 加锁
- `extract(ruleName, flow, ...content)` 每调用一次 `matchedCount` 就加 1

## 模板列表

| 编号 | 文件 | 名称 | Hook |
|------|------|------|------|
| A1 | `a01-extract-phones-tokens.yak` | [分析] 敏感数据全量提取（手机号/JWT/Authorization）+ JSON 报告 | analyzeHTTPFlow + onAnalyzeHTTPFlowFinish |
| A2 | `a02-host-stats.yak` | [分析] 主机访问次数统计 | analyzeHTTPFlow + onAnalyzeHTTPFlowFinish |
| A3 | `a03-classify-by-path.yak` | [分析] 自动分类（登录/上传/后台）+ tag + 染色 | analyzeHTTPFlow |
| A4 | `a04-abnormal-status-report.yak` | [分析] 异常状态码报告（4xx/5xx 饼图 + 表格） | analyzeHTTPFlow + onAnalyzeHTTPFlowFinish + report.New |

## self test mock 模式

由于真实的 `*schema.HTTPFlow` 有 GetRequest / GetResponse / Red / AddTag 等方法，self test 用 `make(map[string]any)` + 闭包方法 stub 出来：

```yak
flow = make(map[string]any)
flow["Url"] = "http://target/api/login"
flow["Method"] = "POST"
flow["Host"] = "target"
flow["StatusCode"] = 200
flow["GetRequest"] = func() { return reqStr }
flow["GetResponse"] = func() { return rspStr }
flow["Red"] = func() { coloredRed = true }
flow["AddTag"] = func(tags...) { for t in tags { addedTags = append(addedTags, t) } }
```

这样 `flow.GetResponse()` / `flow.Red()` / `flow.AddTag(...)` 在自测时与生产时一致。

## YAK_MAIN 调试机制

- `YAK_MAIN` 是 yaklang 引擎内置注入的全局布尔变量
- `yak xxx.yak` 命令行运行：`YAK_MAIN = true`，运行 `runSelfTest()`
- yakit 历史分析热加载窗口加载：`YAK_MAIN = false`，自测块不执行
- 因此完整模板（含自测块）粘贴到 yakit 是绝对安全的

## 验证

```
cd /Users/v1ll4n/Projects/yaklang-ai-training-materials/library-usage/httpflow-analyze-hot-patch-templates
for f in *.yak; do echo "=== $f ==="; yak "$f" 2>&1 | tail -3; done
```

## 与 Yakit 默认模版库的对应关系

4 个模板会追加到 yakit 的分析默认热加载数组 `AnalyzeHotPatchTempDefault`（文件 `app/renderer/src/main/src/defaultConstants/mitm.ts` 末尾），结构 `{name, temp, isDefault: true}`。

## 关键词索引

analyzeHTTPFlow, onAnalyzeHTTPFlowFinish, GetRequest, GetResponse, AddTag,
report.New, 饼图, 表格, JSON 报告, 流量染色, 敏感数据全量提取, 主机统计,
登录上传后台分类, 异常状态码报告, 公众号 030
