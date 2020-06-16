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
                                     i) for i in test_suite['Expressions']],
                                 [self._deserialize_object(i) for i in test_suite['TestCases']])
        if 'TestCase' in object.keys():
            test_case = object.get('TestCase')
            return ast.TestCase(test_case['Assert'],
                                self._deserialize_object(
                                    test_case['Excepted']),
                                self._deserialize_object(
                                    test_case['Actual']))
        if 'Value' in object.keys():
            value = object.get('Value')
            return ast.Value(value['Type'], value['Value'])
        if 'Name' in object.keys():
            name = object.get('Name')
            return ast.Name(name['Name'])
        if 'FunctionCall' in object.keys():
            function_call = object.get('FunctionCall')
            return ast.FunctionCall(function_call['Name'], {k: self._deserialize_object(v) for k, v in function_call['Args'].items()})
