from .base import AST


class TestCase(AST):
    """UTIR Test Case"""

    def __init__(self, type, excepted, actual, message=""):
        self.type = type
        self.excepted = excepted
        self.actual = actual
        self.message = message

    def serialize(self):
        return {
            'type': self.type,
            'excepted': self.excepted.serialize(),
            'actual': self.actual.serialize(),
            'message': self.message,
        }


class TestSuite(AST):
    """UTIR Test Suite"""

    def __init__(self, name, expressions, test_cases):
        self.name = name
        self.expressions = expressions
        self.test_cases = test_cases

    def serialize(self):
        return {
            'name': self.name,
            'expressions': [i.serialize() for i in self.expressions],
            'test_cases': [i.serialize() for i in self.test_cases],
        }
