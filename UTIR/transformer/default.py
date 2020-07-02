from .base import NodeTransformer


class DefaultIRTransformer(NodeTransformer):

    def visit_Call(self, node):
        return node

    def visit_FunctionDef(self, node):
        return node

    def visit_ClassDef(self, node):
        return node
