from .base import NodeTransformer
from .. import ast


class DefaultIRTransformer(NodeTransformer):

    def is_target_class(self, node):
        return False

    def _is_target_class(self, node):
        if 'TestCase' in node.bases:
            return True
        if self.is_target_class(node):
            return True
        return False

    def visit_Func(self, node):
        if node.name.startswith('test'):
            return ast.CaseBlock(
                name=node.name,
                body=self.visit(node.body),
            )
        return node

    def visit_Call(self, node):
        if isinstance(node.value, ast.BinOp) and node.value.kind == ast.BinOpKind.DOT:
            if isinstance(node.value.left, ast.Name) and node.value.left.name == 'self':
                if isinstance(node.value.right, ast.Name) and node.value.right.name.startswith('assert'):
                    if node.value.right.name == 'assertEqual':
                        args = [i.value for i in node.args]
                        if len(node.args) == 2:
                            return ast.Assert(
                                kind=ast.AssertEqual(
                                    excepted=args[0],
                                    actual=args[1],
                                    message=None,
                                )
                            )
                        elif len(node.args) == 3:
                            return ast.Assert(
                                kind=ast.AssertEqual(
                                    excepted=args[0],
                                    actual=args[1],
                                    message=args[2],
                                )
                            )
                    print(f'TODO: ~~ {node.value.right.name}')
        return node

    def visit_BinOp(self, node):
        if node.kind == ast.BinOpKind.DOT and isinstance(node.left, ast.Name) and node.left.name == 'self':
            print(f'~~{node}')
            return node
        return node

    def visit_Class(self, node):
        if self._is_target_class(node):
            fields = node.fields
            cases = [self.visit(i) for i in fields]
            cases = [i for i in cases if isinstance(i, ast.Case)]
            return ast.Suite(
                name=node.name,
                set_up=[],
                cases=cases,
                tear_down=[],
            )
        return node
