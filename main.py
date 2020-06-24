import sys
import UTIR
from UTIR import ast
from UTIR import serializer
from UTIR import dumper
from UTIR import generator
from UTIR.visitor import NodeVisitor


class SampleVisitor(NodeVisitor):

    def visit(self, node):
        print("pre", type(node))
        super().visit(node)
        print("post", type(node))

    def visit_Name(self, node):
        print(node.name, type(node))


def main(argv):
    if len(argv) < 1:
        return
    _main(argv)


def _main(argv):
    from UTIR import Code2IR, IR2Code
    code2ir = Code2IR
    ir2code = IR2Code

    code2ir.convert(argv[1], argv[2])
    ir2code.convert(argv[2], '')


def generate_ast_main(argv):
    from UTIR.reader import SourceReader
    from UTIR.converter import PyAST2IRASTConverter, IRAST2PyASTConverter
    from UTIR.loader import YamlLoader
    from UTIR.deserializer import ASTDeserializer
    # ソースコードの読み込み
    reader = SourceReader()
    python_ast = reader.readf(argv[1])
    # from ast import dump
    # print(dump(python_ast))
    # return

    # ASTを中間表現ASTに変換
    converter = PyAST2IRASTConverter()
    ir_ast = converter.convert(python_ast)

    visitor = SampleVisitor()
    visitor.visit(ir_ast)
    # 中間表現IRのシリアライズ
    test_suite = ir_ast
    ast_serializer = serializer.ASTSerializer()
    object = ast_serializer.serialize(test_suite)
    # 中間表現ASTの書き出し
    object_dumper = dumper.YamlDumper()
    object_dumper.dumpf(argv[2], object)

    # 中間表現ファイルの読み込み
    object_loader = YamlLoader()
    object = object_loader.loadf(argv[2])
    ast_deserializer = ASTDeserializer()
    loaded_ir_ast = ast_deserializer.deserialize(object)
    ir_to_py_comverter = IRAST2PyASTConverter()
    target_ast = ir_to_py_comverter.convert(loaded_ir_ast)
    ast_generator = generator.PyASTToCodeGenerator()
    code = ast_generator.generate(target_ast)
    print(code)


if __name__ == "__main__":
    main(sys.argv)
