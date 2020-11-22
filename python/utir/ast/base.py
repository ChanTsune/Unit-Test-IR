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

    def __repr__(self):
        fields = []
        for name in self._fields:
            field = getattr(name)
            if isinstance(field, AST):
                fields.append("%s=%s" % (name, repr(field)))
            elif isinstance(field, (list, tuple)):
                fields.append("%s=%s" % (name, [repr(i) for i in field]))
            elif isinstance(field, dict):
                fields.append("%s=%s" %
                              (name, {k: repr(v) for k, v in field.items()}))
            else:
                raise TypeError
        return "%s(%s)" % (self.__class__.__name__, ", ".join(fields))

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
