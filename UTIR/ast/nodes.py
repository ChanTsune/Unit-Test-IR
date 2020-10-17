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
        return {
            'Node': 'File',
            'Body': [i.serialize() for i in self.body],
        }


class Stmt(Node):
    pass


@dataclass
class StmtDecl(Stmt):
    decl: Node

    def serialize(self):
        return {
            'Node': 'Decl',
            'Decl': self.decl.serialize(),
        }

@dataclass
class StmtExpr(Stmt):
    expr: Node

    def serialize(self):
        return {
            'Node': 'Expr',
            'Expr': self.expr.serialize(),
        }


@dataclass
class Block(Node):
    body: List[Stmt]

    def serialize(self):
        return {
            'Node': 'Block',
            'Body': [i.serialize() for i in self.body],
        }


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
        return {
            'Node': 'Var',
            'Name': self.name,
            'Type': self.type,
            'Value': None if self.value is None else self.value.serialize()
        }


@dataclass
class Func(Decl):
    name: str
    args: List[Any]
    body: Block

    def serialize(self):
        return {
            'Node': 'Func',
            'Name': self.name,
            'Args': [i.serialize() for i in self.args],
            'Body': self.body.serialize(),
        }

    @dataclass
    class Arg(Decl):
        field: Var
        vararg: bool

        def serialize(self):
            return {
                'Node': 'Arg',
                'Field': self.field.serialize(),
                'Vararg': self.vararg,
            }


@dataclass
class Class(Decl):
    name: str
    bases: List[str]
    constractors: List[Func]
    fields: List[Decl]

    def serialize(self):
        return {
            'Node': 'Class',
            'Name': self.name,
            'Bases': self.bases,
            'Constractors': [i.serialize() for i in self.constractors],
            'Fields': [i.serialize() for i in self.fields],
        }


@dataclass
class Name(Expr):
    name: str

    def serialize(self):
        return {
            'Node': 'Name',
            'Name': self.name,
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
        return {
            'Node': 'Constant',
            'Kind': self.kind.value,
            'Value': self.value,
        }

@dataclass
class IRList(Expr):
    values: List[Expr]

    def serialize(self):
        return {
            'Node': 'List',
            'Values': [i.serialize() for i in self.values],
        }

@dataclass
class Tuple(Expr):
    values: List[Expr]

    def serialize(self):
        return {
            'Node': 'Tuple',
            'Values': [i.serialize() for i in self.values],
        }


class BinOpKind(Enum):
    DOT = 'DOT'
    ASSIGN = 'ASSIGN'
    ADD = 'ADD'
    SUB = 'SUB'
    MUL = 'MUL'
    DIV = 'DIV'
    MOD = 'MOD'
    LEFT_SHIFT = 'LEFT_SHIFT'
    RIGHT_SHIFT = 'RIGHT_SHIFT'
    IN = 'IN'
    NOT_EQUAL = 'NOT_EQUAL'


@dataclass
class BinOp(Expr):
    left: Expr
    kind: BinOpKind
    right: Expr

    def serialize(self):
        return {
            'Node': 'BinOp',
            'Kind': self.kind.value,
            'Left': self.left.serialize(),
            'Right': self.right.serialize(),
        }


class UnaryOpKind(Enum):
    PLUS = 'PLUS'
    MINUS = 'MINUS'


@dataclass
class UnaryOp(Expr):
    kind: UnaryOpKind
    value: Expr

    def serialize(self):
        return {
            'Node': 'UnaryOp',
            'Kind': self.kind.value,
            'Value': self.value.serialize(),
        }


@dataclass
class Subscript(Expr):
    value: Expr
    index: Expr

    def serialize(self):
        return {
            'Node': 'Subscript',
            'Value': self.value.serialize(),
            'Index': self.index.serialize(),
        }


@dataclass
class Call(Expr):
    value: Expr
    args: List[Any]

    def serialize(self):
        return {
            'Node': 'Call',
            'Value': self.value.serialize(),
            'Args': [i.serialize() for i in self.args],
        }

    @dataclass
    class Arg(Node):
        name: str
        value: Expr

        def serialize(self):
            return {
                'Node': 'Arg',
                'Name': None if self.name is None else self.name,
                'Value': self.value.serialize(),
            }


@dataclass
class Throw(Stmt):
    value: Expr

    def serialize(self):
        return {
            'Node': 'Throw',
            'Value': self.value.serialize(),
        }


@dataclass
class Return(Stmt):
    value: Expr

    def serialize(self):
        return {
            'Node': 'Return',
            'Value': self.value.serialize(),
        }


@dataclass
class For(Stmt):
    value: Var
    generator: Expr
    body: Block

    def serialize(self):
        return {
            'Node': 'For',
            'Value': self.value.serialize(),
            'Generator': self.generator.serialize(),
            'Body': self.body.serialize(),
        }


@dataclass
class Try(Stmt):
    body: Block
    catch: Any

    @dataclass
    class Catch(Stmt):
        type: str
        body: Block
        catch: Optional[Any]

        def serialize(self):
            return {
                'Node': 'Catch',
                'Type': self.type,
                'Body': self.body.serialize(),
                'Catch': None if self.catch is None else self.catch.serialize(),
            }

    def serialize(self):
        return {
            'Node': 'Try',
            'Body': self.body.serialize(),
            'Catch': self.catch.serialize(),
        }
