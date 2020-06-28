from .base import Expression


class FunctionDef(Expression):
    """UTIR FunctionDef Expression"""

    def __init__(self, name, kind, args, kwargs, body, return_type):
        self.name = name
        self.kind = kind
        self.args = args
        self.kwargs = kwargs
        self.body = body
        self.return_type = return_type

    def serialize(self):
        return {
            'FunctionDef': {
                'Name': self.name,
                'Kind': self.kind,
                'Args': [i.serialize() for i in self.args],
                'KwArgs': {k: v.serialize() for k, v in self.kwargs.items()},
                'Body': [i.serialize() for i in self.body],
                'ReturnType': self.return_type,
            }
        }

    def _dump(self):
        return f'name={self.name},args={[i.dump() for i in self.args]},kwargs={dict({k: v.dump() for k, v in self.kwargs.items()})},body={[i.dump() for i in self.body]},return_type={self.return_type}'


class Call(Expression):
    """UTIR Call Expression"""

    def __init__(self, func, args, kwargs):
        self.func = func
        self.args = args
        self.kwargs = kwargs

    def serialize(self):
        return {
            'Call': {
                'Func': self.func.serialize(),
                'Args': [i.serialize() for i in self.args],
                'KwArgs': {k: v.serialize() for k, v in self.kwargs.items()}
            }
        }

    def _dump(self):
        return f'func={self.func.dump()},args={[i.dump() for i in self.args]},kwargs={dict({k: v.dump() for k, v in self.kwargs.items()})}'
