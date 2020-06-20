from .base import Expression


class Array(Expression):
    """UTIR Array Expression"""

    def __init__(self, values):
        self.values = values

    def serialize(self):
        return {
            'Array': {
                'Values': [i.serialize() for i in self.values]
            }
        }

    def _dump(self):
        return f'values={[i.dump() for i in self.values]}'
