from enum import Enum

from .base import Expression

class ValueKind(Enum):
    string = 'string'
    int = 'int'
    float = 'float'
    nil = 'nil'


class Value(Expression):
    """UTIR Value Expression"""

    def __init__(self, kind, value):
        self.kind = kind
        self.value = value

    def serialize(self):
        return {
            'Value': {
                'Kind': self.kind,
                'Value': self.value,
            }
        }

    def _dump(self):
        return f'kind={repr(self.kind)},value={repr(self.value)}'
