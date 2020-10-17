import ast as py_ast
from ast import NodeTransformer as PyNodeTransformer
from itertools import chain

from UTIR import ast as ir_ast


def filterNull(lst):
    return [i for i in lst if i is not None]


class PyAST2IRASTConverter(PyNodeTransformer):

    def _wrap_for_block(self, node):
        if isinstance(node, ir_ast.Decl):
            return ir_ast.StmtDecl(node)
        elif isinstance(node, ir_ast.Expr):
            return ir_ast.StmtExpr(node)
        elif isinstance(node, ir_ast.Stmt):
            return node
        raise Exception('Excepted Decl or Expr, but %s' %
                        node.__class__.__name__)

    def visit(self, node):
        """Visit a node."""
        if not isinstance(node, py_ast.AST):
            raise TypeError('python node excepted, but %s received.' %
                            node.__class__.__name__)
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.visit_unsupported)
        return visitor(node)

    def visit_Module(self, node):
        return ir_ast.File(
            body=filterNull([self.visit(i) for i in node.body]) # TODO: filter
        )

    def visit_Str(self, node):
        return ir_ast.Constant(ir_ast.ConstantKind.STRING, node.s)

    def visit_Num(self, node):
        if isinstance(node.n, float):
            return ir_ast.Constant(ir_ast.ConstantKind.FLOAT, str(node.n))
        elif isinstance(node.n, int):
            return ir_ast.Constant(ir_ast.ConstantKind.INTEGER, str(node.n))
        return self.Unsupported()

    def visit_Bytes(self, node):
        return ir_ast.Constant(ir_ast.ConstantKind.BYTES, str(node.s))

    def visit_NameConstant(self, node):
        if node.value == True:
            return ir_ast.Constant(ir_ast.ConstantKind.BOOLEAN, str(True))
        elif node.value == False:
            return ir_ast.Constant(ir_ast.ConstantKind.BOOLEAN, str(False))
        elif node.value == None:
            return ir_ast.Constant(ir_ast.ConstantKind.NULL, 'NULL')
        raise Exception('Unsupported NameConstant %s' % node)

    def visit_ImportFrom(self, node):
        # ignore import directive
        return None

    def visit_Import(self, node):
        # ignore import directive
        return None

    def visit_Expr(self, node):
        return self.visit(node.value)

    def visit_ClassDef(self, node):
        _bases = [self.visit(i) for i in node.bases]
        bases = []
        for i in _bases:
            if isinstance(i, ir_ast.Name):
                bases.append(i.name)
            elif isinstance(i, ir_ast.BinOp) and i.kind == ir_ast.BinOpKind.DOT:
                bases.append(i.right)
            else:
                raise TypeError("%s" % i.__class__.__name__)

        return ir_ast.Class(node.name,
                            bases,
                            [],  # TODO: support constractors
                            filterNull([self.visit(i) for i in node.body]) # TODO: filter
                            )

    def visit_FunctionDef(self, node):
        raw_stmt = [self.visit(i) for i in node.body]
        raw_stmt = filterNull(raw_stmt) # TODO: filter
        stmt = [self._wrap_for_block(i) for i in raw_stmt]
        return ir_ast.Func(node.name,
                           self.visit(node.args),
                           ir_ast.Block(stmt),
                           )

    def visit_arguments(self, node):
        pad_defaults = [None] * (len(node.args) - len(node.defaults))
        arg_defs = []
        for arg, default in chain(zip(node.args, pad_defaults+node.defaults),
                                  zip(node.kwonlyargs, node.kw_defaults)):
            arg_default = default if default is None else self.visit(default)
            var = ir_ast.Var(arg.arg, None, arg_default) # TODO: Type (2nd arg)
            func_arg = ir_ast.Func.Arg(var, vararg=False)
            arg_defs.append(func_arg)
        if node.vararg is not None:
            arg = node.vararg
            var = ir_ast.Var(arg.arg, None, None) # TODO: Type (2nd arg)
            func_arg = ir_ast.Func.Arg(var, vararg=True)
            arg_defs.append(func_arg)
        if node.kwarg is not None:
            arg = node.vararg
            var = ir_ast.Var(arg.arg, 'Dictionary', None)
            func_arg = ir_ast.Func.Arg(var, vararg=False)
            arg_defs.append(func_arg)
        # TODO: python 3.8
        return arg_defs

    def visit_keyword(self, node):
        # TODO: support keyword
        # print("@@@", node.arg, node.value)
        return ir_ast.KwArg(node.arg, self.visit(node.value))

    def visit_Starred(self, node):
        print('warn: Unsupported', node)
        print(node.value)
        return self.Unsupported()

    def visit_If(self, node):
        print('warn: Unsupported', node)
        print(node.test, node.body, node.orelse)
        return None

    def visit_Pass(self, node):
        # ignore pass directive
        return None

    def visit_DictComp(self, node):
        # 辞書内包表記
        print('warn: Unsupported', node)
        print(node.key, node.value, node.generators)
        return self.Unsupported()

    def visit_ListComp(self, node):
        # リスト内包表記
        print('warn: Unsupported', node)
        print(node.elt, node.generators)
        return self.Unsupported()

    def visit_GeneratorExp(self, node):
        print('warn: Unsupported', node)
        print(node.elt, node.generators)
        return self.Unsupported()

    def visit_With(self, node):
        print('warn: Unsupported', node)
        print(node.items, node.body)
        return None

    def visit_For(self, node):
        if len(node.orelse):
            print('warn: Unsupported for node else stmt.', node.orelse)
        body = [self.visit(i) for i in node.body]
        body = filterNull(body)
        body = [self._wrap_for_block(i) for i in body]

        value = self.visit(node.target)
        if isinstance(value, ir_ast.Name):
            value = ir_ast.Var(value.name, None, None)
        else:
            print('warn: Unexpected', value)

        return ir_ast.For(
            value=value,
            generator=self.visit(node.iter),
            body=ir_ast.Block(body),
        )

    def visit_Slice(self, node):
        args = [node.lower, node.upper, node.step]
        args = [ir_ast.Constant(kind=ir_ast.ConstantKind.NULL, value="NULL") if i is None else self.visit(i) for i in args]
        return ir_ast.Call(
            value=ir_ast.Name('slice'),
            args=[ir_ast.Call.Arg(name=None, value=i) for i in args]
        )

    def visit_Tuple(self, node):
        return ir_ast.Tuple(
            values=[self.visit(i) for i in node.elts]
        )

    def visit_Dict(self, node):
        print('warn: Unsupported', node)
        print(node.keys, node.values)
        return self.Unsupported()

    def visit_Try(self, node):
        print('warn: Unsupported', node)
        print(node.body, node.finalbody,
              node.handlers, node.orelse)
        return None

    def visit_UnaryOp(self, node):
        if isinstance(node.op, py_ast.USub):
            op_kind = ir_ast.UnaryOpKind.MINUS
        else:
            raise TypeError("%s" % node.op)
        return ir_ast.UnaryOp(
            op_kind,
            self.visit(node.operand))

    def visit_BinOp(self, node):
        node_kind = node.op.__class__.__name__
        if node_kind == 'Pow':
            return ir_ast.Call(
                ir_ast.Name('pow'),
                [
                    ir_ast.Call.Arg(name=None, value=self.visit(node.left)),
                    ir_ast.Call.Arg(name=None, value=self.visit(node.right)),
                ]
            )

        def get_kind(kind):
            kind = kind.__class__.__name__
            if kind == 'Add':
                return ir_ast.BinOpKind.ADD
            elif kind == 'Sub':
                return ir_ast.BinOpKind.SUB
            elif kind == 'Mult':
                return ir_ast.BinOpKind.MUL
            elif kind == 'Div':
                return ir_ast.BinOpKind.DIV
            elif kind == 'Mod':
                return ir_ast.BinOpKind.MOD
            elif kind == 'LShift':
                return ir_ast.BinOpKind.LEFT_SHIFT
            elif kind == 'RShift':
                return ir_ast.BinOpKind.RIGHT_SHIFT
            
            raise Exception('Unsupported BinOp kind %s' % kind)
        return ir_ast.BinOp(self.visit(node.left),
                            get_kind(node.op),
                            self.visit(node.right))

    def visit_Compare(self, node):
        def opkind_map(node):
            if isinstance(node, py_ast.In):
                return ir_ast.BinOpKind.IN
            elif isinstance(node, py_ast.NotEq):
                return ir_ast.BinOpKind.NOT_EQUAL
            else:
                raise Exception('Unsupported BinOp kind', node.ops)
        if isinstance(node.ops, list):
            if len(node.ops) == 1:
                if isinstance(node.comparators, list) and len(node.comparators) == 1:
                    return ir_ast.BinOp(
                        self.visit(node.left),
                        opkind_map(node.ops[0]),
                        self.visit(node.comparators[0]),
                    )
            print('~~~~warn: Unsupported', node)
            print(node.comparators, node.left, node.ops)
            return self.Unsupported()
        else:
            op_kind = opkind_map(node.ops)
        return ir_ast.BinOp(
            self.visit(node.left),
            op_kind,
            self.visit(node.comparators),
        )

    def visit_AugAssign(self, node):
        if isinstance(node.op, py_ast.Add):
            op_kind = ir_ast.BinOpKind.ADD
        else:
            raise TypeError("%s" % node.op)
        target = self.visit(node.target)
        return ir_ast.BinOp(
            target,
            ir_ast.BinOpKind.ASSIGN,
            ir_ast.BinOp(
                target,
                op_kind,
                self.visit(node.value),
            ),
        )

    def visit_JoinedStr(self, node):
        for i in node._fields:
            v = getattr(node, i)
            print('member:>', i, 'raw_value:>', v)
            for j in v:
                print(j, j._fields)
        # TODO: support f-string
        return self.Unsupported()

    def visit_Assign(self, node):
        if len(node.targets) != 1:
            raise Exception('Unsupported multiple Assign')
        return ir_ast.BinOp(self.visit(node.targets[0]),
                            ir_ast.BinOpKind.ASSIGN,
                            self.visit(node.value))

    def visit_Attribute(self, node):
        return ir_ast.BinOp(self.visit(node.value),
                            ir_ast.BinOpKind.DOT,
                            ir_ast.Name(node.attr),
                            )

    def visit_Name(self, node):
        return ir_ast.Name(node.id)

    def visit_Return(self, node):
        return ir_ast.Return(self.visit(node.value))

    def visit_Call(self, node):
        args = [ir_ast.Call.Arg(name=None, value=self.visit(i))
                for i in node.args]
        # print(node.keywords) # TODO: kwargs
        return ir_ast.Call(self.visit(node.func),
                           args,
                           )

    def visit_Subscript(self, node):
        return ir_ast.Subscript(self.visit(node.value),
                                self.visit(node.slice),
                                )

    def visit_Index(self, node):
        return self.visit(node.value)

    def visit_List(self, node):
        return ir_ast.IRList([self.visit(i) for i in node.elts])

    def generic_visit(self, node):
        print("%s" % node)
        return super().generic_visit(node)

    def visit_unsupported(self, node):
        print(dir(node))
        for i in node._fields:
            v = getattr(node, i)
            print('member:>', i, 'raw_value:>', v)
        raise Exception('Unsupported AST Object %s found!' % node)

    def Unsupported(self):
        return ir_ast.Constant(ir_ast.ConstantKind.NULL, 'NULL')

    def convert(self, node):
        return self.visit(node)
