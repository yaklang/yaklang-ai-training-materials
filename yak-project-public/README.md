# Yak Project 公众号知识库

本目录是 Yak Project 公众号自 2021-10 至今的技术文章导出版本，
作为 yaklang-ai-training-materials 的训练 / 检索语料。

## 内容

- **257 篇 markdown**：已经过严格的噪音清洗，剔除节日、招聘、抽奖、获奖名单、
  品牌 footer、`PART/01` 装饰、作者元信息、`**END**` 之后内容等
- **static/**：4098 张图片，按 URL 的 SHA1 哈希命名；markdown 内部统一用
  `![](static/<hash>.<ext>)` 相对路径引用
- **INDEX.md**：按日期倒序的文章索引，便于检索

## 用法

- 程序化消费：按文件名前缀（编号）排序得到时间线
- 标题与日期可从 markdown 顶部前两行解析：
  ```
  # <标题>

  > 日期：YYYY-MM-DD
  > 原文：https://mp.weixin.qq.com/...
  ```
- 图片完全本地化，搬移整个目录时务必连同 `static/` 一起带走

## 数据来源

原始处理流水线见 `discovery-worlds/公众号0513/`，包含：
- 原始 HTML 抓取与解析
- 图片去重下载（SHA1 路径哈希）
- 自定义 HTML → Markdown 渲染（保留代码块结构）
- 多层噪音过滤策略

本目录由 `scripts/06_export_to_kb.py` 一键导出生成，可幂等重跑。
