from .base import Node


class File(Node):
    def __init__(self, body):

        self.body = body

    def serialize(self):
        return {'File':
                {'Body': [i.serialize() for i in self.body],

                 }
                }


class FunctionDef(Node):
    def __init__(self, name, args, body):

        self.name = name

        self.args = args

        self.body = body

    def serialize(self):
        return {'FunctionDef':
                {'Name': self.name,
                 'Args': [i.serialize() for i in self.args],
                 'Body': [i.serialize() for i in self.body],

                 }
                }


class ClassDef(Node):
    def __init__(self, name, bases, fields, body):

        self.name = name

        self.bases = bases

        self.fields = fields

        self.body = body

    def serialize(self):
        return {'ClassDef':
                {'Name': self.name,
                 'Bases': self.bases,
                 'Fields': [i.serialize() for i in self.fields],
                 'Body': [i.serialize() for i in self.body],

                 }
                }


class Return(Node):
    def __init__(self, value):

        self.value = value

    def serialize(self):
        return {'Return':
                {'Value': self.value.serialize(),

                 }
                }


class Assign(Node):
    def __init__(self, target, value):

        self.target = target

        self.value = value

    def serialize(self):
        return {'Assign':
                {'Target': self.target.serialize(),
                 'Value': self.value.serialize(),

                 }
                }


class For(Node):
    def __init__(self, value, generator, body):

        self.value = value

        self.generator = generator

        self.body = body

    def serialize(self):
        return {'For':
                {'Value': self.value.serialize(),
                 'Generator': self.generator.serialize(),
                 'Body': [i.serialize() for i in self.body],

                 }
                }


class Block(Node):
    def __init__(self, body):

        self.body = body

    def serialize(self):
        return {'Block':
                {'Body': [i.serialize() for i in self.body],

                 }
                }


class Try(Node):
    def __init__(self, body):

        self.body = body

    def serialize(self):
        return {'Try':
                {'Body': [i.serialize() for i in self.body],

                 }
                }


class Raise(Node):
    def __init__(self, value):

        self.value = value

    def serialize(self):
        return {'Raise':
                {'Value': self.value.serialize(),

                 }
                }


class Catch(Node):
    def __init__(self, body):

        self.body = body

    def serialize(self):
        return {'Catch':
                {'Body': [i.serialize() for i in self.body],

                 }
                }


class BoolOp(Node):
    def __init__(self, kind, left, right):

        self.kind = kind

        self.left = left

        self.right = right

    def serialize(self):
        return {'BoolOp':
                {'Kind': self.kind,
                 'Left': self.left.serialize(),
                 'Right': self.right.serialize(),

                 }
                }


class BinOp(Node):
    def __init__(self, kind, left, right):

        self.kind = kind

        self.left = left

        self.right = right

    def serialize(self):
        return {'BinOp':
                {'Kind': self.kind,
                 'Left': self.left.serialize(),
                 'Right': self.right.serialize(),

                 }
                }


class UnaryOp(Node):
    def __init__(self, kind, value):

        self.kind = kind

        self.value = value

    def serialize(self):
        return {'UnaryOp':
                {'Kind': self.kind,
                 'Value': self.value.serialize(),

                 }
                }


class Constant(Node):
    def __init__(self, kind, value):

        self.kind = kind

        self.value = value

    def serialize(self):
        return {'Constant':
                {'Kind': self.kind,
                 'Value': self.value,

                 }
                }


class Attribute(Node):
    def __init__(self, value, attribute):

        self.value = value

        self.attribute = attribute

    def serialize(self):
        return {'Attribute':
                {'Value': self.value.serialize(),
                 'Attribute': self.attribute,

                 }
                }


class Subscript(Node):
    def __init__(self, value, index):

        self.value = value

        self.index = index

    def serialize(self):
        return {'Subscript':
                {'Value': self.value.serialize(),
                 'Index': self.index.serialize(),

                 }
                }


class Name(Node):
    def __init__(self, name, kind=None):

        self.name = name

        self.kind = kind

    def serialize(self):
        return {'Name':
                {'Name': self.name,
                 'Kind': self.kind,

                 }
                }


class Array(Node):
    def __init__(self, values):

        self.values = values

    def serialize(self):
        return {'Array':
                {'Values': [i.serialize() for i in self.values],

                 }
                }


class Tuple(Node):
    def __init__(self, values):

        self.values = values

    def serialize(self):
        return {'Tuple':
                {'Values': [i.serialize() for i in self.values],

                 }
                }


class Call(Node):
    def __init__(self, value, args, kwargs):

        self.value = value

        self.args = args

        self.kwargs = kwargs

    def serialize(self):
        return {'Call':
                {'Value': self.value.serialize(),
                 'Args': [i.serialize() for i in self.args],
                 'KwArgs': [i.serialize() for i in self.kwargs],

                 }
                }


class ArgumentDef(Node):
    def __init__(self, key, default=None):

        self.key = key

        self.default = default

    def serialize(self):
        return {'ArgumentDef':
                {'Key': self.key,
                 'Default': self.default if self.default is None else self.default.serialize(),

                 }
                }


class KwArg(Node):
    def __init__(self, key, value):

        self.key = key

        self.value = value

    def serialize(self):
        return {'KwArg':
                {'Key': self.key,
                 'Value': self.value.serialize(),

                 }
                }
