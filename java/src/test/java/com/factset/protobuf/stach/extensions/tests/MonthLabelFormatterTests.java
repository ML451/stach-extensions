package com.factset.protobuf.stach.extensions.tests;

import com.factset.protobuf.stach.extensions.v2.MonthLabelFormatter;

import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;

public class MonthLabelFormatterTests {

    @Test
    public void testAllLabelsReturnsTwelveItems() {
        List<String> labels = MonthLabelFormatter.allLabels();
        Assert.assertEquals(labels.size(), 12);
    }

    @Test
    public void testAllLabelsAreUnique() {
        List<String> labels = MonthLabelFormatter.allLabels();
        Assert.assertEquals(new HashSet<>(labels).size(), 12);
    }

    @Test
    public void testAllLabelsExpectedValues() {
        List<String> expected = Arrays.asList(
            "J\u00b9", "F", "M\u00b9", "A\u00b9", "M\u00b2", "J\u00b2",
            "J\u00b3", "A\u00b2", "S", "O", "N", "D"
        );
        Assert.assertEquals(MonthLabelFormatter.allLabels(), expected);
    }

    @Test
    public void testUniqueMonthsHaveNoSuperscript() {
        // Feb, Sep, Oct, Nov, Dec have unique first letters
        int[] uniqueMonths = {2, 9, 10, 11, 12};
        for (int month : uniqueMonths) {
            String label = MonthLabelFormatter.format(month);
            Assert.assertEquals(label.length(), 1, "Month " + month + " should be a single character");
        }
    }

    @Test
    public void testAmbiguousMonthsHaveSuperscript() {
        // Jan, Mar, Apr, May, Jun, Jul, Aug share first letters
        int[] ambiguousMonths = {1, 3, 4, 5, 6, 7, 8};
        for (int month : ambiguousMonths) {
            String label = MonthLabelFormatter.format(month);
            Assert.assertEquals(label.length(), 2, "Month " + month + " should have a superscript");
        }
    }

    @Test
    public void testJanuary() {
        Assert.assertEquals(MonthLabelFormatter.format(1), "J\u00b9");
    }

    @Test
    public void testFebruary() {
        Assert.assertEquals(MonthLabelFormatter.format(2), "F");
    }

    @Test
    public void testMarch() {
        Assert.assertEquals(MonthLabelFormatter.format(3), "M\u00b9");
    }

    @Test
    public void testApril() {
        Assert.assertEquals(MonthLabelFormatter.format(4), "A\u00b9");
    }

    @Test
    public void testMay() {
        Assert.assertEquals(MonthLabelFormatter.format(5), "M\u00b2");
    }

    @Test
    public void testJune() {
        Assert.assertEquals(MonthLabelFormatter.format(6), "J\u00b2");
    }

    @Test
    public void testJuly() {
        Assert.assertEquals(MonthLabelFormatter.format(7), "J\u00b3");
    }

    @Test
    public void testAugust() {
        Assert.assertEquals(MonthLabelFormatter.format(8), "A\u00b2");
    }

    @Test
    public void testSeptember() {
        Assert.assertEquals(MonthLabelFormatter.format(9), "S");
    }

    @Test
    public void testOctober() {
        Assert.assertEquals(MonthLabelFormatter.format(10), "O");
    }

    @Test
    public void testNovember() {
        Assert.assertEquals(MonthLabelFormatter.format(11), "N");
    }

    @Test
    public void testDecember() {
        Assert.assertEquals(MonthLabelFormatter.format(12), "D");
    }

    @Test(expectedExceptions = IllegalArgumentException.class)
    public void testInvalidMonthZero() {
        MonthLabelFormatter.format(0);
    }

    @Test(expectedExceptions = IllegalArgumentException.class)
    public void testInvalidMonthThirteen() {
        MonthLabelFormatter.format(13);
    }

    @Test(expectedExceptions = IllegalArgumentException.class)
    public void testInvalidMonthNegative() {
        MonthLabelFormatter.format(-1);
    }
}
