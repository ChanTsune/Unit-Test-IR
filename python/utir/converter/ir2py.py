import ast as py_ast
from utir import ast as ir_ast
from utir.transformer import NodeTransformer as IRNodeTransformer


def isExpr(node):
    return isinstance(node, py_ast.expr)


def wrapNodes(nodes):
    return [py_ast.Expr(node) if isExpr(node) else node for node in nodes]


class IRAST2PyASTConverter(IRNodeTransformer):

    def convert(self, node):
        return self.visit(node)

    def visit(self, node):
        """Visit a node."""
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.visit_unsupported)
        return visitor(node)

    def visit_File(self, node):
        return py_ast.Module(body=wrapNodes(
            [self.visit(i) for i in node.body]
        ))

    def visit_FunctionDef(self, node):
        args = [py_ast.arg(i.key, annotation=None) for i in node.args]
        defaults = [self.visit(i.default)
                    for i in node.args if i.default is not None]
        return py_ast.FunctionDef(
            name=node.name,
            args=py_ast.arguments(args=args,
                                  vararg=None,
                                  kwonlyargs=[],
                                  kw_defaults=[],
                                  kwarg=None,
                                  defaults=defaults,
                                  ),
            body=wrapNodes([self.visit(i) for i in node.body]),
            decorator_list=[],
        )

    def visit_Return(self, node):
        return py_ast.Return(self.visit(node.value))

    def visit_ClassDef(self, node):
        bases = [py_ast.Name(i) for i in node.bases]
        return py_ast.ClassDef(
            name=node.name,
            bases=[],
            keywords=[],
            body=wrapNodes([self.visit(i) for i in node.body]),
            decorator_list=[],
        )

    def visit_Name(self, node):
        return py_ast.Name(id=node.name)

    def visit_Constant(self, node):
        if node.kind == 'string':
            return py_ast.Str(node.value)
        if node.kind == 'int':
            return py_ast.Num(int(node.value))
        if node.kind == 'float':
            return py_ast.Num(float(node.value))
        if node.kind == 'bool':
            return py_ast.NameConstant(value=node.value)
        elif node.kind == 'nil':
            return py_ast.NameConstant(value=None)
        raise Exception('Unsupported Constant kind %s' % node.kind)

    def visit_Attribute(self, node):
        return py_ast.Attribute(
            value=self.visit(node.value),
            attr=node.attribute,
        )

    def visit_Assign(self, node):
        return py_ast.Assign(
            targets=[self.visit(node.target)],
            value=self.visit(node.value),
        )

    def visit_Call(self, node):
        return py_ast.Call(
            func=self.visit(node.value),
            args=[self.visit(i) for i in node.args],
            keywords=[py_ast.keyword(arg=i.key, value=self.visit(
                i.value)) for i in node.kwargs],
        )

    def visit_BinOp(self, node):
        if node.kind == 'Add':
            op = py_ast.Add()
        else:
            raise Exception('Unsupported BinOp kind', node.kind)
        return py_ast.BinOp(self.visit(node.left), op, self.visit(node.right))

    def visit_unsupported(self, node):
        print(dir(node))
        for i in node._fields:
            v = getattr(node, i)
            print('member:>', i, 'raw_value:>', v)
        raise Exception('Unsupported AST Object %s found!' % node)
