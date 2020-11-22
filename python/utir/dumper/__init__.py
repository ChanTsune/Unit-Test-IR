import json

import yaml


class YamlDumper:

    def dumpf(self, path, object):
        with open(path, 'w') as f:
            yaml.dump(object, f)

class JsonDumper:

    def dumpf(self, path, object):
        with open(path, 'w') as f:
            json.dump(object, f, indent=2)
