
class AST:
    """Base class of UTIR AST"""


class Expression(AST):
    """Base class of UTIR Expressions"""


class AssignExpression(Expression):
    """UTIR Assign Expression"""

    def __init__(self, name, value):
        self.name = name
        self.value = value
