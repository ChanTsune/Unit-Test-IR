from dataclasses import dataclass
from typing import Any, List, Optional
from enum import Enum

from .base import AST


class Node(AST):
    pass


@dataclass
class File(Node):
    body: List[Node]

    def serialize(self):
        return {'File':
                {'Body': [i.serialize() for i in self.body],
                 }
                }


class Stmt(Node):
    pass


@dataclass
class StmtDecl(Stmt):
    decl: Node

    def serialize(self):
        return {'Decl': {
            'Decl': self.decl.serialize()
        }}


@dataclass
class StmtExpr(Stmt):
    expr: Node

    def serialize(self):
        return {'Expr': {
            'Expr': self.expr.serialize()
        }}


@dataclass
class Block(Node):
    body: List[Stmt]

    def serialize(self):
        return {'Block': {
            'Body': self.body.serialize()
        }}


class Decl(Node):
    pass


class Expr(Node):
    pass


@dataclass
class Var(Decl):
    name: str
    type: str
    value: Optional[Expr]

    def serialize(self):
        return {'Var': {
            'Name': self.name,
            'Type': self.type,
            'Value': None if self.value is None else self.value.serialize()
        }}


@dataclass
class Func(Decl):
    name: str
    args: List[Any]
    body: Block

    def serialize(self):
        return {'Func':
                {'Name': self.name,
                 'Args': [i.serialize() for i in self.args],
                 'Body': [i.serialize() for i in self.body],

                 }
                }

    @dataclass
    class Arg(Decl):
        field: Var
        varargs: bool

        def serialize(self):
            return {'Arg': {
                'Field': self.field.serialize(),
                'Varargs': self.varargs,
            }}


@dataclass
class Class(Decl):
    name: str
    bases: List[str]
    constractors: List[Func]
    fields: List[Decl]

    def serialize(self):
        return {'Class':
                {'Name': self.name,
                 'Bases': self.bases,
                 'Constractors': [i.serialize() for i in self.constractors],
                 'Fields': [i.serialize() for i in self.fields],
                 }
                }


@dataclass
class Name(Expr):
    name: str

    def serialize(self):
        return {'Name':
                {'Name': self.name,
                 }
                }


class ConstantKind(Enum):
    STRING = 'STRING'
    BYTES = 'BYTES'
    INTEGER = 'INTEGER'
    FLOAT = 'FLOAT'
    BOOLEAN = 'BOOLEAN'
    NULL = 'NULL'


@dataclass
class Constant(Expr):
    kind: ConstantKind
    value: str

    def serialize(self):
        return {'Constant':
                {'Kind': self.kind.value,
                 'Value': self.value,
                 }
                }


@dataclass
class Tuple(Expr):
    values: List[Expr]

    def serialize(self):
        return {'Tuple':
                {'Values': [i.serialize() for i in self.values],

                 }
                }


class BinOpKind(Enum):
    dot = 'DOT'
    assign = 'ASSIGN'


@dataclass
class BinOp(Expr):
    left: Expr
    kind: BinOpKind
    right: Expr

    def serialize(self):
        return {'BinOp':
                {'Kind': self.kind.value,
                 'Left': self.left.serialize(),
                 'Right': self.right.serialize(),
                 }
                }


class UnaryOpKind(Enum):
    plus = 'PLUS'
    minus = 'MINUS'


@dataclass
class UnaryOp(Expr):
    kind: UnaryOpKind
    value: Expr

    def serialize(self):
        return {'UnaryOp':
                {'Kind': self.kind.value,
                 'Value': self.value.serialize(),

                 }
                }


@dataclass
class Subscript(Expr):
    value: Expr
    index: Expr

    def serialize(self):
        return {'Subscript':
                {'Value': self.value.serialize(),
                 'Index': self.index.serialize(),

                 }
                }


@dataclass
class Call(Expr):
    value: Expr
    args: List[Any]

    def serialize(self):
        return {'Call':
                {'Value': self.value.serialize(),
                 'Args': [i.serialize() for i in self.args],
                 }
                }

    @dataclass
    class Arg(Node):
        name: str
        value: Expr

        def serialize(self):
            return {'Arg': {
                    'Name': self.name,
                    'Value': self.value.serialize()
                    }
                    }


@dataclass
class Throw(Expr):
    value: Expr

    def serialize(self):
        return {'Throw':
                {'Value': self.value.serialize(),

                 }
                }


@dataclass
class Return(Expr):
    value: Expr

    def serialize(self):
        return {'Return':
                {'Value': self.value.serialize(),

                 }
                }


@dataclass
class For(Expr):
    value: Var
    generator: Expr
    body: Block

    def serialize(self):
        return {'For':
                {'Value': self.value.serialize(),
                 'Generator': self.generator.serialize(),
                 'Body': self.body.serialize(),

                 }
                }


@dataclass
class Try(Expr):
    body: Block

    def serialize(self):
        return {'Try':
                {'Body': self.body.serialize(),

                 }
                }


@dataclass
class Catch(Expr):
    type: str
    body: Block

    def serialize(self):
        return {'Catch': {
            'Type': self.type,
            'Body': self.body.serialize(),

        }
        }
