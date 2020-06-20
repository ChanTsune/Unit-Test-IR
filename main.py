import sys
import UTIR
from UTIR import ast
from UTIR import serializer
from UTIR import dumper
from UTIR import generator


def main(argv):
    if len(argv) < 1:
        return
    generate_ast_main(argv)


def generate_ast_main(argv):
    from UTIR.reader import SourceReader
    from UTIR.converter import PyAST2IRASTConverter
    from UTIR.loader import YamlLoader
    from UTIR.deserializer import ASTDeserializer
    # ソースコードの読み込み
    reader = SourceReader()
    python_ast =  reader.readf(argv[1])

    # ASTを中間表現ASTに変換
    converter = PyAST2IRASTConverter()
    ir_ast = converter.convert(python_ast)

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
    print(loaded_ir_ast.dump())
    print(test_suite.dump())


def generate_code_main(argv):
    import ast as py_ast
    a = """
a = 1
a = 4
a += 1
print(a)
    """
    target_ast = py_ast.parse(a)
    ast_generator = generator.PyASTToCodeGenerator()
    code = ast_generator.generate(target_ast)
    print(code)


if __name__ == "__main__":
    main(sys.argv)
