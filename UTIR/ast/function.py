from .base import Expression


class ArgumentDef(Expression):

    def __init__(self, key, default=None):
        self.key = key
        self.default = default

    def serialize(self):
        return {
            'ArgumentDef': {
                'Key': self.key,
                'Default': self.default if self.default is None else self.default.serialize(),
            }
        }


class Return(Expression):
    def __init__(self, expression):
        self.expression = expression

    def serialize(self):
        return {
            'Return': {
                'Expression': self.expression.serialize()
            }
        }


class FunctionDef(Expression):
    """UTIR FunctionDef Expression"""

    def __init__(self, name, kind, args, body, return_type):
        self.name = name
        self.kind = kind
        self.args = args
        self.body = body
        self.return_type = return_type

    def serialize(self):
        return {
            'FunctionDef': {
                'Name': self.name,
                'Kind': self.kind,
                'Args': [i.serialize() for i in self.args],
                'Body': [i.serialize() for i in self.body],
                'ReturnType': self.return_type,
            }
        }

    def _dump(self):
        return f'name={self.name},args={[i.dump() for i in self.args]},kwargs={dict({k: v.dump() for k, v in self.kwargs.items()})},body={[i.dump() for i in self.body]},return_type={self.return_type}'


class Call(Expression):
    """UTIR Call Expression"""

    def __init__(self, func, args, kwargs, kind=None):
        self.func = func
        self.args = args
        self.kwargs = kwargs
        self.kind = kind

    def serialize(self):
        return {
            'Call': {
                'Func': self.func.serialize(),
                'Args': [i.serialize() for i in self.args],
                'KwArgs': {k: v.serialize() for k, v in self.kwargs.items()},
                'Kind': self.kind
            }
        }

    def _dump(self):
        return f'func={self.func.dump()},args={[i.dump() for i in self.args]},kwargs={dict({k: v.dump() for k, v in self.kwargs.items()})}'
