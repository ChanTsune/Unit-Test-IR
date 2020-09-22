import ast
from ast import NodeTransformer


class MyTransformer(NodeTransformer):

    def visit_Call(self, node):
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
            elif func.attr == 'checkraises':
                func.attr = 'assertRaises'
                args = node.args
                keywords = node.keywords
                method = ast.Attribute(value=args[1], attr=args[2].s)

                return ast.Call(
                    func=func,
                    args=[args[0], method] + args[3:],
                    keywords=keywords,
                )
        return node

    def visit_FunctionDef(self, node):
        if node.name in ['checkequal', 'checkraises']:
            return None
        return self.generic_visit(node)
