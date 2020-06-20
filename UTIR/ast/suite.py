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

    def _dump(self):
        return f'assert={repr(self.assert_)},excepted={self.excepted.dump()},actual={self.actual.dump()},message={repr(self.message)}'


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

    def _dump(self):
        return f'name={repr(self.name)},expressions={[i.dump() for i in self.expressions]}'


class TestProject(AST):
    """UTIR Test Project"""

    def __init__(self, name, test_suites):
        self.name = name
        self.test_suites = test_suites

    def serialize(self):
        return {
            'TestProject': {
                'Name': self.name,
                'TestSuites': [i.serialize() for i in self.test_suites]
            }
        }

    def _dump(self):
        return f'name={repr(self.name)}, test_suites={[i.dump() for i in self.test_suites]}'
