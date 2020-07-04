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

    @property
    def _fields(self):
        for field in dir(self):
            if not field.startswith('__'):
                try:
                    attr = getattr(self, field)
                    if isinstance(attr, (list, dict)):
                        if len(attr) != 0:
                            yield field
                    elif isinstance(attr, AST):
                        yield field
                except AttributeError:
                    pass


class Node(AST):
    pass
