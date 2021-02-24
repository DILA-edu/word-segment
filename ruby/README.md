# 自動分詞程式

使用 [Ruby](https://www.ruby-lang.org/) 撰寫，執行前需先安裝 Ruby。

## Configuration

將 config-example.yml 複製為 config.yml，再根據環境編輯 config.yml.

## CBETA XML P5a 轉 TAFxml (Text-analysis friendly)

* 下載 [CBETA XML P5a](https://github.com/cbeta-git/xml-p5a)，並設定 config.yml 裡的 cbeta_xml_p5a 參數。
* 下載 [CBETA 缺字資料庫](https://github.com/cbeta-org/cbeta_gaiji)，並設定 config.yml 裡的 gajji 參數。
* 轉檔執行 `ruby taf.rb`
* 結果輸出到 config.yml 裡定義的 cbeta_taf_xml
* TAFxml 的格式說明及轉檔規則，請參考 [simple-xml-rules.md](simple-xml-rules.md).

## 將 TAFxml 自動分詞

* 需先安裝 [CRF++](https://taku910.github.io/crfpp/)，轉檔程式會呼叫 command line 的 crf_test 命令。
* 執行 `ruby seg-taf.rb`
* 花費時間：使用 6個 CPU, 全部 CBETA 跑完大約 2小時。
* 結果輸出到 config.yml 裡定義的 seged_taf

## 將自動分詞後的 TAFxml 轉為純文字

* 執行 `ruby x2t.rb`
* 結果輸出到 config.yml 裡定義的 seged_txt
