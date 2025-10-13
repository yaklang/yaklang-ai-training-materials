# Medium: 并发批量端口扫描

## 题目描述

编写一个 Yak 脚本，使用并发方式批量扫描多个目标的常见端口。

要求：
1. 扫描 3 个目标：`127.0.0.1`, `localhost`, `::1`
2. 扫描端口：`22,80,443,3306,8080`
3. 使用 `SizedWaitGroup` 控制并发数量（最多 2 个并发任务）
4. 统计所有目标的扫描结果
5. 输出每个目标的开放端口数量和总体统计

## 输入

- 目标列表：`["127.0.0.1", "localhost", "::1"]`
- 端口列表：`22,80,443,3306,8080`
- 最大并发数：2

## 预期输出

```
=== Starting Concurrent Scan ===
Max concurrent tasks: 2
Targets: 3
Ports: 22,80,443,3306,8080

Scanning 127.0.0.1...
Scanning localhost...
[INFO] ... (scan logs)

=== Scan Results ===
Target: 127.0.0.1
  Open ports: 1
  - 3306: mysql[8.2.0]

Target: localhost
  Open ports: 1
  - 3306: mysql[8.2.0]

Target: ::1
  Open ports: 0

=== Summary ===
Total targets scanned: 3
Total open ports found: 2
Average open ports per target: 0.67
```

## 解题思路

1. **并发控制**
   - 使用 `sync.NewSizedWaitGroup(maxConcurrent)` 创建限制并发数的 WaitGroup
   - 使用 `wg.Add(1)` 和 `defer wg.Done()` 管理任务
   - 使用 `wg.Wait()` 等待所有任务完成

2. **并发扫描**
   - 使用 `go` 关键字启动并发任务
   - 每个 goroutine 扫描一个目标
   - 注意闭包中的变量捕获问题

3. **数据收集**
   - 使用 map 或 slice 收集各个目标的扫描结果
   - 注意并发写入时的数据安全（可以每个 goroutine 收集自己的结果，最后汇总）

4. **结果统计**
   - 统计每个目标的开放端口数
   - 计算总体统计信息

## 关键知识点

- `sync.NewSizedWaitGroup(size)` - 创建带并发限制的 WaitGroup
- `wg.Add(1)` - 增加等待计数
- `wg.Done()` - 完成一个任务
- `wg.Wait()` - 等待所有任务完成
- `go func() { ... }()` - 启动 goroutine
- 闭包变量捕获：`target := target`
- `defer` 关键字确保资源释放
- 并发编程的数据安全

## 难度等级

⭐⭐ Medium - 考察并发编程和 WaitGroup 的使用

## 评分标准

- 正确使用 SizedWaitGroup (30%)
- 正确实现并发扫描 (25%)
- 正确处理闭包变量 (15%)
- 正确收集和统计结果 (20%)
- 错误处理和输出格式 (10%)

