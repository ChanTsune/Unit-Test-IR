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

    @classmethod
    def convert(cls, read_path, write_path):
        source_reader = cls.source_reader_class()
        python_ast = source_reader.readf(read_path)
        for transformer_class in cls.py_ast_transformer_classes:
            transformer = transformer_class()
            python_ast = transformer.visit(python_ast)
        ast_converter = cls.ast_converter_class()
        ir_ast = ast_converter.convert(python_ast)
        for transformer_class in cls.ir_ast_transformer_classes:
            transformer = transformer_class()
            ir_ast = transformer.visit(ir_ast)
        ast_serializer = cls.ir_ast_serializer_class()
        object = ast_serializer.serialize(ir_ast)
        object_dumper = cls.ir_ast_dumper_class()
        object_dumper.dumpf(write_path, object)


class IR2Code:
    ir_ast_loader_class = YamlLoader
    ir_ast_deserializer_class = ASTDeserializer
    ir_ast_transformer_classes = []
    ast_converter_class = IRAST2PyASTConverter
    py_ast_transformer_classes = []
    py_code_generator_class = PyASTToCodeGenerator

    @classmethod
    def convert(cls, read_path, write_path):
        loader = cls.ir_ast_loader_class()
        object = loader.loadf(read_path)
        deserializer = cls.ir_ast_deserializer_class()
        ir_ast = deserializer.deserialize(object)
        for transformer_class in cls.ir_ast_transformer_classes:
            transformer = transformer_class()
            ir_ast = transformer.visit(ir_ast)
        ast_converter = cls.ast_converter_class()
        python_ast = ast_converter.convert(ir_ast)
        for transformer_class in cls.py_ast_transformer_classes:
            transformer = transformer_class()
            python_ast = transformer.visit(python_ast)
        code_generator = cls.py_code_generator_class()
        code = code_generator.generate(python_ast)
        print(code)
