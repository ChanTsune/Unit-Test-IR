import ast
import astor
from . import ast as ir_ast


def generate_python_code_from_utir_ast(ir_ast):
    return astor.to_source(ir_ast.to_py_ast())
