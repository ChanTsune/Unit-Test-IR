from .base import Expression


class ClassDef(Exception):
    """UTIR ClassDef Exception"""

    def __init__(self, name, fields, body):
        self.name = name
        self.fields = fields
        self.body = body

    def serialize(self):
        return {
            'ClassDef': {
                'Name': self.name,
                'Fields': [i.serialize() for i in self.fields],
                'Body': [i.serialize() for i in self.body],
            }
        }

    def _dump(self):
        return f'name={repr(self.name)},fields={self.fields}'
