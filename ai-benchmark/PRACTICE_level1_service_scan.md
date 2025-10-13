# Easy: 简单服务扫描

## 题目描述

编写一个 Yak 脚本，使用 `servicescan` 库扫描指定目标的端口，并统计扫描结果。

要求：
1. 扫描目标 `127.0.0.1` 的端口 `22,80,443,3306,8080`
2. 统计开放的端口数量
3. 列出所有开放端口及其服务信息
4. 统计关闭的端口数量

## 输入

- 目标：`127.0.0.1`
- 端口：`22,80,443,3306,8080`

## 预期输出

脚本应该输出类似：
```
Scanning 127.0.0.1:22,80,443,3306,8080...
Open Ports:
  - 22: openssh[7.4]
  - 80: nginx[1.18.0]
Closed Ports: 3
Total Scanned: 5
```

（实际结果取决于本机开放的端口）

## 解题思路

1. **使用 servicescan 库**
   - 调用 `servicescan.Scan(target, ports)` 进行扫描
   - 该函数返回一个 channel，需要用 for 循环遍历结果

2. **处理扫描结果**
   - 每个结果包含端口状态信息
   - 需要判断端口是 open 还是 closed
   - 统计各种状态的数量

3. **数据统计**
   - 使用变量记录开放端口数、关闭端口数
   - 收集开放端口的详细信息

4. **错误处理**
   - 使用 `die(err)` 或 `~` 操作符处理错误

## 关键知识点

- `servicescan.Scan(target, ports)` - 执行服务扫描
- `for result in channel` - 遍历 channel 获取结果
- `result.State` - 端口状态（open/closed）
- `result.Port` - 端口号
- `result.Fingerprint` - 服务指纹信息
- 错误处理：`~` 操作符或 `die(err)`

## 难度等级

⭐ Easy - 主要考察对 servicescan 库的基本使用

## 评分标准

- 正确调用 servicescan.Scan (30%)
- 正确遍历扫描结果 (20%)
- 正确判断端口状态 (20%)
- 正确统计各类端口数量 (20%)
- 错误处理正确 (10%)

