
from utir import ast
from utir.exception import InvalidFileFormatError


class ASTDeserializer:
    def deserialize(self, object):
        if 'Version' not in object.keys():
            raise InvalidFileFormatError("Key of 'Version' dose not exist.")
        if object['Version'] == 0:
            return self._deserialize_object(object)
        raise InvalidFileFormatError(
            "Unsupported Version %s" % object['Version'])

    def _deserialize_object(self, object):

        if 'File' in object.keys():
            obj = object['File']
            return ast.File(
                [self._deserialize_object(i) for i in obj['Body']],)
        if 'FunctionDef' in object.keys():
            obj = object['FunctionDef']
            return ast.FunctionDef(
                obj['Name'], [self._deserialize_object(i) for i in obj['Args']], [self._deserialize_object(i) for i in obj['Body']],)
        if 'ClassDef' in object.keys():
            obj = object['ClassDef']
            return ast.ClassDef(
                obj['Name'], obj['Bases'], [self._deserialize_object(i) for i in obj['Fields']], [self._deserialize_object(i) for i in obj['Body']],)
        if 'Return' in object.keys():
            obj = object['Return']
            return ast.Return(
                self._deserialize_object(obj['Value']),)
        if 'Assign' in object.keys():
            obj = object['Assign']
            return ast.Assign(
                self._deserialize_object(obj['Target']), self._deserialize_object(obj['Value']),)
        if 'For' in object.keys():
            obj = object['For']
            return ast.For(
                self._deserialize_object(obj['Value']), self._deserialize_object(obj['Generator']), [self._deserialize_object(i) for i in obj['Body']],)
        if 'Block' in object.keys():
            obj = object['Block']
            return ast.Block(
                [self._deserialize_object(i) for i in obj['Body']],)
        if 'Try' in object.keys():
            obj = object['Try']
            return ast.Try(
                [self._deserialize_object(i) for i in obj['Body']],)
        if 'Raise' in object.keys():
            obj = object['Raise']
            return ast.Raise(
                self._deserialize_object(obj['Value']),)
        if 'Catch' in object.keys():
            obj = object['Catch']
            return ast.Catch(
                [self._deserialize_object(i) for i in obj['Body']],)
        if 'BoolOp' in object.keys():
            obj = object['BoolOp']
            return ast.BoolOp(
                obj['Kind'], self._deserialize_object(obj['Left']), self._deserialize_object(obj['Right']),)
        if 'BinOp' in object.keys():
            obj = object['BinOp']
            return ast.BinOp(
                obj['Kind'], self._deserialize_object(obj['Left']), self._deserialize_object(obj['Right']),)
        if 'UnaryOp' in object.keys():
            obj = object['UnaryOp']
            return ast.UnaryOp(
                obj['Kind'], self._deserialize_object(obj['Value']),)
        if 'Constant' in object.keys():
            obj = object['Constant']
            return ast.Constant(
                obj['Kind'], obj['Value'],)
        if 'Attribute' in object.keys():
            obj = object['Attribute']
            return ast.Attribute(
                self._deserialize_object(obj['Value']), obj['Attribute'],)
        if 'Subscript' in object.keys():
            obj = object['Subscript']
            return ast.Subscript(
                self._deserialize_object(obj['Value']), self._deserialize_object(obj['Index']),)
        if 'Name' in object.keys():
            obj = object['Name']
            return ast.Name(
                obj['Name'], obj['Kind'],)
        if 'Array' in object.keys():
            obj = object['Array']
            return ast.Array(
                [self._deserialize_object(i) for i in obj['Values']],)
        if 'Tuple' in object.keys():
            obj = object['Tuple']
            return ast.Tuple(
                [self._deserialize_object(i) for i in obj['Values']],)
        if 'Call' in object.keys():
            obj = object['Call']
            return ast.Call(
                self._deserialize_object(obj['Value']), [self._deserialize_object(i) for i in obj['Args']], [self._deserialize_object(i) for i in obj['KwArgs']],)
        if 'ArgumentDef' in object.keys():
            obj = object['ArgumentDef']
            return ast.ArgumentDef(
                obj['Key'], obj['Default'] if obj['Default'] is None else self._deserialize_object(obj['Default']),)
        if 'KwArg' in object.keys():
            obj = object['KwArg']
            return ast.KwArg(
                obj['Key'], self._deserialize_object(obj['Value']),)
