# 超级牛哭诉常年被认错，Yaklang和Yakit有哪些区别

日期: 2024-09-14 | 原文: <https://mp.weixin.qq.com/s/c9lwOLk4jWDNJ3yTVp5Fww>

天命人们大家好

黑猴大家都通关了吗

这里是一觉睡醒要再上30+年班的超级马喽牛

![image](static/c447e71255fa351b.png)

先提前祝大家[中秋快乐](http://mp.weixin.qq.com/s?__biz=Mzk0MTM4NzIxMQ==&mid=2247521342&idx=1&sn=04d08f4920279e5c620c5c7e9138d803&chksm=c2d1e89af5a6618ceb0508c384d662f79fbcf992e0a36f9d74e25ce62ec9d66b1eea023b7fa9&scene=21#wechat_redirect)

经常有小伙伴问

“Yakit怎么报错了？”

“YAK和Yakit有什么区别？”

牛牛委屈

无能狂怒（标题致歉，封面致歉，ooc致歉

今天的文章，就来为大家集中解答一波

![image](static/26bb17ffc74df66b.png)

![image](static/eea61b6bdb934c3b.png)

![image](static/f5501faa9535545c.png)

![image](static/58ad2437ea2d5c20.png)

Yaklang是一种**专为网络安全领域设计的领域特定编程语言**。其目标在于解决安全产品整合过程中所面临的技术挑战，例如不同产品之间的互操作性问题以及安全工具开发过程中的效率和一致性问题。作为一门编程语言，Yaklang能够**独立**完成多项复杂且高级的任务，包括启动中间人攻击、发送HTTP原始报文和编写复杂的POC等。

![image](static/63edb6f3a07cc5d0.png)

Yakit是官方的Yaklang**图形化客户端**，绝大多数用户通常接触的软件就是Yakit。实际上，Yakit可以被视为一个精致的“盒子”，其主要目的是为大部分用户提供便利，帮助他们更有效地使用Yaklang。

![image](static/7a7b1a6b587a9447.png)

在最初，**Yaklang**最先出现，它作为一门专门为网络安全领域设计的领域特定编程语言，可以通过编程来完成许多复杂的任务，但是这也带来了一部分的**门槛**，即用户需要重新学习一门语言，哪怕这门语言的语法非常的直观，易于学习，对于大部分用户来说依然不够简便。

为了解决这个问题，**Yakit**出现了。**Yakit**是**Yaklang**的图形化客户端，其旨在降低用户的学习门槛，提高效率。Yakit通过直观的图形界面，使得用户能够通过简单的方式去执行复杂的功能模块，测试相关的网站/APP等。

![image](static/ada671bae09aa05d.png)

Yakit与Yaklang是基于CS(Client/Server,客户端/服务器模式)架构的,而它们之间的通信则是通过**gRPC**进行的。

gRPC是由Google开发的一种高性能、开源且通用的远程过程调用（RPC）框架。该框架基于HTTP/2协议，并采用Protocol Buffers（protobuf）作为接口定义语言（IDL），从而实现不同编程语言之间的高效通信与交互。

在设计过程中，gRPC充分考虑了向后兼容性，尤其是在使用Protocol Buffers时，提供了良好的版本管理机制。良好的兼容性确保了不同版本之间添加字段或接口不会影响通信流程。**这也是为何我们能够使用旧版的Yakit连接新版的Yaklang，或反之亦然的原因。**

![image](static/af96b910933f5d5b.png)

在我们正常启动Yakit时，我们会自动进入最近使用的模式（一般是本地模式），如：

![image](static/5a4e1db5acb564d6.png)

得益于Yakit与Yaklang的通信方式（基于CS架构），我们可以通过远程模式来连接Yaklang引擎，远程模式可以在项目管理界面的左下角切换：

![image](static/98dec93575f51bfa.png)

或在连上项目后**设置-切换连接模式-远程**进行切换：

![image](static/aea32ae42054d773.png)

之后，我们可以使用命令:

```swift
yak grpc --host 0.0.0.0 --port 8888
```

来启动一个gRPC服务器，以便使用Yakit使用：

![image](static/75d8d09e537a1883.png)

接下来，我们就可以在远程模式中轻松地进行连接：

![image](static/bd2902f90a2becd0.png)

![image](static/5e578e2467979aa6.png)

在了解Yakit与Yaklang的定义及其区别之后，用户再面对类似的**UNIMPLEMENTED**错误就知道如何解决了，即通过升级Yakit和Yaklang版本来解决此问题。为确保获得更佳的使用体验，**建议同时更新这两者。**
