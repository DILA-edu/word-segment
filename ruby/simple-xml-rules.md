# CBETA XML 簡化版 格式說明

## Character Encoding

UTF-8

## 簡化版的 Elements

### ab

* `<ab type="prose">` 散文 (原多個 p 合成一個 ab)
* `<ab type="verse">` 韻文(偈頌, 原 `<lg>`)
* `<ab type="dharani">` 咒語 (原 `<p type="dharani">`)
* `<ab type="table">`, `<ab type="row">`, `<ab type="cell">` 例如 T49n2035
* `<ab type="form">` 原 `<form>`

#### list

`<ab type="list">` (原 XML `<list>`, ex: T08n0225)

巢狀 List ex: T10n0293

    <ab type='list'>
    大藏經局刊字作頭
    　作頭何囦
    　作頭范山
    大藏經局措置梨板勾當
    　勾當僧明秀
    　勾當僧明達
    ....
    </ab>

### body

### byline

### div

* 保留 type 屬性, 加 level 屬性
* 如果 body 下有多個 div, 就在最外層再包一個 `<div level=”1”>`
* `<div type=”w”>`, `<div type=”xu”>` 都保留

### head

### juan

* `<juan fun="open">…</juan>` 轉為 `<ab type="juan" subtype="open">`
* `<juan fun="close">…</juan> 轉為 <ab type="juan" subtype="close">`

### trailer

內容及標記均不轉出

## 雙行對照

ex: T10n0299_p0892c01

    「na　maḥ　sa　maṃ　ta　va　dra　ya　vo　
    曩　莫　三　滿　多　跋　捺囉　野　冒　
    dhi　sa　tvā　ya　ma　hā　sa　tvā　
    地　薩　怛嚩　野　麼　賀　薩　怛嚩　
    ya　sa　hā　kā　ru　ṇi　kā　ya　ta　
    野　麼　賀　迦　嚕　抳　迦　野　怛　
    dya　thā　oṃ　va　ra　ṭi　va　ra　
    儞也　他　唵　婆　囉　胝　婆　囉　
    ṭi　va　ra　va　ra　ti　sā　hā　
    胝　婆　囉　婆　冷　帝　薩嚩　賀」

## 特字

`<g>` 改為 Unicode PUA 字元，例如 `<g ref="#CB02596"/>` 轉為 `&#xF0A24;`。

## 去除 tag

`<div type=”other”>` 標記去除, 但是內容保留.

## 去除元素

back, docNumber, lb, mulu, note, pb sic, teiHeader
