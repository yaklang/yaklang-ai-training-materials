# 在函数中处理崩溃和 die(err) 的问题

一般来说，推荐所有的错误都显示处理，但是如果每次都处理 `die(err)` 造成的程序崩溃，程序代码会臃肿。

如果一个任务函数没有那么重要，你可以通过 `defer recover()` 来直接处理，案例如下：

```yak
func task() {
    defer recover()
    die(1)
}

task()
/*
OUTPUT:

[INFO] 2025-03-17 14:30:55 YakVM Code DIE With Data: (int) 1

[WARN] 2025-03-17 14:30:55 [vm_exec:1829] defer recover() catch: (string) (len=8) "(int) 1\n"

*/
```

如果一个任务函数很重要，`recover()` 可以直接捕捉到这个函数执行过程中的崩溃，可以参考如下代码：

```yak
func task() {
    defer func {
        err = recover()
        println("catched die err: %v" % err)
    }
    die(1)
}

task()
/*
OUTPUT:

[INFO] 2025-03-17 14:32:51 YakVM Code DIE With Data: (int) 1

catched die err: (int) 1
*/
```

## WavyCall （波浪号 ~） 抛出的错误处理
    
如果一个函数后面加波浪号，这个叫 wavycall 是 yaklang 中特有的语法，可以简化错误处理。

```yak
rsp, req := poc.HTTPEx(packet)~ // 这个代码等价于 `rsp, req, err := poc.HTTPEx(packet)~; die(err)`
```

如果要处理这种错误，可以参考如下代码：

```yak
try { 
    rsp, req := poc.HTTPEx(packet)~ // 使用 try-catch 来局部捕捉错误
} catch (err) {
    println("catched err: %v" % err)
}
```

如果你的 `poc.HTTPEx()~` 在一个函数中，也可以使用函数级的崩溃捕捉处理

```yak
func task() {
    defer recover()
    rsp, req := poc.HTTPEx(packet)~ // 使用 try-catch 来局部捕捉错误
}

这样在 task 函数中，如果 `poc.HTTPEx(packet)~` 崩溃了，会自动捕捉到错误，并打印出来。

一般来说，try-catch 的语法和 defer recover 的语法是可以同时使用的。可以看如下的案例。

```yak
func a () { die("a") }

func b() { die("unexpected not try-catched") }

func c() {
    defer func{
        err := recover()
        if err != nil {
            println("defer recover catch err: %v" % err)
        }
    }
    try {
        a()
    } catch e {
        println("a() 's error is handled: %v" % e)
    }
    b()
}

c()
/*
OUTPUT:

[INFO] 2025-03-17 14:38:49 YakVM Code DIE With Data: (string) (len=1) "a"

a() 's error is handled: a
[INFO] 2025-03-17 14:38:49 YakVM Code DIE With Data: (string) (len=26) "unexpected not try-catched"

defer recover catch err: unexpected not try-catched
*/
```

# case

```
//# 章节：错误处理与崩溃恢复机制
// 本段代码演示 Yak 语言中错误处理的核心机制，包含 defer/recover、try-catch、波浪号操作符等关键语法

//## 基础崩溃恢复模式
// 使用 defer recover() 实现全局错误捕获
// 适用场景：非关键性任务函数的错误抑制
func task() {
    defer recover()  // 注册全局恢复点，捕获后续die抛出的错误
    die(1)           // 显式抛出错误并终止程序
}

task()
/*
输出解析：
[INFO] 显示原生错误信息（die抛出）
[WARN] 显示recover捕获的错误堆栈
*/


//## 关键任务错误处理
// 带错误日志记录的高级恢复模式
func criticalTask() {
    defer func {       // 匿名函数捕获错误上下文
        err := recover()
        println("关键任务崩溃捕获: %v" % err)  // 自定义错误日志
    }
    die(1)  // 模拟关键操作失败
}

criticalTask()


//# 章节：波浪号操作符(~)错误处理
// 波浪号语法糖：自动错误检查与抛出
// 等价于 poc.HTTPEx(packet)~ => rsp, req, err := poc.HTTPEx(packet); die(err)
rsp, req := poc.HTTPEx(packet)~  // 简化错误传播语法


//## 波浪号错误的局部捕获
try { 
    // 高风险操作使用try-catch包裹
    rsp, req := poc.HTTPEx(packet)~  
} catch err {
    println("HTTP请求失败: %v" % err)  // 精确捕获网络错误
}


//## 函数级错误隔离
func safeRequest() {
    defer recover()  // 函数级安全边界
    rsp, req := poc.HTTPEx(packet)~  // 自动错误传播
}


//# 章节：错误处理优先级
// 演示 try-catch 与 defer recover 的捕获顺序
func a () { die("a") }      // 基础错误源
func b() { die("未捕获错误") } // 未受保护的错误

func errorPriorityDemo() {
    defer func{  // 函数级恢复点
        err := recover()
        println("最终捕获: %v" % err)  // 兜底错误处理
    }
    
    try {        // 局部优先处理
        a()
    } catch e {
        println("局部捕获: %v" % e)  // 优先处理
    }
    
    b()  // 未受保护的错误向上传播
}

errorPriorityDemo()
/*
执行流程：
1. a() 的错误被最近的try-catch捕获
2. b() 的错误传播到函数级defer recover
3. 最终由defer块处理未捕获错误
*/
```