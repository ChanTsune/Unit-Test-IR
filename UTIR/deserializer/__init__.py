from UTIR import ast
from UTIR.exception import InvalidFileFormatError


class ASTDeserializer:
    def deserialize(self, object):
        if 'Version' not in object.keys():
            raise InvalidFileFormatError("Key of 'Version' dose not exist.")
        if object['Version'] == 0:
            return self._deserialize_object(object)
        raise InvalidFileFormatError(
            "Unsupported Version %s" % object['Version'])

    def _deserialize_object(self, object):
        if 'TestSuite' in object.keys():
            test_suite = object['TestSuite']
            return ast.TestSuite(test_suite['Name'],
                                 [self._deserialize_object(
                                     i) for i in test_suite['Expressions']])
        elif 'TestCase' in object.keys():
            test_case = object.get('TestCase')
            return ast.TestCase(test_case['Assert'],
                                self._deserialize_object(
                                    test_case['Excepted']),
                                self._deserialize_object(
                                    test_case['Actual']))
        elif 'Value' in object.keys():
            value = object.get('Value')
            return ast.Value(value['Kind'], value['Value'])
        elif 'Name' in object.keys():
            name = object.get('Name')
            return ast.Name(name['Name'])
        elif 'FunctionCall' in object.keys():
            function_call = object.get('FunctionCall')
            return ast.FunctionCall(self._deserialize_object(function_call['Func']),
                                    [self._deserialize_object(i) for i in function_call['Args']],
                                    {k: self._deserialize_object(v) for k, v in function_call['KwArgs'].items()})
        elif 'Assign' in object.keys():
            assign = object.get('Assign')
            return ast.AssignExpression(self._deserialize_object(assign['Target']),
                                        self._deserialize_object(assign['Value']))
        else:
            raise Exception('Unsupported key %s' % object.keys())
