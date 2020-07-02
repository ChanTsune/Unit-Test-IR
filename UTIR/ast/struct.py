from .base import Expression


class ClassDef(Exception):
    """UTIR ClassDef Exception"""

    def __init__(self, name, bases, fields, body):
        self.name = name
        self.bases = bases
        self.fields = fields
        self.body = body

    def serialize(self):
        return {
            'ClassDef': {
                'Name': self.name,
                'Bases': self.bases,
                'Fields': [i.serialize() for i in self.fields],
                'Body': [i.serialize() for i in self.body],
            }
        }

    def _dump(self):
        return f'name={repr(self.name)},fields={self.fields}'
