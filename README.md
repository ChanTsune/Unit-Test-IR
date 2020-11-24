# Unit-Test-IR

Intermediate Representation for unit tests.


## 概要
本プロジェクトは、多言語向けフレームワーク、既存ライブラリの多言語向けへの移植等のユニットテストの記述コストを削減することを目的としたものである。
既に作成済みのユニットテストのコードを中間表現を経由し移植先の言語に変換することでユニットテストの記述にかかるコストの削減を試みる。


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

また、ツールを利用する際、ツールを利用するための環境構築の時間は含めないものとする。
理由は、ツールを利用するにあたってツールには特殊な機構を利用しているわけではなく各言語の標準的なパッケージマネージャーで利用可能な状態で配布を行うからである。

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

#### セットアップ

`.env` ファイルを作成して以下を記述
```
INPUT=sample_data/string_test.py
OUTPUT=sample_data/test_sample.yaml
```
#### 実行

```
docker-compose up
```

`sample_data/`ディレクトリ下に各言語のテストファイルが生成されるので、生成後のファイルを後述の各環境向けのセットアップを参照してファイルを配置。

### 2. 手動で別の言語に書き直してもらう場合

`sample_data/string_tests.py` を 手動で別の言語に書き直してもらう。

## 環境構築

### Docker
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

## Kotlin向け環境構築

`intellij idea`をインストール  

テスト対象のライブラリをクローン  
```bash
git clone https://github.com/ChanTsune/ktPyString.git
```

`intellij idea`でテスト対象のライブラリのプロジェクトを開く。  

`src/test/kotlin/ktPyString`ディレクトリ下に手動、または同梱のツールを利用して生成したファイルを配置

### テストの実行
`intellij idea`内で実行

もしくはプロジェクトルートで

windows
```
./gradle.bat test
```

MacOS or Linux
```
./gradlew test
```


## Swift向け環境構築

`XCode`をインストール(XCode11以上推奨)

テスト対象のライブラリをクローン
```bash
git clone https://github.com/ChanTsune/SwiftyPyString.git
```

`XCode`でテスト対象のライブラリのプロジェクトを開く。

`Tests/SwiftyPyStringTests`ディレクトリ下に手動、または同梱のツールを利用して生成したファイルを配置

`Tests/SwiftyPyStringTests/XCTestManifests.swift`ファイルに作成したテストクラスを追記
```swift
import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EmptyStringTests.allTests),
        testCase(FormatComplexTests.allTests),
        testCase(FormatFloatingPointTests.allTests),
        testCase(FormatIntegerTests.allTests),
        testCase(FormatStringTests.allTests),
        testCase(FormatTests.allTests),
        testCase(SliceTests.allTests),
        testCase(SwiftyPyStringTests.allTests),
        testCase(テストクラス名.allTests), // 追記
    ]
}
#endif
```

### テストの実行
XCode内で実行  

もしくはプロジェクトルートで
```bash
swift test
```

## OCaml向け環境構築

`opam2`をインストール

`opam2`インストール後に`OCaml4.09.1`環境の作成
```bash
opam switch create 4.09.1
```

`dune` `ounit2`をインストール
```bash
opam install dune ounit2
```

テスト対象のライブラリをクローン
```bash
git clone https://github.com/ChanTsune/mlpystring.git
```

任意のエディタでテスト対象のライブラリのディレクトリを開く

`test`ディレクトリ下に手動、または同梱のツールを利用して生成したファイルを配置


`test/test.ml`にテストスイートを追記
```ocmal
open OUnit2

let suite = "suite" >::: [
    String_test.tests;
    Operator_test.tests;
    Slice_test.tests;
    ファイル名.baseTest; (* 追記 *)
  ]

let () = run_test_tt_main suite;;
```

### テストの実行
プロジェクトルートで
```bash
dune runtest
```
を実行

## 実験に協力してくれた皆様へ

まずは、実験へのご協力ありがとうございます。

実験で計測した時間、手動で作成したファイル、手直ししたファイルをSlackにDM等で送っていただけると助かります。
