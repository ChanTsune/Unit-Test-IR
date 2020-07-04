import sys
from json import load


def _main(argv):
    with open(argv[1], 'r') as f:
        ir_def = load(f)
    with open(argv[2], 'w') as f:
        for k, v in ir_def.items():
            f.write(f"""
from .base import Node

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


def main(argv):
    if len(argv) <= 2:
        return
    _main(argv)


if __name__ == "__main__":
    main(sys.argv)
