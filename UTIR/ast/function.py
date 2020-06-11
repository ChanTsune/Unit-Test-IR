from .base import Expression


class FunctionCall(Expression):
    """UTIR FunctionCall Expression"""

    def __init__(self, name, args):
        self.name = name
        self.args = args
