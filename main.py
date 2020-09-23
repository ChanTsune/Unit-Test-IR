import sys
from UTIR import ast
from UTIR import serializer
from UTIR import dumper
from UTIR import generator
from UTIR.transformer import DefaultIRTransformer


class MyIRTransformer(DefaultIRTransformer):

    def is_target_class(self, node):
        return False


def main(argv):
    if len(argv) <= 1:
        return
    _main(argv)


def _main(argv):
    from UTIR import Code2IR, IR2Code
    from UTIR.dumper import JsonDumper
    from transformers import MyTransformer

    class MyCode2IR(Code2IR):
        py_ast_transformer_classes = [MyTransformer]
        ir_ast_transformer_classes = [MyIRTransformer]
        ir_ast_dumper_class = JsonDumper

    code2ir = MyCode2IR()
    ir2code = IR2Code()

    code2ir.convert(argv[1], argv[2])
    # ir2code.convert(argv[2], '')


if __name__ == "__main__":
    main(sys.argv)
