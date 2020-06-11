from .base import Expression


class Array(Expression):
    """UTIR Array Expression"""

    def __init__(self, values):
        self.values = values
