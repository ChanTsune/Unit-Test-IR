import sys
from .loader import YamlLoader
from .deserializer import ASTDeserializer

version = "0.0.0"

def main_yaml(argv):
    parser = YamlLoader()
    obj = parser.load(argv[1])
    parser.dump(argv[2], obj)

def main(argv):
    pass

def main_desrialize(argv):
    if len(argv) < 1:
        return 
    loader = YamlLoader()
    object = loader.loadf(argv[1])
    deserializer = ASTDeserializer()
    ast = deserializer.deserialize(object)
    print(ast)

if __name__ == "__main__":
    main_desrialize(sys.argv)
