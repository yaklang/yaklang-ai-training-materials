# Level 3: 错误处理与重试机制

## 题目描述

编写一个 Yak 脚本，实现健壮的网络请求重试机制，包含错误处理、重试策略、超时控制。

要求：
1. 实现可配置的重试函数
2. 支持指数退避重试策略
3. 区分可重试和不可重试的错误
4. 实现超时控制
5. 记录详细的重试日志
6. 统计成功率

## 功能需求

- 最大重试次数：3
- 初始重试间隔：1秒
- 重试间隔增长：指数退避（1s, 2s, 4s）
- 请求超时：5秒
- 可重试错误：网络错误、超时、5xx错误
- 不可重试错误：4xx客户端错误

## 预期输出

```
=== Retry Mechanism Test ===

[Test 1] Simulating unstable service
Attempt 1/3: Request failed (timeout)
  Waiting 1s before retry...
Attempt 2/3: Request failed (connection refused)
  Waiting 2s before retry...
Attempt 3/3: Request succeeded!
  Status: 200, Time: 234ms
Result: ✓ Success after 3 attempts

[Test 2] Simulating 404 error
Attempt 1/3: Request failed (404 Not Found)
  Error is not retryable (4xx error)
Result: ✗ Failed (non-retryable error)

[Test 3] Simulating 500 error then success
Attempt 1/3: Request failed (500 Internal Server Error)
  Waiting 1s before retry...
Attempt 2/3: Request succeeded!
  Status: 200, Time: 123ms
Result: ✓ Success after 2 attempts

=== Statistics ===
Total tests: 3
Successful: 2
Failed: 1
Success rate: 66.67%
Average attempts: 2.33
```

## 解题思路

1. **重试函数设计**
   - 接受请求函数作为参数
   - 返回结果和错误
   - 实现重试逻辑

2. **错误分类**
   - 网络错误：可重试
   - 超时错误：可重试
   - 5xx 错误：可重试
   - 4xx 错误：不可重试
   - 2xx 成功：不重试

3. **重试策略**
   - 指数退避算法
   - 最大重试次数限制
   - 使用 `sleep()` 实现延迟

4. **错误处理**
   - 使用 try-catch 捕获异常
   - 使用 `~` 操作符处理错误
   - 详细的错误日志

5. **统计分析**
   - 记录每次尝试
   - 统计成功率
   - 计算平均重试次数

## 关键知识点

- 高阶函数（函数作为参数）
- 错误处理：try-catch, defer-recover
- `sleep(seconds)` - 延迟执行
- `time.Now()` - 时间操作
- 指数退避算法
- 日志记录
- 统计计算

## 难度等级

⭐⭐⭐ Level 3 - 综合考察错误处理、重试策略、函数设计

## 评分标准

- 正确实现重试函数 (30%)
- 正确实现错误分类 (25%)
- 正确实现指数退避 (20%)
- 日志和统计完整 (15%)
- 代码结构清晰 (10%)

