from .base import Expression


class Struct(Exception):
    """UTIR Struct Exception"""

    def __init__(self, name, values):
        self.name = name
        self.values = values

    def serialize(self):
        return {
            'Struct':{
                'Name': self.name,
                'Values': {k: v.serialize() for k, v in self.values.items()},
            }
        }

    def _dump(self):
        return f'name={repr(self.name)},values={dict({k: v.dump() for k, v in self.values.items()})}'
