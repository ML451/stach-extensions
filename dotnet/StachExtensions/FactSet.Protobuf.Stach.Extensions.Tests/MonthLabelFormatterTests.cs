using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using FactSet.Protobuf.Stach.Extensions.V2;

namespace FactSet.Protobuf.Stach.Extensions.Tests
{
    [TestClass]
    public class MonthLabelFormatterTests
    {
        [TestMethod]
        public void TestAllLabelsReturnsTwelveItems()
        {
            var labels = MonthLabelFormatter.AllLabels();
            Assert.AreEqual(12, labels.Count);
        }

        [TestMethod]
        public void TestAllLabelsAreUnique()
        {
            var labels = MonthLabelFormatter.AllLabels();
            Assert.AreEqual(12, new HashSet<string>(labels).Count);
        }

        [TestMethod]
        public void TestAllLabelsExpectedValues()
        {
            var expected = new List<string>
            {
                "J\u00b9", "F", "M\u00b9", "A\u00b9", "M\u00b2", "J\u00b2",
                "J\u00b3", "A\u00b2", "S", "O", "N", "D"
            };
            var actual = MonthLabelFormatter.AllLabels();
            CollectionAssert.AreEqual(expected, actual.ToList());
        }

        [TestMethod]
        public void TestUniqueMonthsHaveNoSuperscript()
        {
            int[] uniqueMonths = { 2, 9, 10, 11, 12 };
            foreach (int month in uniqueMonths)
            {
                string label = MonthLabelFormatter.Format(month);
                Assert.AreEqual(1, label.Length, $"Month {month} should be a single character");
            }
        }

        [TestMethod]
        public void TestAmbiguousMonthsHaveSuperscript()
        {
            int[] ambiguousMonths = { 1, 3, 4, 5, 6, 7, 8 };
            foreach (int month in ambiguousMonths)
            {
                string label = MonthLabelFormatter.Format(month);
                Assert.AreEqual(2, label.Length, $"Month {month} should have a superscript");
            }
        }

        [TestMethod]
        public void TestJanuary() => Assert.AreEqual("J\u00b9", MonthLabelFormatter.Format(1));

        [TestMethod]
        public void TestFebruary() => Assert.AreEqual("F", MonthLabelFormatter.Format(2));

        [TestMethod]
        public void TestMarch() => Assert.AreEqual("M\u00b9", MonthLabelFormatter.Format(3));

        [TestMethod]
        public void TestApril() => Assert.AreEqual("A\u00b9", MonthLabelFormatter.Format(4));

        [TestMethod]
        public void TestMay() => Assert.AreEqual("M\u00b2", MonthLabelFormatter.Format(5));

        [TestMethod]
        public void TestJune() => Assert.AreEqual("J\u00b2", MonthLabelFormatter.Format(6));

        [TestMethod]
        public void TestJuly() => Assert.AreEqual("J\u00b3", MonthLabelFormatter.Format(7));

        [TestMethod]
        public void TestAugust() => Assert.AreEqual("A\u00b2", MonthLabelFormatter.Format(8));

        [TestMethod]
        public void TestSeptember() => Assert.AreEqual("S", MonthLabelFormatter.Format(9));

        [TestMethod]
        public void TestOctober() => Assert.AreEqual("O", MonthLabelFormatter.Format(10));

        [TestMethod]
        public void TestNovember() => Assert.AreEqual("N", MonthLabelFormatter.Format(11));

        [TestMethod]
        public void TestDecember() => Assert.AreEqual("D", MonthLabelFormatter.Format(12));

        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void TestInvalidMonthZero() => MonthLabelFormatter.Format(0);

        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void TestInvalidMonthThirteen() => MonthLabelFormatter.Format(13);

        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void TestInvalidMonthNegative() => MonthLabelFormatter.Format(-1);
    }
}
