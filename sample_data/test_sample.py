from unittest import TestCase


class IRSampleTest(TestCase):

    def test_case_one(self):
        a = 1
        b = 2
        c = 3
        self.assertEqual(a + b, c)
