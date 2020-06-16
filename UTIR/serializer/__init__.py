from UTIR import ast


class ASTSerializer:

    def serialize(self, ir_ast):
        if not isinstance(ir_ast, ast.AST):
            raise TypeError(
                "%s '' argument must be an UTIR.ast.AST based class" % self.__class__.__name__)
        object = {'Version': 0}
        object.update(ir_ast.serialize())
        return object
