import yaml


class YamlLoader:

    def loadf(self, path):
        with open(path, 'r') as f:
            return yaml.load(f, yaml.SafeLoader)
