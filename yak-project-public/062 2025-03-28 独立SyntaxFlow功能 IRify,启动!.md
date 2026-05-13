# 独立SyntaxFlow功能？IRify，启动！

日期: 2025-03-28 | 原文: <https://mp.weixin.qq.com/s/8p_ZqS15qczjRRQlHKfoFg>

（饿梦惊醒）

（翻身）

（摸到电脑）

（尝试打开电脑学习）

（代码审计…代码扫描…）

（…ZZZ...ZZZ...)

![image](static/7305358d1ae2195f.gif)

![image](static/f31ca1194c1ad992.png)

![image](static/cc4140a34fa94a90.png)

打开IRify，是熟悉的项目管理页面，同Yakit一样，这里可以管理所有的项目。

![image](static/3baac000ef12a51c.png)

让我们新建一个项目，进入IRify⬇️

![image](static/8b62e897b07b0534.png)

![image](static/27e31961828d8a95.png)

也可以通过左上角进入对应页面。

![image](static/d6e587b7830019be.png)

SyntaxFlow代码审计与代码扫描前都需要先进行项目编译。

![image](static/e7072e87c78dc3f5.png)

点击左上角项目管理：

> 可见图中红色方框圈起的选项

编译项目的选项如下（必选项为项目路径）：

![image](static/e2bcb3c5de924fa4.png)

其他额外参数等都非必填。

直接点击首页开始审计或代码扫描，也可进行快捷编译：

![image](static/6e5fa4104d829920.png)

![image](static/e78f696c7877b678.png)

点击代码审计-编译项目：

![image](static/502ffe52db99f076.png)

![image](static/d3de261fd44a34b7.png)

点击代码扫描，右侧可以直接上传文件快捷编译

![image](static/3564f04328e2c6a2.png)

![image](static/2694ad87bcb8e0b1.png)

在**项目管理**页面中，可以看到已编译项目列表，将会显示已编译项目的名称、路径、编译时间和相关操作。可以进行该项目的打开、扫描以及项目删除等操作

![image](static/24d2d6610cca41d1.png)

![image](static/621ff9456cc8bf7a.png)

通过左上角或首页的按钮，我们先进入代码审计页面：

![image](static/bd8d81e8d0bae122.png)

在左侧**文件列表**和右侧**打开已有项目**、**最近打开中**都可以打开已编译的项目，将会跳转至代码审计页面。

可以检查文件内容，但这些已经编译的项目文件内容是只读的。

![image](static/fd50e87be1614074.png)

![image](static/61651a34cb2f0657.png)

在左侧侧边栏中可以看到代码审计选项， 点开以后可以发现编写审计规则的窗口：

![image](static/d542e05470e8f576.png)

![image](static/3e2e67f378edf2f6.png)

每一次查询都会得到一个变量列表，如同上文所示，在SyntaxFlow规则中定名的变量都会在结果中列出。

点开变量名将会展示该变量内保存的所有结果，点击查看其中的某一项结果，YakRunner将会展开以下结构，编辑器将会跳转到该结果对应的源码位置：

![image](static/849c59f1e1ded5c3.png)

### 审计结果：分析路径

在右侧上半部分审计结果将会展示获得该结果的所有分析路径。

默认展开路径信息。

![image](static/ef480af0935fa798.png)

- 可以继续点击获得每一个路径节点对应的源码信息。

- 点击右侧信息也可以直接在编辑器跳转。
- 点击右上角为关闭详细信息或对路径进行折叠。

![image](static/8fb1d314722c2fc2.png)

### 审计结果：分析图

右侧下半部分将会展示分析过程的图：

紫色节点代表当前结果，其他的普通节点代表分析过程中的节点。

![image](static/b7d839c47f601427.png)

普通节点可以点击并且显示节点信息，点击文件路径可以在编辑器跳转：

![image](static/11f5092b0cbec875.png)

![image](static/c6a4f16a5f1e0c8a.png)

![image](static/e5c9c7c2f281b480.png)

首页和左上角均可进入代码扫描页面

![image](static/c8c1eae8ab1a7aba.png)

导入新项目或选择已有项目后，再勾选左边规则，即可开始代码扫描。

![image](static/0607ab00a0873b13.png)

![image](static/7c40f47bd2b89563.png)

扫描过程中，可以看到已选规则、风险统计、扫描进度等信息。

风险与漏洞列表中可以进行删除、在代码审计中打开、误报上传等操作。

![image](static/4ecbab5ea83d96a9.png)

扫描结果可以从左上角进入数据库查看

![image](static/ede8fe06a22dba3c.png)

![image](static/e9228456622fe430.png)

IRify具有独立的规则管理页面，能够查看本地数据库中已经存在的规则，且支持组名与关键词搜索，右上角可进行规则的增删、导入导出等操作：

![image](static/ee53b1f3e0f2ff2e.png)

![image](static/a92603335a29223d.png)

![image](static/6755dd694067ea49.png)

![image](static/60e0c87159e04bb4.png)

作为专精代码审计的独立软件，IRify使得用户从此不必打开Yakit，可以精准使用SyntaxFlow技术进行代码审计操作。

并且不同于ssa.to的线上轻量级代码审计，大文件在IRify中也能够轻松梭哈。

IRify还能够适配多种操作系统：

![image](static/57fe6f21a4f59af1.png)

**下载指路：https://yaklang.com/irify**

欢迎体验！
