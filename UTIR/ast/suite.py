from .base import AST


class TestCase(AST):
    """UTIR Test Case"""

    def __init__(self, type, excepted, actual, message=""):
        self.type = type
        self.excepted = excepted
        self.actual = actual
        self.message = message


class TestSuite(AST):
    """UTIR Test Suite"""

    def __init__(self, name, expressions, test_cases):
        self.name = name
        self.expressions = expressions
        self.test_cases = test_cases
