from .reader import SourceReader
from .converter import PyAST2IRASTConverter, IRAST2PyASTConverter
from .serializer import ASTSerializer
from .deserializer import ASTDeserializer
from .dumper import YamlDumper
from .loader import YamlLoader
from .generator import PyASTToCodeGenerator
from .transformer import DefaultIRTransformer

version = "0.0.0"

__all__ = ['Code2IR', 'IR2Code']


class Code2IR:
    source_reader_class = SourceReader
    py_ast_transformer_classes = []
    ast_converter_class = PyAST2IRASTConverter
    ir_ast_transformer_classes = [DefaultIRTransformer]
    ir_ast_serializer_class = ASTSerializer
    ir_ast_dumper_class = YamlDumper

    def convert(self, read_path, write_path):
        source_reader = self.source_reader_class()
        python_ast = source_reader.readf(read_path)
        for transformer_class in self.py_ast_transformer_classes:
            transformer = transformer_class()
            python_ast = transformer.visit(python_ast)
        ast_converter = self.ast_converter_class()
        ir_ast = ast_converter.convert(python_ast)
        for transformer_class in self.ir_ast_transformer_classes:
            transformer = transformer_class()
            ir_ast = transformer.visit(ir_ast)
        ast_serializer = self.ir_ast_serializer_class()
        object = ast_serializer.serialize(ir_ast)
        object_dumper = self.ir_ast_dumper_class()
        object_dumper.dumpf(write_path, object)


class IR2Code:
    ir_ast_loader_class = YamlLoader
    ir_ast_deserializer_class = ASTDeserializer
    ir_ast_transformer_classes = []
    ast_converter_class = IRAST2PyASTConverter
    py_ast_transformer_classes = []
    py_code_generator_class = PyASTToCodeGenerator

    def convert(self, read_path, write_path):
        loader = self.ir_ast_loader_class()
        object = loader.loadf(read_path)
        deserializer = self.ir_ast_deserializer_class()
        ir_ast = deserializer.deserialize(object)
        for transformer_class in self.ir_ast_transformer_classes:
            transformer = transformer_class()
            ir_ast = transformer.visit(ir_ast)
        ast_converter = self.ast_converter_class()
        python_ast = ast_converter.convert(ir_ast)
        for transformer_class in self.py_ast_transformer_classes:
            transformer = transformer_class()
            python_ast = transformer.visit(python_ast)
        code_generator = self.py_code_generator_class()
        code = code_generator.generate(python_ast)
        print(code)
