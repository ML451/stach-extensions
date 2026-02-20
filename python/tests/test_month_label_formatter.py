import unittest

from fds.protobuf.stach.extensions.v2.MonthLabelFormatter import MonthLabelFormatter


class MonthLabelFormatterTests(unittest.TestCase):

    def test_all_labels_returns_twelve_items(self):
        labels = MonthLabelFormatter.all_labels()
        self.assertEqual(len(labels), 12)

    def test_all_labels_are_unique(self):
        labels = MonthLabelFormatter.all_labels()
        self.assertEqual(len(set(labels)), 12)

    def test_all_labels_expected_values(self):
        expected = [
            "J\u00b9", "F", "M\u00b9", "A\u00b9", "M\u00b2", "J\u00b2",
            "J\u00b3", "A\u00b2", "S", "O", "N", "D",
        ]
        self.assertEqual(MonthLabelFormatter.all_labels(), expected)

    def test_unique_months_have_no_superscript(self):
        # Feb, Sep, Oct, Nov, Dec have unique first letters
        for month in [2, 9, 10, 11, 12]:
            label = MonthLabelFormatter.format(month)
            self.assertEqual(len(label), 1, f"Month {month} should be a single character")

    def test_ambiguous_months_have_superscript(self):
        # Jan, Mar, Apr, May, Jun, Jul, Aug share first letters
        for month in [1, 3, 4, 5, 6, 7, 8]:
            label = MonthLabelFormatter.format(month)
            self.assertEqual(len(label), 2, f"Month {month} should have a superscript")

    def test_january(self):
        self.assertEqual(MonthLabelFormatter.format(1), "J\u00b9")

    def test_february(self):
        self.assertEqual(MonthLabelFormatter.format(2), "F")

    def test_march(self):
        self.assertEqual(MonthLabelFormatter.format(3), "M\u00b9")

    def test_april(self):
        self.assertEqual(MonthLabelFormatter.format(4), "A\u00b9")

    def test_may(self):
        self.assertEqual(MonthLabelFormatter.format(5), "M\u00b2")

    def test_june(self):
        self.assertEqual(MonthLabelFormatter.format(6), "J\u00b2")

    def test_july(self):
        self.assertEqual(MonthLabelFormatter.format(7), "J\u00b3")

    def test_august(self):
        self.assertEqual(MonthLabelFormatter.format(8), "A\u00b2")

    def test_september(self):
        self.assertEqual(MonthLabelFormatter.format(9), "S")

    def test_october(self):
        self.assertEqual(MonthLabelFormatter.format(10), "O")

    def test_november(self):
        self.assertEqual(MonthLabelFormatter.format(11), "N")

    def test_december(self):
        self.assertEqual(MonthLabelFormatter.format(12), "D")

    def test_invalid_month_zero(self):
        with self.assertRaises(ValueError):
            MonthLabelFormatter.format(0)

    def test_invalid_month_thirteen(self):
        with self.assertRaises(ValueError):
            MonthLabelFormatter.format(13)

    def test_invalid_month_negative(self):
        with self.assertRaises(ValueError):
            MonthLabelFormatter.format(-1)


if __name__ == "__main__":
    unittest.main()
