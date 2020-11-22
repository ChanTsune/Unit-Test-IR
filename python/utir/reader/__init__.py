import ast


class SourceReader:
    def readf(self, path):
        with open(path, 'r') as f:
            return self.reads(f.read())

    def reads(self, string):
        return ast.parse(string)
