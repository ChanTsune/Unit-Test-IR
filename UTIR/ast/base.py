class Serializeable:

    def serialize(self):
        raise NotImplementedError(
            "%s is not implemented 'serialize' method" % self.__class__.__name__)


class AST(Serializeable):
    """Base class of UTIR AST"""

    def to_py_ast(self):
        raise NotImplementedError(
            "%s is not implemented 'to_py_ast' method" % self.__class__.__name__)


class Expression(AST):
    """Base class of UTIR Expressions"""


class AssignExpression(Expression):
    """UTIR Assign Expression"""

    def __init__(self, name, value):
        self.name = name
        self.value = value

    def serialize(self):
        return {
            'Assign': {
                'Name': self.name,
                'Value': self.value.serialize(),
            }
        }

    def to_py_ast(self):
        return ast.Assign(self.name, self.value)


class Name(Expression):
    """UTIR Name Expression"""

    def __init__(self, name):
        self.name = name

    def serialize(self):
        return {
            'Name': {
                'Name': self.name,
            }
        }

    def to_py_ast(self):
        return ast.Name(self.name)
