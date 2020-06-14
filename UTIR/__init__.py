import sys
from .loader import YamlLoader

version = "0.0.0"

def main_yaml(argv):
    parser = YamlLoader()
    obj = parser.load(argv[1])
    parser.dump(argv[2], obj)

def main(argv):
    pass


if __name__ == "__main__":
    main(sys.argv)
