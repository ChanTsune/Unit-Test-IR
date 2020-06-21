from enum import Enum

from .base import Expression

class ValueKind(Enum):
    string = 'string'
    int = 'int'
    float = 'float'
    bool = 'bool'
    nil = 'nil'


class Value(Expression):
    """UTIR Value Expression"""

    def __init__(self, kind, value):
        if kind not in ValueKind.__members__.keys():
            raise Exception('Unsupported kind: %s' % kind)
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
