import ast as py_ast
from ast import NodeTransformer as PyNodeTransformer

from UTIR import ast as ir_ast


class PyAST2IRASTConverter(PyNodeTransformer):

    def visit(self, node):
        """Visit a node."""
        if isinstance(node, list):
            new_nodes = []
            for old_node in node:
                new_node = self.visit(old_node)
                if new_node is None:
                    continue
                elif isinstance(new_node, ir_ast.AST):
                    new_nodes.append(new_node)
                    continue
                elif isinstance(new_node, list):
                    new_nodes.extend(new_node)
            return new_nodes
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.visit_unsupported)
        return visitor(node)

    def visit_Module(self, node):
        return ir_ast.File(self.visit(node.body))

    def visit_Str(self, node):
        return ir_ast.Constant('string', node.s)

    def visit_Num(self, node):
        if isinstance(node.n, float):
            return ir_ast.Constant('float', node.n)
        elif isinstance(node.n, int):
            return ir_ast.Constant('int', node.n)
        return self.Unsupported()

    def visit_Bytes(self, node):
        return ir_ast.Constant('bytes', node.s)

    def visit_NameConstant(self, node):
        if node.value == True:
            return ir_ast.Constant('bool', True)
        elif node.value == False:
            return ir_ast.Constant('bool', False)
        elif node.value == None:
            return ir_ast.Constant('nil', None)
        raise Exception('Unsupported %s' % node)

    def visit_ImportFrom(self, node):
        # ignore import directive
        return None

    def visit_Import(self, node):
        # ignore import directive
        return None

    def visit_Expr(self, node):
        return self.visit(node.value)

    def visit_ClassDef(self, node):
        _bases = self.visit(node.bases)
        bases = []
        for i in _bases:
            if isinstance(i, ir_ast.Attribute):
                bases.append(i.attribute)
            elif isinstance(i, ir_ast.Name):
                bases.append(i.name)
            else:
                raise TypeError("%s" % i.__class__.__name__)

        return ir_ast.ClassDef(node.name,
                               bases,
                               [],  # TODO: support fields
                               self.visit(node.body)
                               )

    def visit_FunctionDef(self, node):
        return ir_ast.FunctionDef(node.name,
                                  self.visit(node.args),
                                  self.visit(node.body),
                                  )

    def visit_arguments(self, node):
        arg_defs = []
        for arg in node.args:
            arg_defs.append(ir_ast.ArgumentDef(arg.arg))
        # TODO: support 'args', 'defaults', 'kw_defaults', 'kwarg', 'kwonlyargs', 'vararg'
        # for arg in node:
        #     pass
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
        print('warn: Unsupported', node)
        print(node.target, node.iter,
              node.body, node.orelse)
        return None

    def visit_Slice(self, node):
        print('warn: Unsupported', node)
        print(node.upper, node.step, node.lower)
        return self.Unsupported()

    def visit_Tuple(self, node):
        print('warn: Unsupported', node)
        print(node.elts)
        return self.Unsupported()

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
            op_kind = 'USub'
        else:
            raise TypeError("%s" % node.op)
        return ir_ast.UnaryOp(
            op_kind,
            self.visit(node.operand))

    def visit_BinOp(self, node):
        return ir_ast.BinOp(node.op.__class__.__name__,
                            self.visit(node.left),
                            self.visit(node.right))

    def visit_Compare(self, node):
        print('warn: Unsupported', node)
        print(node.comparators, node.left, node.ops)
        return self.Unsupported()

    def visit_AugAssign(self, node):
        if isinstance(node.op, py_ast.Add):
            op_kind = 'Add'
        else:
            raise TypeError("%s" % node.op)
        target = self.visit(node.target)

        return ir_ast.Assign(
            target,
            ir_ast.BinOp(op_kind,
                         target,
                         self.visit(node.value)
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
        return ir_ast.Assign(self.visit(node.targets[0]),
                             self.visit(node.value))

    def visit_Attribute(self, node):
        return ir_ast.Attribute(self.visit(node.value), node.attr)

    def visit_Name(self, node):
        return ir_ast.Name(node.id)

    def visit_Return(self, node):
        return ir_ast.Return(self.visit(node.value))

    def visit_Call(self, node):
        return ir_ast.Call(self.visit(node.func),
                           self.visit(node.args),
                           self.visit(node.keywords)
                           )

    def visit_Subscript(self, node):
        return ir_ast.Subscript(self.visit(node.value),
                                self.visit(node.slice),
                                )

    def visit_Index(self, node):
        return self.visit(node.value)

    def visit_List(self, node):
        return ir_ast.Array(self.visit(node.elts))

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
        return ir_ast.Constant('nil', None)

    def convert(self, node):
        return self.visit(node)
