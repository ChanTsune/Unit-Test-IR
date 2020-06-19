from .base import Expression


class FunctionCall(Expression):
    """UTIR FunctionCall Expression"""

    def __init__(self, func, args, kwargs):
        self.func = func
        self.args = args
        self.kwargs = kwargs

    def serialize(self):
        return {
            'FunctionCall': {
                'Func': self.func.serialize(),
                'Args': [i.serialize() for i in self.args],
                'KwArgs': {k: v.serialize() for k, v in self.kwargs.items()}
            }
        }

    def _dump(self):
        return f'func={self.func.dump()},args={[i.dump() for i in self.args]},kwargs={dict({k: v.dump() for k, v in self.kwargs.items()})}'
