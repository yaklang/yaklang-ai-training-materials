
## 案例: 使用 `xpath.Find` 来查询 HTML 节点 {#find}

在使用查询 API 之前，我们需要通过 `xpath.LoadHTMLDocument` 来生成一个 HTML 可操作文档，然后把文档的实例传递给其他的查询参数获取内容。

```
doc, err := xpath.LoadHTMLDocument(`
<!DOCTYPE html><html lang="en-US">
<head>
<title>Hello,World!</title>
</head>
<body>
<div class="container">
<header>
	<!-- Logo -->
   <h1>City Gallery</h1>
</header>  
<nav>
  <ul>
    <li><a href="/London">London</a></li>
    <li><a href="/Paris">Paris</a></li>
    <li><a href="/Tokyo">Tokyo</a></li>
  </ul>
</nav>
<article>
  <h1>London</h1>
  <img src="pic_mountain.jpg" alt="Mountain View" style="width:304px;height:228px;">
  <p>London is the capital city of England. It is the most populous city in the  United Kingdom, with a metropolitan area of over 13 million inhabitants.</p>
  <p>Standing on the River Thames, London has been a major settlement for two millennia, its history going back to its founding by the Romans, who named it Londinium.</p>
</article>
<footer>Copyright &copy; W3Schools.com</footer>
</div>
</body>
</html>
`)
die(err)

nodes := xpath.Find(doc, "//p")
for _, node := range nodes {
    println(xpath.InnerText(node))
}
```