class Serializeable:

    def serialize(self):
        raise NotImplementedError(
            "%s is not implemented 'serialize' method" % self.__class__.__name__)

    @classmethod
    def deserialize(cls, data):
        raise NotImplementedError(
            "%s is not implemented 'deserialize' method" % cls.__name__)


class AST(Serializeable):
    """Base class of UTIR AST"""


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
