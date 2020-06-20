import yaml


class YamlDumper:

    def dumpf(self, path, object):
        with open(path, 'w') as f:
            yaml.dump(object, f)

default_yaml_dumper = YamlDumper()
