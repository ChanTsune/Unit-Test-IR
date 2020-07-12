import sys

for i in sys.path:
    if i.endswith('example'):
        sys.path.append("/".join(i.split('/')[:-1]))


def main(argv):
    if len(argv) < 1:
        return
    _main(argv)


def _main(argv):
    from UTIR import Code2IR, IR2Code
    from transformers import MyTransformer

    class MyCode2IR(Code2IR):
        py_ast_transformer_classes = [MyTransformer]
    code2ir = MyCode2IR

    code2ir.convert(argv[1], argv[2])

    ir2code = IR2Code

    ir2code.convert(argv[2], '')


if __name__ == "__main__":
    import sys
    main(sys.argv)
