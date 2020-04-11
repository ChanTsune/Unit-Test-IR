import yaml


class YamlLoader:

    def loadf(self, file):
        with open(file, 'r') as f:
            return yaml.load(f, yaml.SafeLoader)

    def dumpf(self, file, obj):
        with open(file, 'w') as f:
            yaml.dump(obj, f)
