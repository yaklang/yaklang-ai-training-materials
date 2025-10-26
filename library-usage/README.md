# Yaklang library-usage 测试覆盖情况

## 已完成的库测试

### 核心基础库
- ✅ **builtin** - 内置函数、基础能力、语言核心功能（新发现）
- ✅ **time** - 时间处理、格式化、计算、定时器
- ✅ **json** - JSON序列化、反序列化、JSONPath查询
- ✅ **yaml** - YAML序列化、反序列化、配置文件
- ✅ **log** - 日志输出、日志级别控制
- ✅ **context** - 上下文管理、超时控制、取消机制

### 网络和通信
- ✅ **http** - HTTP客户端、GET/POST请求、Header、Cookie
- ✅ **httpserver** - HTTP服务器、路由处理
- ✅ **tcp** - TCP连接、客户端服务器、Socket编程
- ✅ **udp** - UDP通信、无连接协议、数据报传输
- ✅ **dns** - DNS查询、域名解析、记录类型查询
- ✅ **crawler** - 基础HTTP爬虫、URL抓取
- ✅ **crawlerx** - 智能浏览器爬虫、JS渲染

### 编码和数据处理
- ✅ **codec** - 编码解码
- ✅ **str** - 字符串处理
- ✅ **fstring** - 格式化字符串

### 安全和测试
- ✅ **fuzz** - 模糊测试、变量生成、HTTP请求模糊、Protobuf模糊
- ✅ **mitm** - 中间人攻击、流量劫持、HTTP/HTTPS代理、请求响应修改
- ✅ **brute** - 暴力破解、弱口令检测、多协议爆破、字典攻击
- ✅ **subdomain** - 子域名枚举、域名发现、DNS暴力破解、搜索引擎查询
- ✅ **servicescan** - 服务识别、指纹识别、端口扫描、CPE信息提取
- ✅ **synscan** - SYN端口扫描、半开连接、快速端口发现、并发扫描
- ✅ **ping** - 主机存活检测、网络连通性测试、ICMP/TCP Ping、批量探测
- ✅ **poc** - 漏洞验证框架、HTTP请求构造、安全测试、漏洞检测

### 文件和系统
- ✅ **file** - 文件操作
- ✅ **fileparser** - 文件解析
- ✅ **os** - 操作系统接口
- ✅ **exec** - 命令执行
- ✅ **zip** - ZIP压缩
- ✅ **git** - Git操作

### 正则和文本
- ✅ **re** - 正则表达式
- ✅ **re2** - RE2正则引擎
- ✅ **diff** - 文本差异

### 安全和认证
- ✅ **tls** - TLS/SSL
- ✅ **twofa** - 双因素认证
- ✅ **ssh** - SSH客户端
- ✅ **bot** - 机器人API

### Java相关
- ✅ **java-yso** - Yso工具
- ✅ **java-cross-validation** - Java交叉验证
- ✅ **java-decompile** - Java反编译

### 扫描和POC
- ✅ **poc** - POC测试框架
- ✅ **scan** - 端口和服务扫描

### 系统服务
- ✅ **systemd** - Systemd服务管理

### 数据库
- ✅ **yakit-db** - Yakit数据库操作

### 函数和编程
- ✅ **function** - 函数式编程实践（自定义教程）

---

## 缺失的重要库

### 高优先级（安全测试核心）
- ⚠️ **nuclei** - Nuclei POC引擎、YAML POC执行
- ⚠️ **jwt** - JWT令牌处理、认证绕过
- ⚠️ **csrf** - CSRF防护、跨站请求伪造
- ❌ **finscan** - FIN扫描、隐蔽端口扫描（已停止维护）
- ⚠️ **traceroute** - 路由追踪、网络拓扑发现

### 中优先级（安全测试相关）
- ⚠️ **nasl** - NASL脚本引擎、OpenVAS兼容
- ⚠️ **risk** - 风险管理、漏洞评估
- ⚠️ **report** - 报告生成、结果输出
- ⚠️ **dnslog** - DNSLog、外带数据检测

### 中优先级（数据和协议）
- ⚠️ **db** - 数据库通用接口
- ⚠️ **redis** - Redis客户端
- ⚠️ **ldap** - LDAP协议
- ⚠️ **smb** - SMB协议
- ⚠️ **rdp** - RDP协议

