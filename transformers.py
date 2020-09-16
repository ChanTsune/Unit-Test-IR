from UTIR import ast
from UTIR.transformer import NodeTransformer


class MyTransformer(NodeTransformer):

    def visit_Call(self, node):
        print(node)
        func = node.func
        if isinstance(func, ast.Attribute):
            if func.attr == 'checkequal':
                func.attr = 'assertEqual'
                args = node.args
                keywords = node.keywords
                method = ast.Attribute(value=args[1], attr=args[2].s)

                call = ast.Call(func=method, args=args[3:], keywords=keywords)
                return ast.Call(func=func,
                                args=[args[0], call],
                                keywords=[])
        return node

    def visit_FunctionDef(self, node):
        if node.name == 'checkequal':
            return None
        return self.generic_visit(node)
