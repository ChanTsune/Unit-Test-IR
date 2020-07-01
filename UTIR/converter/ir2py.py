import ast as py_ast
from UTIR import ast as ir_ast


class IRAST2PyASTConverter:
    def convert(self, ir):
        return self.map_expression(ir)

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
        elif isinstance(ir, ir_ast.AssignExpression):
            return py_ast.Assign(
                targets=[self.map_expression(ir.target)],
                value=self.map_expression(ir.value),
            )
        elif isinstance(ir, ir_ast.Name):
            return py_ast.Name(id=ir.name)
        elif isinstance(ir, ir_ast.Value):
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
                keywords=[py_ast.keyword(arg=k,value=self.map_expression(v)) for k,v in ir.kwargs.items()],
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
                    ## TODO: Message ir.message
                    ],
                keywords=[],
            )
        )
