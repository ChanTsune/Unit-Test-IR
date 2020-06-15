import yaml


class Dumper:

    def dumpf(self, path, object):
        with open(path, 'w') as f:
            yaml.dump(object, f)
