from unittest import TestCase


class IRSampleTest(TestCase):

    def test_case_one(self):
        a = 1
        b = 2
        c = 3
        self.assertEqual(a + b, c)

    def test_case_two(self):
        a = 1
        self.assertEqual(a, 1)

    def test_case_3(self):
        a = 1
        self.assertEqual(a, 1)
