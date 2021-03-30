# DILA佛典分詞語料暨自動分詞工具

# 簡介


本語料集為法鼓文理學院所建置之基於CBETA佛教文獻之分詞語料，其包含經過人工標注之佛典分詞語料，以及利用該分詞語料所訓練出之自動分詞工具，並將此自動分詞之工具對於全部之CBETA文本進行分詞之結果。

其自動分詞工具之方法，基於條件隨機域 (Conditional Random Field, CRF)模型，使用CRF++ 0.5.8進行訓練而得。其模型之實作細節及分詞正確率，可參閱如下論文：
- Yu-Chun Wang (2020). Word Segmentation for Classical Chinese Buddhist Literature. *Journal of the Japanese Association for Digital Humanities*, 5(2), 154-172.

# 目錄架構


## training_corpus
人工標注之分詞語料

## word-segmented-cbeta
將 CBETA 全部典籍全部自動分詞，提供兩種格式:

* word-segmented-cbeta 資料夾
  * seged-taf 資料夾： TAFxml 格式 (Text Analysis Friendly)
  * seged-txt 資料夾： 純文字格式

缺字使用 Unicode PUA.

## ruby

自動分詞 Ruby 程式, 請看 [ruby/README.md](ruby/README.md)
