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

    def dump(self):
        return "%s(%s)" % (self.__class__.__name__, self._dump())

    def _dump(self):
        return ''

    def __repr__(self):
        return self.dump()


class Expression(AST):
    """Base class of UTIR Expressions"""


class AssignExpression(Expression):
    """UTIR Assign Expression"""

    def __init__(self, target, value):
        self.target = target
        self.value = value

    def serialize(self):
        return {
            'Assign': {
                'Target': self.target.serialize(),
                'Value': self.value.serialize(),
            }
        }

    def _dump(self):
        return f'target={self.target.dump()},value={self.value.dump()}'


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

    def _dump(self):
        return f'name={repr(self.name)}'


class Attribute(Expression):
    """UTIR Attribute Expression"""

    def __init__(self, value, attribute):
        self.value = value
        self.attribute = attribute

    def serialize(self):
        return {
            'Attribute': {
                'Value': self.value.serialize(),
                'Attribute': self.attribute,
            }
        }

    def _dump(self):
        return f'value={self.value.dump()},attribute={repr(self.attribute)}'
