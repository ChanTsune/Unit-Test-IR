import ast as py_ast
from ast import NodeTransformer as PyNodeTransformer

from UTIR import ast as ir_ast


class PyAST2IRASTConverter(PyNodeTransformer):

    def visit(self, node):
        """Visit a node."""
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.visit_unsupported)
        return visitor(node)

    def visit_unsupported(self, node):
        raise Exception('Unsupported AST Object %s passed!' % node)


class PyAST2IRASTConverter:

    def convert(self, python_ast):
        return self.generic_convert(python_ast)

    def generic_convert(self, python_ast):
        """Python AST to IR AST"""
        if isinstance(python_ast, list):
            new_nodes = []
            for i in python_ast:
                node = self.generic_convert(i)
                if node is None:
                    continue
                new_nodes.append(node)
            return new_nodes

        if isinstance(python_ast, py_ast.Expr):
            python_ast = python_ast.value
        if isinstance(python_ast, py_ast.Module):
            return ir_ast.File(self.generic_convert(python_ast.body))
        elif isinstance(python_ast, py_ast.ImportFrom):
            # ignore import directive
            return None
        elif isinstance(python_ast, py_ast.FunctionDef):
            return ir_ast.FunctionDef(python_ast.name,
                                      None,  # TODO: support Kind
                                      self.generic_convert(python_ast.args),
                                      self.generic_convert(python_ast.body),
                                      None,  # return type
                                      )
        elif isinstance(python_ast, py_ast.arguments):
            arg_defs = []
            for arg in python_ast.args:
                arg_defs.append(ir_ast.ArgumentDef(arg.arg))
            # TODO: support 'args', 'defaults', 'kw_defaults', 'kwarg', 'kwonlyargs', 'vararg'
            # for arg in python_ast:
            #     pass
            return arg_defs
        elif isinstance(python_ast, py_ast.Return):
            return ir_ast.Return(self.generic_convert(python_ast.value))
        elif isinstance(python_ast, py_ast.BinOp):
            return ir_ast.Call(ir_ast.Name(python_ast.op.__class__.__name__),
                               self.generic_convert(
                                   [python_ast.left, python_ast.right]),
                               {},
                               'OPERATOR')
        elif isinstance(python_ast, py_ast.ClassDef):
            bases = self.generic_convert(python_ast.bases)
            bases = [i.name for i in bases]
            return ir_ast.ClassDef(python_ast.name,
                                   bases,
                                   [],  # TODO: support fields
                                   self.generic_convert(python_ast.body)
                                   )

        elif isinstance(python_ast, py_ast.Name):
            return ir_ast.Name(python_ast.id)
        elif isinstance(python_ast, py_ast.Attribute):
            return ir_ast.Attribute(self.generic_convert(python_ast.value), python_ast.attr)
        elif isinstance(python_ast, py_ast.Assign):
            if len(python_ast.targets) != 1:
                raise Exception('Unsupported multiple Assign')
            return ir_ast.AssignExpression(self.generic_convert(python_ast.targets[0]),
                                           self.generic_convert(python_ast.value))
        elif isinstance(python_ast, py_ast.Num):
            return ir_ast.Value('int', python_ast.n)
        elif isinstance(python_ast, py_ast.Str):
            return ir_ast.Value('string', python_ast.s)
        elif isinstance(python_ast, py_ast.Call):
            return ir_ast.Call(self.generic_convert(python_ast.func),
                               [self.generic_convert(i)
                                for i in python_ast.args],
                               {i.arg: self.generic_convert(
                                   i.value) for i in python_ast.keywords}
                               )
        elif isinstance(python_ast, py_ast.NameConstant):
            if python_ast.value == True:
                return ir_ast.Value('bool', True)
            elif python_ast.value == False:
                return ir_ast.Value('bool', False)
            elif python_ast.value == None:
                return ir_ast.Value('nil', None)
        else:
            print(dir(python_ast))
            raise Exception('Unsupported AST Object %s found!' % python_ast)