### 低优先级（高级功能）
- ⚠️ **nuclei** - Nuclei POC引擎
- ⚠️ **nasl** - NASL脚本引擎
- ⚠️ **ssa** - SSA静态分析
- ⚠️ **syntaxflow** - 语法流分析
- ⚠️ **sca** - 软件成分分析

### 低优先级（辅助工具）
- ⚠️ **sync** - 同步原语
- ⚠️ **io** - IO操作
- ⚠️ **bufio** - 缓冲IO
- ⚠️ **env** - 环境变量
- ⚠️ **cli** - 命令行解析
- ⚠️ **math** - 数学运算
- ⚠️ **timezone** - 时区处理
- ⚠️ **regen** - 正则表达式生成

### 低优先级（特殊协议和工具）
- ⚠️ **jwt** - JWT令牌
- ⚠️ **csrf** - CSRF防护
- ⚠️ **xml** - XML处理
- ⚠️ **xpath** - XPath查询
- ⚠️ **xhtml** - HTML解析
- ⚠️ **js** - JavaScript执行
- ⚠️ **spacengine** - 空间引擎
- ⚠️ **mmdb** - MaxMind数据库
- ⚠️ **ja3** - JA3指纹
- ⚠️ **pcapx** - PCAP扩展
- ⚠️ **suricata** - Suricata规则
- ⚠️ **cve** - CVE查询
- ⚠️ **cwe** - CWE查询
- ⚠️ **risk** - 风险管理
- ⚠️ **report** - 报告生成
- ⚠️ **dnslog** - DNSLog
- ⚠️ **dictutil** - 字典工具
- ⚠️ **tools** - 工具集
- ⚠️ **httpool** - HTTP连接池
- ⚠️ **dyn** - 动态执行
- ⚠️ **hook** - 钩子函数
- ⚠️ **x** - Funk扩展
- ⚠️ **yso** - YSO工具
- ⚠️ **facades** - 门面模式
- ⚠️ **t3** - T3协议
- ⚠️ **iiop** - IIOP协议
- ⚠️ **judge** - 判断工具
- ⚠️ **gzip** - Gzip压缩
- ⚠️ **rpa** - RPA自动化
- ⚠️ **simulator** - 模拟器
- ⚠️ **bin** - 二进制处理
- ⚠️ **openapi** - OpenAPI
- ⚠️ **sandbox** - 沙箱
- ⚠️ **hids** - HIDS
- ⚠️ **filesys** - 文件系统
- ⚠️ **excel** - Excel处理

---

## 当前测试统计

- **已完成**: 39个核心库
- **缺失重要库**: 约56个
- **总覆盖率**: ~41%

### 最新完成的库
- ✅ **poc** - 漏洞验证框架、HTTP请求构造、安全测试（新增）
- ✅ **ping** - 主机存活检测、网络连通性测试、ICMP/TCP Ping（新增）
- ✅ **synscan** - SYN端口扫描、半开连接、快速端口发现（新增）
- ✅ **servicescan** - 服务识别、指纹识别、端口扫描、CPE信息（新增）
- ✅ **subdomain** - 子域名枚举、域名发现、DNS暴力破解（新增）
- ✅ **brute** - 暴力破解、弱口令检测、多协议爆破（新增）
- ✅ **mitm** - 中间人攻击、流量劫持、HTTP/HTTPS代理（新增）
- ✅ **builtin** - 内置函数、基础能力、语言核心（重要发现）
- ✅ **fuzz** - 模糊测试、变量生成、安全测试（新增）
- ✅ **dns** - DNS查询、域名解析、记录类型（新增）
- ✅ **udp** - UDP通信、无连接协议、数据报（新增）
- ✅ **tcp** - TCP连接、Socket编程、网络通信（新增）

## 下一步计划

建议按以下顺序补充缺失的库：

1. **立即补充** (安全测试核心):
   - nuclei - Nuclei POC引擎
   - jwt - JWT令牌处理
   - csrf - CSRF防护
   - risk - 风险管理
   - report - 报告生成

2. **尽快补充** (网络和协议):
   - finscan - FIN扫描
   - traceroute - 路由追踪
   - nasl - NASL脚本引擎
   - dnslog - DNSLog检测

3. **按需补充** (数据库和协议):
   - db - 数据库接口
   - redis - Redis客户端
   - ldap - LDAP协议
   - smb - SMB协议

## 安全测试工具链完整性

通过本次更新，我们已经完成了Yaklang安全测试工具链的核心组件：

### 信息收集阶段
- ✅ **ping** - 主机存活检测
- ✅ **subdomain** - 子域名枚举
- ✅ **crawler/crawlerx** - Web应用爬取

