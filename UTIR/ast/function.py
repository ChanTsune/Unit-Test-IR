from .base import Expression


class FunctionCall(Expression):
    """UTIR FunctionCall Expression"""

    def __init__(self, func, *args, **kwargs):
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
