from dataclasses import dataclass
from typing import Any, List, Dict, Optional

from .nodes import Node, Decl, Expr


class IR(Decl):
    pass


@dataclass
class Suite(IR):
    set_up: List[Node]
    cases: List[Any]
    tear_down: List[Node]

    def serialize(self):
        return {
            'Node': 'Suite',
            'SetUp': [i.serialize() for i in self.set_up],
            'Cases': [i.serialize() for i in self.cases],
            'TearDown': [i.serialize() for i in self.tear_down],
        }


class Case(IR):
    pass


@dataclass
class CaseMethodSet(Case):

    @dataclass
    class Param:
        receiver: Expr
        args: Dict[str, Expr]
        excepted: Expr
        message: Optional[str]

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
class CaseExpr(Case):
    name: str
    expr: List[Node]
    asserts: List[Node]

    def serialize(self):
        return {
            'Node': 'CaseExpr',
            'Name': self.name,
            'Expr': [i.serialize() for i in self.expr],
            'Asserts': [i.serialize() for i in self.asserts],
        }


@dataclass
class Assert(IR):
    """UTIR Assert"""
    kind: Any

    def serialize(self):
        return {
            'Kind': self.kind.serialize(),
        }


class AssertKind:
    pass


@dataclass
class AssertEqual(AssertKind):
    excepted: Node
    actual: Node
    message: Optional[str]

    def serialize(self):
        return {
            'Node': 'Equal',
            'Excepted': self.excepted.serialize(),
            'Actual': self.actual.serialize(),
            'Message': self.message,
        }
