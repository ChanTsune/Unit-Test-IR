# Unit-Test-IR

Intermediate Representation for unit tests.


## 概要
本プロジェクトは、多言語向けフレームワーク、既存ライブラリの多言語向けへの移植等のユニットテストの記述コストを削減することを目的としたものである。
既に作成済みのユニットテストのコードを中間表現を経由し移植先の言語に変換することでユニットテストの記述にかかるコストの削減を試みる。


## セットアップ

Dockerのインストールが必須。
あとはKotlin,Swift,OCamlのうち一つを選んでIED等をインストール。

### Docker(必須)

- Windowsを利用する場合(wsl2が利用できる場合)
Docker for windowsをインストール
`docker`,`docker-compose`コマンドが利用できることを確認

- Windowsを利用する場合(wsl2が利用できない場合)
VirtualBoxをインストール
Docker tool box をインストール
`docker`,`docker-compose`コマンドが利用できることを確認

- MacOSを利用する場合
Docker,docker-composeをインストール
```
brew cask install docker
brew install docker-compose
```

Dockerのインストールか完了したら、プロジェクトルートで以下を実行

```
make world
```
### Kotlin - intellij idea(任意)

Kotlinを利用する場合はIDEとして`intellij idea`の利用を推奨します。

### Swift - Xcode(任意)

Swiftを利用する場合はIDEとして`Xcode`の利用を推奨します。

### OCaml(任意)

OCamlは特に推奨のエディタ等はありません

## 実験シナリオ

この実験では拙作のPythonの文字列操作メソッドを他言語に移植したライブラリ
[ktPyString](https://github.com/ChanTsune/ktPyString),
[SwiftyPyString](https://github.com/ChanTsune/SwiftyPyString),
[mlpystring](https://github.com/ChanTsune/mlpystring),
を対象にCPythonの文字列に対して行っているテストから一部を抜粋したもの(`sample_data/string_tests.py`)を利用する。

Kotlin,Swift,OCamlのうち一つを選んでいただき次の実験を行う。


1. 中間表現を利用する場合(ツールを利用)
2. 手動で別の言語に書き直してもらう場合

それぞれにかかった時間を計測し、より短い時間で完成したほうを良いものとする。
ただし、同一人物が同一のコードを利用して検証を行った場合、二度目に行う方が良い結果が得られると思うので(一度書いたことのあるコードを再度書くことになるので)、
数人に対して実験に協力してもらいその際、1と2の順番を入れ替えて計測を行う。

また、*テスト対象のライブラリの都合一部の関数、例外は実装されていない場合があるのでその場合はその項目を飛ばして行う*ものとする。

手動で書き直してもらうケースでは既存のエディタやIDEの機能の利用はできるものとする。
理由は、既にあるものと比較した際どれほどの時間削減効果が見込めるかを図るためである。

## 計測条件
1. 生成されたコードの手直しにかかる時間の計測
2. 手動で書き直すのにかかる時間の計測

- テストコードの記述にかかる時間のみを計測するものとする(環境構築にかかる時間等は含めないものとする)  
- 計測時間はどちらも分単位とする  
- どちらもコンパイルが完了した時点で計測終了とする  
(ライブラリがPython完全準拠ではないのでおそらく一部のテストケースが通過しないので)

### 1. 中間表現を利用する場合

`sample_data/string_tests.py` に対して同梱のツールを利用し 中間表現を経由して生成した移植先の言語のテストファイルをコンパイルが通るところまで手直ししてもらう。

#### 中間表現コードの生成と自動変換コードの生成

```bash
docker-compose up
```

`sample_data/`ディレクトリ下に中間表現ファイル(`string_tests.yaml`)が吐き出されていることを確認。

Dockerコンテナの実行順序が制御できない都合、中間表現ファイルの生成前に変換先コードの生成が実行されてしまう場合があるのでその場合は再度上記コマンドを実行。

#### 手直し

Kotlinの場合は`test_env/ktPyString/src/test/kotlin/ktPyString/AutoGenerate.kt`ファイル  
Swiftの場合は`test_env/SwiftyPyString/Tests/SwiftyPyStringTests/AutoGenerate.swift`ファイル  
OCamlの場合は`test_env/mlpystring/test/AutoGenerate.ml`ファイル  

をそれぞれコンパイルが通るように手直しする。

コンパイルはそれぞれ
Kotlinの場合は`test_env/ktPyString/`ディレクトリ  
Swiftの場合は`test_env/SwiftyPyString/`ディレクトリ  
OCamlの場合は`test_env/mlpystring/`ディレクトリ  
で
```bash
docker-compose up
```
を実行

#### 

### 2. 手動で別の言語に書き直してもらう場合

`sample_data/string_tests.py` を 手動で別の言語に書き直してもらう。

#### Kotlinを選んだ場合

`test_env/ktPyString/src/test/kotlin/ktPyString/Handwritten.kt`ファイルに`sample_data/string_tests.py`のテストケースをkotlinコードとして書き直す。

*コードを書き直す際、強力なコード補完が効くため`intellij idea`の利用を推奨。*

##### 実行
`test_env/ktPyString`ディレクトリで

```bash
docker-compose up
```

#### Swiftを選んだ場合

`test_env/SwiftyPyString/Tests/SwiftyPyStringTests/Handwritten.swift`ファイルに`sample_data/string_tests.py`のテストケースをSwiftコードとして書き直す。

##### 実行

`test_env/SwiftyPyString`ディレクトリで

```bash
docker-compose up
```

#### OCamlを選んだ場合

`test_env/mlpystring/test/Handwritten.ml`ファイルに`sample_data/string_tests.py`のテストケースをOCamlコードとして書き直す。

##### 実行

`test_env/mlpytring`ディレクトリで

```bash
docker-compose up
```

## 実験に協力していただいた皆様へ

まずは、実験へのご協力ありがとうございます。

実験で計測した時間、手動で作成したファイル、手直ししたファイルをSlackにDM等で送っていただけると助かります。
