import ast as py_ast

from UTIR import ast as ir_ast


class PyAST2IRASTConverter:

    def convert(self, python_ast):
        test_case_classes = self.get_test_case_class(python_ast)
        for test_case_class in test_case_classes:
            test_methods = self.get_test_methods(test_case_class)
            ir_suites = []
            for method in test_methods:
                expressions = self.parse_test_method(method)
                suite = ir_ast.TestSuite(
                    method.name, [self.map_exception(i) for i in expressions])
                ir_suites.append(suite)
            return ir_suites

    def get_test_case_class(self, python_ast):
        """"""
        if not isinstance(python_ast, py_ast.Module):
            return []
        classes = self._filter_test_class(python_ast.body)
        return classes

    def _filter_test_class(self, ast_list):
        def _filter(i):
            for i in i.bases:
                if i.id == 'TestCase':
                    return True
            return False
        classes = [i for i in ast_list if isinstance(
            i, py_ast.ClassDef) and _filter(i)]
        return classes

    def get_test_methods(self, test_case_class):
        """引数に期待するのは TestCase class"""
        body = test_case_class.body
        return [i for i in body if isinstance(i, py_ast.FunctionDef) and i.name.startswith('test')]

    def parse_test_method(self, test_method):
        """引数に期待するのは test_XX 関数"""
        return test_method.body

    def map_exception(self, python_ast):
        """"""
        if isinstance(python_ast, py_ast.Expr):
            python_ast = python_ast.value
        if isinstance(python_ast, py_ast.Name):
            return ir_ast.Name(python_ast.id)
        elif isinstance(python_ast, py_ast.Attribute):
            return ir_ast.Attribute(self.map_exception(python_ast.value), python_ast.attr)
        elif isinstance(python_ast, py_ast.Assign):
            if len(python_ast.targets) != 1:
                raise Exception('Unsupported multiple Assign')
            return ir_ast.AssignExpression(self.map_exception(python_ast.targets[0]),
                                           self.map_exception(python_ast.value))
        elif isinstance(python_ast, py_ast.Num):
            return ir_ast.Value('int', python_ast.n)
        elif isinstance(python_ast, py_ast.Call):
            if isinstance(python_ast.func, py_ast.Attribute):
                if isinstance(python_ast.func.value, py_ast.Name) and python_ast.func.attr.startswith('assert'):
                    if python_ast.func.value.id == 'self':
                        return self.map_assert(python_ast)
            return ir_ast.FunctionCall(self.map_exception(python_ast.func),
                                       [self.map_exception(i)
                                         for i in python_ast.args],
                                         {}
                                    #    {k: self.map_exception(v) for k, v in python_ast.keywords.items()} #TODO: kwargsのサポート
                                       )
        else:
            raise Exception('Unsupported AST Object %s found!' % python_ast)

    def map_assert(self, python_ast):
        """期待するのはself.assertXXの呼び出し py_ast.Call"""
        if not isinstance(python_ast, py_ast.Call):
            raise Exception('Invalid AST Object %s passed!' % python_ast)
        assert_kind = python_ast.func.attr[len('assert'):]
        if assert_kind not in ['Equal']:
            raise Exception('Unsupported assert kind: %s' % assert_kind)
        args_len = len(python_ast.args)
        if args_len == 2:
            return ir_ast.TestCase(assert_kind,
                                   self.map_exception(python_ast.args[0]),
                                   self.map_exception(python_ast.args[1]),
                                   )
        if args_len == 3:
            return ir_ast.TestCase(assert_kind,
                                self.map_exception(python_ast.args[0]),
                                self.map_exception(python_ast.args[1]),
                                python_ast.args[2],
                                )
