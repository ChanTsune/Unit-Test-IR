from .base import AST


class TestCase(AST):
    """UTIR Test Case"""

    def __init__(self, assert_, excepted, actual, message=""):
        self.assert_ = assert_
        self.excepted = excepted
        self.actual = actual
        self.message = message

    def serialize(self):
        return {
            'TestCase': {
                'Assert': self.assert_,
                'Excepted': self.excepted.serialize(),
                'Actual': self.actual.serialize(),
                'Message': self.message,
            }
        }


class TestSuite(AST):
    """UTIR Test Suite"""

    def __init__(self, name, expressions):
        self.name = name
        self.expressions = expressions

    def serialize(self):
        return {
            'TestSuite': {
                'Name': self.name,
                'Expressions': [i.serialize() for i in self.expressions],
            }
        }
