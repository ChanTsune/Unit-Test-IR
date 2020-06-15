import sys
import UTIR
from UTIR import ast
from UTIR import serializer
from UTIR import dumper


def main(argv):
    pass


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