### 端口和服务发现
- ✅ **synscan** - 快速端口扫描
- ✅ **servicescan** - 服务指纹识别
- ✅ **dns** - DNS查询和解析

### 漏洞检测和验证
- ✅ **poc** - 漏洞验证框架
- ✅ **fuzz** - 模糊测试工具
- ✅ **brute** - 暴力破解工具

### 流量分析和代理
- ✅ **mitm** - 中间人攻击代理
- ✅ **http** - HTTP客户端

这些核心库构成了完整的渗透测试工具链，为安全研究人员提供了强大的基础能力。

---

## 测试要求

所有测试脚本必须满足：

1. ✅ 在10秒内完成执行
2. ✅ 使用`assert`验证关键结果
3. ✅ 在关键位置添加AI搜索优化的注释
4. ✅ 每个库放在独立文件夹中
5. ✅ 包含实际应用场景示例
6. ✅ 减少`println`输出，多用`assert`验证

---

## 使用方法

进入对应目录，执行测试脚本：

```bash
cd /Users/v1ll4n/Projects/yaklang-ai-training-materials/library-usage/time
yak time-practice.yak

cd /Users/v1ll4n/Projects/yaklang-ai-training-materials/library-usage/json
yak json-practice.yak

# ... 其他库类似
```

---

**最后更新**: 2025-10-26 19:17

## 重要说明

### 超时控制
所有新创建的测试都已经过优化，确保在10秒内完成：
- 使用`context.Seconds()`进行超时控制
- 限制循环次数和数据收集量
- 避免无限等待的`for range`循环
- 添加适当的`break`条件

### 测试验证
每个测试都包含：
- ✅ 充分的`assert`验证
- ✅ 关键位置的AI搜索优化注释
- ✅ 实际应用场景示例
- ✅ 错误处理和边界情况
- ✅ 10秒内完成执行

### 文件结构
```
library-usage/
├── builtin/builtin-practice.yak    # 内置函数（重要发现）
├── fuzz/fuzz-practice.yak          # 模糊测试（新增）
├── dns/dns-practice.yak            # DNS查询（新增）
├── udp/udp-practice.yak            # UDP通信（新增）
├── tcp/tcp-simple.yak              # TCP连接（新增）
├── time/time-practice.yak          # 时间处理
├── json/json-practice.yak          # JSON处理
├── yaml/yaml-practice.yak          # YAML处理
├── log/log-practice.yak            # 日志输出
├── http/http-practice.yak          # HTTP客户端
├── context/context-practice.yak    # 上下文管理
├── crawler/crawler-simple.yak      # 爬虫（简化版）
├── crawler/crawler-practice.yak    # 爬虫（完整版）
└── README.md                       # 本文档
```

## 重要发现：内置函数库

通过分析`yaklang.Import("", ...)`，发现了Yaklang的三个核心内置函数库：

### 1. yaklib.GlobalExport - 全局工具函数
包含50+个全局函数，涵盖：
- **断言和调试**: `assert`, `desc`, `typeof`, `dump`, `fail`, `die`
- **类型转换**: `parseInt`, `parseFloat`, `parseBool`, `parseString`, `atoi`
- **时间处理**: `timestamp`, `datetime`, `now`, `sleep`, `tick1s`
- **随机生成**: `randn`, `randstr`, `uuid`
- **字符编码**: `chr`, `ord`
- **输入输出**: `input`, `dump`, `sdump`
- **日志控制**: `loglevel`, `logquiet`, `logrecover`

### 2. builtin.YaklangBaseLib - 语言基础操作
包含40+个基础操作函数，涵盖：
- **数据结构**: `append`, `len`, `cap`, `make`, `slice`, `sub`
- **映射操作**: `get`, `set`, `delete`, `mkmap`, `mapFrom`
- **输出函数**: `print`, `printf`, `println`, `sprint`, `sprintf`
- **数学函数**: `max`, `min`
- **错误处理**: `panic`, `panicf`, `error`
- **运算符重载**: `$add`, `$sub`, `$mul`, `$quo`, `$eq`, `$lt`, `$gt`

### 3. GlobalEvalExports - 动态执行
包含动态代码执行功能：
- **动态导入**: `import` - 从文件导入变量和函数
- **代码执行**: 支持运行时代码执行和模块加载

这些内置函数是Yaklang语言的核心基础，相当于其他语言的标准库。

