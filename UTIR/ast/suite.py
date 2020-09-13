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


class Case(IR):
    pass


@dataclass
class CaseSet(Case):
    target: Node
    call: str
    params: List[Any]
    kind: Any


@dataclass
class CaseExpr(Case):
    name: str
    expr: List[Node]
    asserts: List[Node]


@dataclass
class Assert(IR):
    """UTIR Assert"""
    kind: Any


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
