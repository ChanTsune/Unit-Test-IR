import sys
from .loader import YamlLoader

version = "0.0.0"


if __name__ == "__main__":
    parser = YamlLoader()
    obj = parser.load(sys.argv[1])
    parser.dump(sys.argv[2], obj)
