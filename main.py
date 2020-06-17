import sys
import UTIR
from UTIR import ast
from UTIR import serializer
from UTIR import dumper
from UTIR import generator


def main(argv):
    if len(argv) < 1:
        return
    generate_code_main(argv)

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


def serialize_main(argv):
    if len(argv) < 1:
        return
    test_suite = ast.TestSuite("Sample", [], [])
    ast_serializer = serializer.ASTSerializer()
    object = ast_serializer.serialize(test_suite)
    object_dumper = dumper.Dumper()
    object_dumper.dumpf(argv[1], object)


if __name__ == "__main__":
    main(sys.argv)