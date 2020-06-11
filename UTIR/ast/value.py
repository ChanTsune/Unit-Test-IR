from UTIR.exception import ASTError
from .base import Expression


class Value(Exception):
    """UTIR Value Exception"""
    type = None

    def __init__(self, value):
        if self.type is None:
            raise ASTError("Value class can not create instance")
        self.value = value


class StringValue(Value):
    """UTIR String Value"""
    type = "string"


class IntValue(Value):
    """UTIR Int Value"""
    type = "int"


class FloatValue(Value):
    """UTIR Float Value"""
    type = "float"


class NilValue(Value):
    """UTIR Nil Value"""
    type = "nil"
