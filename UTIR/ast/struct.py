from .base import Expression


class Struct(Exception):
    """UTIR Struct Exception"""
    def __init__(self, **values):
        self.values = values
