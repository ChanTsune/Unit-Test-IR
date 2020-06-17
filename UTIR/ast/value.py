from enum import Enum

from .base import Expression

class ValueKind(Enum):
    string = 'string'
    int = 'int'
    float = 'float'
    nil = 'nil'


class Value(Exception):
    """UTIR Value Exception"""

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
