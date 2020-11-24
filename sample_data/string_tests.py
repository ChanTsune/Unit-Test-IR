# """
# Common tests shared by test_unicode, test_userstring and test_bytes.
# """

import unittest, string, sys, struct
from test import support
from collections import UserList


class BaseTest:

    # check that obj.method(*args) returns result
    def checkequal(self, result, obj, methodname, *args, **kwargs):
        result = self.fixtype(result)
        obj = self.fixtype(obj)
        args = self.fixtype(args)
        kwargs = {k: self.fixtype(v) for k,v in kwargs.items()}
        realresult = getattr(obj, methodname)(*args, **kwargs)
        self.assertEqual(
            result,
            realresult
        )
        # if the original is returned make sure that
        # this doesn't happen with subclasses
        if obj is realresult:
            try:
                class subtype(self.__class__.type2test):
                    pass
            except TypeError:
                pass  # Skip this if we can't subclass
            else:
                obj = subtype(obj)
                realresult = getattr(obj, methodname)(*args)
                self.assertIsNot(obj, realresult)

    # check that obj.method(*args) raises exc
    def checkraises(self, exc, obj, methodname, *args):
        obj = self.fixtype(obj)
        args = self.fixtype(args)
        with self.assertRaises(exc) as cm:
            getattr(obj, methodname)(*args)
        self.assertNotEqual(str(cm.exception), '')

    # call obj.method(*args) without any checks
    def checkcall(self, obj, methodname, *args):
        obj = self.fixtype(obj)
        args = self.fixtype(args)
        getattr(obj, methodname)(*args)

    def test_count(self):
        self.checkequal(3, 'aaa', 'count', 'a')
        self.checkequal(0, 'aaa', 'count', 'b')
        self.checkequal(3, 'aaa', 'count', 'a')
        self.checkequal(0, 'aaa', 'count', 'b')
        self.checkequal(3, 'aaa', 'count', 'a')
        self.checkequal(0, 'aaa', 'count', 'b')
        self.checkequal(0, 'aaa', 'count', 'b')
        self.checkequal(2, 'aaa', 'count', 'a', 1)
        self.checkequal(0, 'aaa', 'count', 'a', 10)
        self.checkequal(1, 'aaa', 'count', 'a', -1)
        self.checkequal(3, 'aaa', 'count', 'a', -10)
        self.checkequal(1, 'aaa', 'count', 'a', 0, 1)
        self.checkequal(3, 'aaa', 'count', 'a', 0, 10)
        self.checkequal(2, 'aaa', 'count', 'a', 0, -1)
        self.checkequal(0, 'aaa', 'count', 'a', 0, -10)
        self.checkequal(3, 'aaa', 'count', '', 1)
        self.checkequal(1, 'aaa', 'count', '', 3)
        self.checkequal(0, 'aaa', 'count', '', 10)
        self.checkequal(2, 'aaa', 'count', '', -1)
        self.checkequal(4, 'aaa', 'count', '', -10)

        self.checkequal(1, '', 'count', '')
        self.checkequal(0, '', 'count', '', 1, 1)
        self.checkequal(0, '', 'count', '', sys.maxsize, 0)

        self.checkequal(0, '', 'count', 'xx')
        self.checkequal(0, '', 'count', 'xx', 1, 1)
        self.checkequal(0, '', 'count', 'xx', sys.maxsize, 0)

        self.checkraises(TypeError, 'hello', 'count')

    def test_find(self):
        self.checkequal(0, 'abcdefghiabc', 'find', 'abc')
        self.checkequal(9, 'abcdefghiabc', 'find', 'abc', 1)
        self.checkequal(-1, 'abcdefghiabc', 'find', 'def', 4)

        self.checkequal(0, 'abc', 'find', '', 0)
        self.checkequal(3, 'abc', 'find', '', 3)
        self.checkequal(-1, 'abc', 'find', '', 4)

        # to check the ability to pass None as defaults
        self.checkequal( 2, 'rrarrrrrrrrra', 'find', 'a')
        self.checkequal(12, 'rrarrrrrrrrra', 'find', 'a', 4)
        self.checkequal(-1, 'rrarrrrrrrrra', 'find', 'a', 4, 6)
        self.checkequal(12, 'rrarrrrrrrrra', 'find', 'a', 4, None)
        self.checkequal( 2, 'rrarrrrrrrrra', 'find', 'a', None, 6)

        self.checkraises(TypeError, 'hello', 'find')


        self.checkequal(0, '', 'find', '')
        self.checkequal(-1, '', 'find', '', 1, 1)
        self.checkequal(-1, '', 'find', '', sys.maxsize, 0)

        self.checkequal(-1, '', 'find', 'xx')
        self.checkequal(-1, '', 'find', 'xx', 1, 1)
        self.checkequal(-1, '', 'find', 'xx', sys.maxsize, 0)

        # issue 7458
        self.checkequal(-1, 'ab', 'find', 'xxx', sys.maxsize + 1, 0)

    def test_rfind(self):
        self.checkequal(9,  'abcdefghiabc', 'rfind', 'abc')
        self.checkequal(12, 'abcdefghiabc', 'rfind', '')
        self.checkequal(0, 'abcdefghiabc', 'rfind', 'abcd')
        self.checkequal(-1, 'abcdefghiabc', 'rfind', 'abcz')

        self.checkequal(3, 'abc', 'rfind', '', 0)
        self.checkequal(3, 'abc', 'rfind', '', 3)
        self.checkequal(-1, 'abc', 'rfind', '', 4)

        # to check the ability to pass None as defaults
        self.checkequal(12, 'rrarrrrrrrrra', 'rfind', 'a')
        self.checkequal(12, 'rrarrrrrrrrra', 'rfind', 'a', 4)
        self.checkequal(-1, 'rrarrrrrrrrra', 'rfind', 'a', 4, 6)
        self.checkequal(12, 'rrarrrrrrrrra', 'rfind', 'a', 4, None)
        self.checkequal( 2, 'rrarrrrrrrrra', 'rfind', 'a', None, 6)

        self.checkraises(TypeError, 'hello', 'rfind')

        # issue 7458
        self.checkequal(-1, 'ab', 'rfind', 'xxx', sys.maxsize + 1, 0)

        # issue #15534
        self.checkequal(0, '<......\u043c...', "rfind", "<")

    def test_index(self):
        self.checkequal(0, 'abcdefghiabc', 'index', '')
        self.checkequal(3, 'abcdefghiabc', 'index', 'def')
        self.checkequal(0, 'abcdefghiabc', 'index', 'abc')
        self.checkequal(9, 'abcdefghiabc', 'index', 'abc', 1)

        self.checkraises(ValueError, 'abcdefghiabc', 'index', 'hib')
        self.checkraises(ValueError, 'abcdefghiab', 'index', 'abc', 1)
        self.checkraises(ValueError, 'abcdefghi', 'index', 'ghi', 8)
        self.checkraises(ValueError, 'abcdefghi', 'index', 'ghi', -1)

        # to check the ability to pass None as defaults
        self.checkequal( 2, 'rrarrrrrrrrra', 'index', 'a')
        self.checkequal(12, 'rrarrrrrrrrra', 'index', 'a', 4)
        self.checkraises(ValueError, 'rrarrrrrrrrra', 'index', 'a', 4, 6)
        self.checkequal(12, 'rrarrrrrrrrra', 'index', 'a', 4, None)
        self.checkequal( 2, 'rrarrrrrrrrra', 'index', 'a', None, 6)

        self.checkraises(TypeError, 'hello', 'index')

    def test_rindex(self):
        self.checkequal(12, 'abcdefghiabc', 'rindex', '')
        self.checkequal(3,  'abcdefghiabc', 'rindex', 'def')
        self.checkequal(9,  'abcdefghiabc', 'rindex', 'abc')
        self.checkequal(0,  'abcdefghiabc', 'rindex', 'abc', 0, -1)

        self.checkraises(ValueError, 'abcdefghiabc', 'rindex', 'hib')
        self.checkraises(ValueError, 'defghiabc', 'rindex', 'def', 1)
        self.checkraises(ValueError, 'defghiabc', 'rindex', 'abc', 0, -1)
        self.checkraises(ValueError, 'abcdefghi', 'rindex', 'ghi', 0, 8)
        self.checkraises(ValueError, 'abcdefghi', 'rindex', 'ghi', 0, -1)

        # to check the ability to pass None as defaults
        self.checkequal(12, 'rrarrrrrrrrra', 'rindex', 'a')
        self.checkequal(12, 'rrarrrrrrrrra', 'rindex', 'a', 4)
        self.checkraises(ValueError, 'rrarrrrrrrrra', 'rindex', 'a', 4, 6)
        self.checkequal(12, 'rrarrrrrrrrra', 'rindex', 'a', 4, None)
        self.checkequal( 2, 'rrarrrrrrrrra', 'rindex', 'a', None, 6)

        self.checkraises(TypeError, 'hello', 'rindex')
