import ast as py_ast
from UTIR import ast as ir_ast
from UTIR.transformer import NodeTransformer as IRNodeTransformer


class IRAST2PyASTConverter(IRNodeTransformer):

    def convert(self, node):
        return self.visit(node)

    def visit(self, node):
        """Visit a node."""
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.visit_unsupported)
        return visitor(node)

    def visit_File(self, node):
        return py_ast.Module(body=[
            self.visit(i) for i in node.body
        ])

    def visit_unsupported(self, node):
        print(dir(node))
        for i in node._fields:
            v = getattr(node, i)
            print('member:>', i, 'raw_value:>', v)
        raise Exception('Unsupported AST Object %s found!' % node)

    def map_expression(self, ir):
        if isinstance(ir, ir_ast.TestProject):
            return py_ast.Module(body=[
                py_ast.ImportFrom(module='unittest',
                                  names=[py_ast.alias(
                                      name='TestCase', asname=None)],
                                  level=0,
                                  ),
                py_ast.ClassDef(name=ir.name,
                                bases=[py_ast.Name(id='TestCase')],
                                keywords=[],
                                body=[self.map_expression(i)
                                      for i in ir.test_suites],
                                decorator_list=[],
                                ),
            ])
        elif isinstance(ir, ir_ast.TestSuite):
            return py_ast.FunctionDef(
                name=ir.name,
                args=py_ast.arguments(args=[py_ast.arg(arg='self', annotation=None)],
                                      vararg=None,
                                      kwonlyargs=[],
                                      kw_defaults=[],
                                      kwarg=None,
                                      defaults=[],
                                      ),
                body=[self.map_expression(i) for i in ir.expressions],
                decorator_list=[],
            )
        elif isinstance(ir, ir_ast.TestCase):
            return self.map_assert(ir)
        elif isinstance(ir, ir_ast.Assign):
            return py_ast.Assign(
                targets=[self.map_expression(ir.target)],
                value=self.map_expression(ir.value),
            )
        elif isinstance(ir, ir_ast.Name):
            return py_ast.Name(id=ir.name)
        elif isinstance(ir, ir_ast.Constant):
            if ir.kind == 'int':
                return py_ast.Num(n=ir.value)
            elif ir.kind == 'string':
                return py_ast.Str(s=ir.value)
            elif ir.kind == 'bool':
                return py_ast.NameConstant(value=ir.value)
            elif ir.kind == 'nil':
                return py_ast.NameConstant(value=None)
            else:
                raise Exception('Unsupported value kind %s' % ir.kind)
        elif isinstance(ir, ir_ast.Call):
            return py_ast.Call(
                func=self.map_expression(ir.func),
                args=[self.map_expression(i) for i in ir.args],
                keywords=[py_ast.keyword(arg=k, value=self.map_expression(
                    v)) for k, v in ir.kwargs.items()],
            )
        else:
            raise Exception('Unsupported ast type %s' % str(ir))

    def map_assert(self, ir):
        return py_ast.Expr(value=py_ast.Call(
            func=py_ast.Attribute(
                value=py_ast.Name(id='self'),
                attr='assert'+ir.assert_,
            ),
            args=[self.map_expression(ir.excepted),
                  self.map_expression(ir.actual),
                  # TODO: Message ir.message
                  ],
            keywords=[],
        )
        )
