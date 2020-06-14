from .base import Expression


class FunctionCall(Expression):
    """UTIR FunctionCall Expression"""

    def __init__(self, name, **args):
        self.name = name
        self.args = args

    def serialize(self):
        return {
            'FunctionCall': {
                'Name': self.name,
                'Args': {k: v.serialize() for k, v in self.args.items()}
            }
        }
