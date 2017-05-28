文字Ngram実行コマンド(nは1〜5の自然数)

```
ruby char_gram.rb n
```

単語Ngram実行コマンド(nは1〜3の自然数)

```
ruby word_gram.rb n -F "%f[6]\n"
```

文字Ngramの結果はresult-characterに保存される。

単語Ngramの結果はresult-wordに保存される。

デフォルトだと100件のデータ(../data/¥*¥*)を処理するようになっているので、10000件のデータ(../Wikipedia/¥*¥*)を処理する場合は MyFile.rb 3行目の data を Wikipedia に変更する。
