# [file] 文件操作与IO库

## 常量

1. `file.O_APPEND` 同 Golang 中的 `os.O_APPEND` 用于创建文件的标志值，可以通过 `|` 来链接其他值
1. `file.O_CREATE` 同 Golang 中的 `os.O_CREATE` 用于创建文件的标志值，可以通过 `|` 来链接其他值
1. `file.O_EXCL` 同 Golang 中的 `os.O_EXCL` 用于创建文件的标志值，可以通过 `|` 来链接其他值
1. `file.O_RDONLY` 同 Golang 中的 `os.O_RDONLY` 用于创建文件的标志值，可以通过 `|` 来链接其他值
1. `file.O_RDWR` 同 Golang 中的 `os.O_RDWR` 用于创建文件的标志值，可以通过 `|` 来链接其他值
1. `file.O_SYNC` 同 Golang 中的 `os.O_SYNC` 用于创建文件的标志值，可以通过 `|` 来链接其他值
1. `file.O_TRUNC` 同 Golang 中的 `os.O_TRUNC` 用于创建文件的标志值，可以通过 `|` 来链接其他值
1. `file.O_WRONLY` 同 Golang 中的 `os.O_WRONLY` 用于创建文件的标志值，可以通过 `|` 来链接其他值

## 关键接口展示

### `*yaklib._yakFile` 的文件操作知多少

是 yak 封装的一个比原生 File 更好用的库，支持的接口如下：

```yak
type _yakFile interface {
    Name() string                   // 获取当前文件名
    Close() error                   // 关闭当前文件
    
    /* 读文件内容常见的函数 */
    ReadAll() ([]byte, error)       // 读出文件全部内容
    ReadString() (string, error)    // 读出文件全部内容，转成 string
    ReadLines() []string            // 按行读出文件全部内容
    
    /* 写文件内容 */
    WriteLine(i: interface{}) (count int, _ error)      // 写一行，如果输入是 string/[]byte 会被写成文本，如果是 []string 或默认是多行文本，如果输入是其他，将会被转成 JSON 对象，再写一行
    WriteString(i: string) (int, error)                 // 写一行字符串文本
    Write(i: interface)                                 // 写入内容，任何内容都可以写入，如果是一个对象，将优先变为 JSON 对象写入。

    GetOsFile() *os.File                                // 当 _yakFile 不够用的时候，通过这个方法，可以获得 `*os.File` 对象，可以像操作 Golang 一样操作他
}
```

### 从 `fs.FileInfo` 中获取文件信息

`fs.FileInfo` 其实是原生 Golang 的一个对象，但是这个对象我们很常用，所以我们讲在本小节讲解这个对象怎么使用

如果你有兴趣，Golang 官方文档原文在这里：[fs.FileInfo/os.FileInfo 接口定义](https://golang.org/pkg/io/fs/#FileInfo)

```yak
type FileInfo interface {
    Name() string       // 文件名
    Size() int64        // length in bytes for regular files; system-dependent for others 文件大小
    Mode() FileMode     // file mode bits
    ModTime() time.Time // modification time
    IsDir() bool        // abbreviation for Mode().IsDir()
    Sys() interface{}   // underlying data source (can return nil)
}
```

## 实战案例：

### 创建文件

#### 创建一个普通文件 `file.OpenFile(var1: string, mode: int, perm: int)`

我们使用最基本的 API 创建一个文件，以读写的权限打开，给予 0777 的权限。

这个函数其实是 Golang 的 `os.OpenFile` 包装而成的，[这里可以查看原始函数](https://golang.org/pkg/os/#OpenFile)

```yak
// 创建简单的文件
f, err := file.OpenFile("_testFile.txt", file.O_CREATE|file.O_RDWR, 0777)
die(err)
f.Write("we write some Message \n\n\n\n\nasdfahsdfasdf Now\n")
f.Close()

// 像 cat 一样，把文件打印出来到屏幕上
file.Cat("_testFile.txt")

// 移除文件
file.Rm("_testFile.txt")
```

上述文件输出结果为

```
we write some Message




asdfahsdfasdf Now

```

:::note 要注意，这个函数源自于 [Golang os.OpenFile](https://golang.org/pkg/os/#OpenFile)
:::


#### 简化 `file.OpenFile`，我们可以使用 `file.Open`

我们把上面的 `file.OpenFile` 进行了简化，我们第二个参数默认填写为 `file.O_CREATE|file.O_RDWR`，第三个权限默认填为 `0777`。

`file.Open("test-file.txt")` 等效为 `file.OpenFile("test-file.txt", file.O_CREATE|file.O_RDWR, 0777)`

```yak
f, err := file.Open("_testFile.txt")
die(err)

// 随便写一行输入吧
f.Write("这个使用案例是针对  file.Open(`_testFile.txt`) 的，其实很简单\n")
f.Close()
file.Cat("_testFile.txt")
file.Rm("_testFile.txt")
```

输出为

```
这个使用案例是针对  file.Open(`_testFile.txt`) 的，其实很简单
```

#### 创建临时文件 `file.TempFile(dir: string)`

```yak
// 创建一个临时文件
f, err := file.TempFile("")
die(err)
println("我们创建了一个临时文件：", f.Name())

// 往临时文件中写一个字符串
println("写入一点随机字符串")
f.Write("asdfasdf")

// 记得脚本结束要关闭文件
defer f.Close()

// 我们验证我们的内容写成功了没？
raw,  err := file.ReadFile(f.Name())
die(err)

println("我们写入的文件内容为：")

// 展示写的结果
dump(raw)
```

执行的结果为

```yak
我们创建了一个临时文件： /var/folders/tj/pfxp0gls4r74c_lx0hw48yjh0000gn/T/yak-320826568.tmp
写入一点随机字符串
我们写入的文件内容为：
([]uint8) (len=8 cap=512) {
 00000000  61 73 64 66 61 73 64 66                           |asdfasdf|
}
```

### 文件删除

文件删除直接调用 `file.Remove` 或者 `file.Rm` 都可以达成目的，其本质上是调用 `os.RemoveAll` 来执行的

```yak
fileName = "target-filename.txt"
file.Remove(fileName)
file.Rm(fileName)
```

### 文件移动

直接调用 `file.Rename(oldName, newName string)` 即可完成需求

当然，我们设置了快捷方式 `file.Mv(oldName: string, newName)` 。

这个操作本质上是使用 `os.Rename` 来完成的

### 文件按行读写

```yak
f, err := file.Open("12_fileio.yak")
die(err)
dump(f.ReadLines())
f.Close()
```

上述小代码的内容其实很简单，打开一个文件，然后按照行来读取，展示出来。

## 小结

`file` 包是一个轻巧易用的包，在保证基础的文件操作的同时，增加了一些封装的函数，让文件操作变得更简易。