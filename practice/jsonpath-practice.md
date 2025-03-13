## JsonPath 是什么？

JsonPath 是一种用于从 JSON 数据中提取数据的查询语言，类似于 XML 的 XPath。它允许你使用路径表达式来导航和选择 JSON 文档中的特定元素。

## 基本语法

在 Yak 语言中，JsonPath 通过 `json.Find` 函数实现，该函数接受两个参数：一个 JSON 对象和一个 JsonPath 表达式。

```yak
result = json.Find(jsonObject, "jsonPathExpression")
```

## JsonPath 表达式元素

| 表达式 | 描述 |
|-------|------|
| `$` | 根对象 |
| `.` | 子元素操作符 |
| `..` | 递归下降操作符（在所有层级中搜索） |
| `*` | 通配符（所有对象或元素） |
| `[]` | 数组下标操作符 |
| `[start:end]` | 数组切片操作符 |
| `[-n:]` | 获取数组最后 n 个元素 |

## 常用表达式示例

### 1. 基本路径访问 (`$.property`)

使用点表示法访问对象的属性。

```yak
// 示例：获取 store 对象中的 bicycle 属性
bicycle = json.Find(obj, "$.store.bicycle")
```

### 2. 递归搜索 (`$..property`)

在 JSON 的所有层级中搜索指定属性。

```yak
// 示例：获取所有名为 "name" 的属性值
names = json.Find(obj, "$..name")
```

如案例1所示：
```yak
result = json.Find(obj, "$..name")
// 结果: ["Bob", "Alice"]
```

### 3. 数组访问 (`$[index]`)

通过索引访问数组中的特定元素。

```yak
// 示例：获取 people 数组中第一个元素
firstPerson = json.Find(obj, "$.people[0]")
```

如案例3所示：
```yak
first = json.Find(obj, "$.people[0].name")
// 结果: "John"
```

### 3. 数组访问 (`$[index]`)

通过索引访问数组中的特定元素。

```yak
// 示例：获取 people 数组中第一个元素
firstPerson = json.Find(obj, "$.people[0]")
```

### 4. 数组切片 (`$[start:end]`)

获取数组的一个子集。

```yak
// 示例：获取 people 数组中前两个元素
firstTwoPeople = json.Find(obj, "$.people[0:2]")
```


### 5. 通配符 (`*`)

匹配所有对象或数组元素。

```yak
// 示例：获取所有书籍的所有属性
allBookProps = json.Find(obj, "$.store.book[*].*")
```


## 案例1：基本的递归查询

```yak
obj = {
    "abc": 1,
    "items": [
        { "name": "Bob", "age": 12 },
        { "name": "Alice", "age": 18 }
    ]
}

// 使用递归下降操作符 ".." 在所有层级中查找名为 "name" 的属性
// 这会搜索整个 JSON 对象，无论嵌套多深
result = json.Find(obj, "$..name")
dump(result)
/*
OUTPUT:

([]interface {}) (len=2 cap=2) {
 (string) (len=3) "Bob",    // 第一个匹配项，来自 items[0].name
 (string) (len=5) "Alice"   // 第二个匹配项，来自 items[1].name
}
*/

```

## 案例2：访问嵌套数组中的特定属性

```yak
obj = {
    "store": {
        "book": [
            {
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            },
            {
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            }
        ],
        "bicycle": {
            "color": "red",
            "price": 19.95
        }
    }
}

// 获取所有书籍的作者
// $.store.book[*].author 表示:
// $ - 根对象
// .store - store 属性
// .book - book 数组
// [*] - 数组中的所有元素
// .author - 每个元素的 author 属性
authors = json.Find(obj, "$.store.book[*].author")
dump(authors)
/*
OUTPUT:
([]interface {}) (len=2 cap=2) {
 (string) (len=11) "Nigel Rees",   // 第一本书的作者
 (string) (len=12) "Evelyn Waugh"  // 第二本书的作者
}
*/


*/

```

## Case3：数组索引和切片操作

