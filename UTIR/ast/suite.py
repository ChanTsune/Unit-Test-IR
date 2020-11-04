from dataclasses import dataclass
from typing import Any, List, Dict, Optional

from .nodes import Block, Node, Decl, Expr


class IR:
    pass

class IRDecl(IR, Decl):
    pass

class IRExpr(IR, Expr):
    pass

@dataclass
class Suite(IRDecl):
    name: str
    set_up: List[Node]
    cases: List[Any]
    tear_down: List[Node]

    def serialize(self):
        return {
            'Node': 'Suite',
            'Name': self.name,
            'SetUp': [i.serialize() for i in self.set_up],
            'Cases': [i.serialize() for i in self.cases],
            'TearDown': [i.serialize() for i in self.tear_down],
        }


class Case(IRDecl):
    pass


@dataclass
class CaseMethodSet(Case):

    @dataclass
    class Param:
        receiver: Expr
        args: Dict[str, Expr]
        excepted: Expr
        message: Optional[str] = None

        def serialize(self):
            return {
                'Node': 'Param',
                'Receiver': self.receiver.serialize(),
                'Args': self.args,
                'Excepted': self.excepted.serialize(),
                'Message': self.message
            }
    name: str
    params: List[Param]

    def serialize(self):
        return {
            'Node': 'MethodSet',
            'Name': self.name,
            'Params': [i.serialize() for i in self.params],
        }


@dataclass
class CaseBlock(Case):
    name: str
    body: Block

    def serialize(self):
        return {
            'Node': 'CaseBlock',
            'Name': self.name,
            'Body': self.body.serialize(),
        }


@dataclass
class Assert(IRExpr):
    """UTIR Assert"""
    kind: Any

    def serialize(self):
        return {
            'Node': 'Assert',
            'Kind': self.kind.serialize(),
        }


class AssertKind(IRExpr):
    pass


@dataclass
class AssertEqual(AssertKind):
    excepted: Expr
    actual: Expr
    message: Optional[str] = None

    def serialize(self):
        return {
            'Node': 'Equal',
            'Excepted': self.excepted.serialize(),
            'Actual': self.actual.serialize(),
            'Message': self.message,
        }

@dataclass
class AssertFailure(AssertKind):
    error: Optional[str]
    func: Expr
    args: List[Expr]
    message: Optional[str] = None

    def serialize(self):
        return {
            'Node': 'Failure',
            'Error': self.error,
            'Func': self.func.serialize(),
            'Args': [i.serialize() for i in self.args],
            'Message': self.message,
        }
