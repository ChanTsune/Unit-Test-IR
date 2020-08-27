import sys
from json import load


class Generator:
    def load_node(self, path):
        with open(path, 'r') as f:
            return load(f)

    def main(self, argv):
        ir_def = self.load_node(argv[1])
        with open(argv[2], 'w') as f:
            self.exec_main(argv, ir_def, f)

    def exec_main(self, argv, ir_def, f):
        pass


class PythonGenerator(Generator):
    def exec_main(self, argv, ir_def, f):
        f.write("from .base import Node")
        for k, v in ir_def.items():
            f.write(f"""
class {k}(Node):
    def __init__(self,{",".join(k.lower()+"=None" if v.endswith('?') else k.lower() for k,v in v["fields"].items())}):
""")
            for field, type in v["fields"].items():
                f.write(f"""
        self.{field.lower()} = {field.lower()}
            """)
            f.write(f"""
    def serialize(self):
        return {{ '{k}':
            {{""")
            for field, type in v["fields"].items():
                f.write(f"'{field}':")
                if type in ("[]Node", "[]ArgumentDef", "[]FunctionDef", "[]Name", "[]KwArg"):
                    f.write(f"[i.serialize() for i in self.{field.lower()}],")
                elif type in ("Node", "ArgumentDef"):
                    f.write(f"self.{field.lower()}.serialize(),")
                elif type == "Node?":
                    f.write(
                        f"self.{field.lower()} if self.{field.lower()} is None else self.{field.lower()}.serialize(),")
                else:
                    f.write(
                        f"self.{field.lower()},"
                    )
                f.write("\n")
            f.write(f"""
            }}
         }}
""")
        with open(argv[3], 'w') as f:
            gen_deserializer(f, ir_def)


def gen_deserializer(f, object):
    f.write(f"""
from UTIR import ast
from UTIR.exception import InvalidFileFormatError


class ASTDeserializer:
    def deserialize(self, object):
        if 'Version' not in object.keys():
            raise InvalidFileFormatError("Key of 'Version' dose not exist.")
        if object['Version'] == 0:
            return self._deserialize_object(object)
        raise InvalidFileFormatError(
            "Unsupported Version %s" % object['Version'])

    def _deserialize_object(self, object):
    """)
    for cls, define in object.items():
        f.write(f"""
        if '{cls}' in object.keys():
            obj = object['{cls}']
            return ast.{cls}(
        """)
        for field, type in define['fields'].items():
            if type in ("[]Node", "[]ArgumentDef", "[]FunctionDef", "[]Name", "[]KwArg"):
                f.write(
                    f"""[self._deserialize_object(i) for i in obj['{field}']],""")
            elif type in ("Node", "ArgumentDef"):
                f.write(f"self._deserialize_object(obj['{field}']),")
            elif type in ("Node?",):
                f.write(
                    f"obj['{field}'] if obj['{field}'] is None else self._deserialize_object(obj['{field}']),")
            else:
                f.write(f"""obj['{field}'],""")
        f.write(""")""")


class KotlinGenerator(Generator):

    def exec_main(self, argv, ir_def, f):
        f.write("package Unit.Test.IR.ast.node")
        for cls, define in ir_def.items():
            f.write(f"""
data class {cls}(""")
            for field, type in define['fields'].items():
                field = field[:1].lower() + field[1:]
                if type.startswith("[]"):
                    f.write(f"""val {field}:List<{type[2:]}>,""")
                else:
                    f.write(f"""val {field}:{type},""")
            p = f.tell()
            f.seek(p-1)
            f.write(f"""):Node{{
}}
""")


def main(argv):
    # PythonGenerator().main(argv)
    KotlinGenerator().main(argv)


if __name__ == "__main__":
    main(sys.argv)
