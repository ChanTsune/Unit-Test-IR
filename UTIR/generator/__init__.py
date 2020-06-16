import ast
import astor


class PyASTToCodeGenerator:

    def generate(self, py_ast):
        return astor.to_source(py_ast)
