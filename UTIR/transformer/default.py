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

    def visit_Class(self, node):
        if self._is_target_class(node):
            print('TODO: CVT:', node.name)
            return node
        return node
