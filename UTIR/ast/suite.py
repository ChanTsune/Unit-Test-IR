from dataclasses import dataclass
from typing import Any, List

from .nodes import Node, Decl


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
class CaseSet(Case):
    target: Node
    call: str
    params: List[Any]
    kind: Any

    def serialize(self):
        return {
            'Node': 'CaseSet',
            'Target':self.target.serialize(),
            'Call': self.call,
            'Params': [i.serialize() for i in self.params],
            'Kind': self.kind.name,
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
    message: str

    def serialize(self):
        return {
            'Assert': {
                'Kind': self.kind,
                'Excepted': self.excepted.serialize(),
                'Actual': self.actual.serialize(),
                'Message': self.message,
            }
        }
