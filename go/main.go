package main

import (
	"bytes"
	"flag"
	"fmt"
	"go/ast"
	"go/format"
	"go/parser"
	"go/token"
	"io/ioutil"
	"os"

	"golang.org/x/tools/go/ast/astutil"
)

func main() {
	flag.Parse()
	if n := flag.NArg(); n <= 1 {
		fmt.Println("few args", n, "must be bigger than 2")
		os.Exit(1)
	}
	src, err := ioutil.ReadFile(flag.Arg(0))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	// ソースファイル群を表すデータの作成
	// ソースファイルデータにはファイル名やファイル内の構文の位置などの情報を持つ
	// たとえばパッケージ単位でコードの解析を行う場合は同一ディレクトリのソースファイルをまとめて扱う必要があるのでソースファイル群という単位でソース情報を持っているものと思われる
	fset := token.NewFileSet()
	// ソースコードを構文木に変換
	// 第二引数にファイル名を渡すとファイルを、第三引数にソースコードの文字列を渡すと文字列を変換する
	f, err := parser.ParseFile(fset, "", src, 0)
	if err != nil {
		panic(err)
	}

	// 構文木を見やすく表示する
	// 前記の構文木データはこれで表示したもの

	// ast.Print(fset, f)

	ast.Inspect(f, func(n ast.Node) bool {
		if n != nil {
			println(astutil.NodeDescription(n))
		}
		switch x := n.(type) {
		case *ast.Field:
			print("const %s = 1\n", x.Names)
		}
		return true
	})

	ioutil.WriteFile(flag.Arg(1), []byte(NodeToCode(f)), 0666) // 0666 is file permission
}

// NodeToCode ...
func NodeToCode(node ast.Node) string {
	buf := new(bytes.Buffer)
	_ = format.Node(buf, token.NewFileSet(), node)
	return buf.String()
}
