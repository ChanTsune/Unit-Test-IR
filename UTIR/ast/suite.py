from .base import AST


class Assert(AST):
    """UTIR Assert"""

    def __init__(self, kind, excepted, actual, message=''):
        self.kind = kind
        self.excepted = excepted
        self.actual = actual
        self.message = message

    def serialize(self):
        return {
            'Assert': {
                'Kind': self.kind,
                'Excepted': self.excepted.serialize(),
                'Actual': self.actual.serialize(),
                'Message': self.message,
            }
        }


class TestCase(AST):
    """UTIR Test Case"""

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


class TestSuite(AST):
    """UTIR Test Suite"""

    def __init__(self, name, test_cases):
        self.name = name
        self.test_cases = test_cases

    def serialize(self):
        return {
            'TestSuite': {
                'Name': self.name,
                'TestCases': [i.serialize() for i in self.test_cases],
            }
        }

    def _dump(self):
        return f'name={repr(self.name)},test_cases={[i.dump() for i in self.test_cases]}'


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