```yak
obj = {
    "people": [
        {"name": "John", "age": 25},
        {"name": "Jane", "age": 24},
        {"name": "Mark", "age": 30},
        {"name": "Sara", "age": 28}
    ]
}

// 获取第一个人的名字
// 使用索引 [0] 访问数组中的第一个元素
first = json.Find(obj, "$.people[0].name")
dump(first)
/*
OUTPUT:

(string) (len=4) "John"  // 返回单个字符串，而不是数组，因为只有一个匹配项
*/

// 获取前两个人的名字
// 使用数组切片 [0:2] 获取索引从 0 到 1 的元素（不包括索引 2）
firstTwo = json.Find(obj, "$.people[0:2].name")
dump(firstTwo)
/*
OUTPUT:

([]interface {}) (len=2 cap=2) {
 (string) (len=4) "John",  // 第一个人的名字
 (string) (len=4) "Jane"   // 第二个人的名字
}
*/

```

## case4：复杂的递归查询和多层嵌套

```yak
obj = {
    "menu": {
        "id": "file",
        "value": "File",
        "popup": {
            "menuitem": [
                {"value": "New", "onclick": "CreateNewDoc()"},
                {"value": "Open", "onclick": "OpenDoc()"},
                {"value": "Close", "onclick": "CloseDoc()"}
            ]
        },
        "submenu": {
            "menuitem": [
                {"value": "Save", "onclick": "SaveDoc()"}
            ]
        }
    }
}

// 获取所有 menuitem 数组
// $..menuitem 表示在整个 JSON 对象中递归查找所有名为 "menuitem" 的属性
// 这会返回两个数组：一个来自 popup，一个来自 submenu
allMenuItems = json.Find(obj, "$..menuitem")
dump(allMenuItems)
/*
OUTPUT:

([]interface {}) (len=2 cap=2) {
 ([]interface {}) (len=3 cap=4) {  // 第一个匹配项：popup.menuitem 数组
  (map[string]interface {}) (len=2) {
   (string) (len=7) "onclick": (string) (len=14) "CreateNewDoc()",
   (string) (len=5) "value": (string) (len=3) "New"
  },
  (map[string]interface {}) (len=2) {
   (string) (len=5) "value": (string) (len=4) "Open",
   (string) (len=7) "onclick": (string) (len=9) "OpenDoc()"
  },
  (map[string]interface {}) (len=2) {
   (string) (len=7) "onclick": (string) (len=10) "CloseDoc()",
   (string) (len=5) "value": (string) (len=5) "Close"
  }
 },
 ([]interface {}) (len=1 cap=1) {  // 第二个匹配项：submenu.menuitem 数组
  (map[string]interface {}) (len=2) {
   (string) (len=7) "onclick": (string) (len=9) "SaveDoc()",
   (string) (len=5) "value": (string) (len=4) "Save"
  }
 }
}
*/

// 获取所有 value 字段
// $..value 表示在整个 JSON 对象中递归查找所有名为 "value" 的属性
// 这会找到所有层级中的 value 属性值
allValues = json.Find(obj, "$..value")
dump(allValues)
/*
OUTPUT:

([]interface {}) (len=5 cap=8) {
 (string) (len=4) "File",  // menu.value
 (string) (len=3) "New",   // menu.popup.menuitem[0].value
 (string) (len=4) "Open",  // menu.popup.menuitem[1].value
 (string) (len=5) "Close", // menu.popup.menuitem[2].value
 (string) (len=4) "Save"   // menu.submenu.menuitem[0].value
}
*/

```

## case5：数组负索引和切片高级用法

```yak
obj = {
    "teams": [
        {"name": "Team A", "members": ["John", "Alice", "Bob"]},
        {"name": "Team B", "members": ["Carol", "Dave"]},
        {"name": "Team C", "members": ["Eve", "Frank", "Grace", "Helen"]}
    ]
}

// 获取每个团队的最后一个成员
// $.teams[*].members[-1:] 表示:
// $ - 根对象
// .teams - teams 数组
// [*] - 数组中的所有元素
// .members - 每个团队的 members 数组
// [-1:] - 每个 members 数组的最后一个元素（负索引表示从末尾开始计数）
lastMembers = json.Find(obj, "$.teams[*].members[-1:]")
dump(lastMembers)
/*
OUTPUT:

([]interface {}) (len=3 cap=4) {
 (string) (len=3) "Bob",    // Team A 的最后一个成员
 (string) (len=4) "Dave",   // Team B 的最后一个成员
 (string) (len=5) "Helen"   // Team C 的最后一个成员
}
*/

```
