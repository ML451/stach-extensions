package com.factset.protobuf.stach.extensions.v2;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Generates compact, unambiguous single-letter month axis labels using Unicode
 * superscript characters to disambiguate months that share the same first
 * letter (J=Jan/Jun/Jul, M=Mar/May, A=Apr/Aug).
 *
 * Result: J¹ F M¹ A¹ M² J² J³ A² S O N D
 */
public class MonthLabelFormatter {

    private static final String[] LETTERS = {
        null, "J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"
    };

    // Unicode superscripts: \u00b9 = ¹, \u00b2 = ², \u00b3 = ³
    private static final String[] SUPERSCRIPTS = {
        null,           // index 0 unused
        "\u00b9",       // 1  Jan  -> J¹
        "",             // 2  Feb  -> F
        "\u00b9",       // 3  Mar  -> M¹
        "\u00b9",       // 4  Apr  -> A¹
        "\u00b2",       // 5  May  -> M²
        "\u00b2",       // 6  Jun  -> J²
        "\u00b3",       // 7  Jul  -> J³
        "\u00b2",       // 8  Aug  -> A²
        "",             // 9  Sep  -> S
        "",             // 10 Oct  -> O
        "",             // 11 Nov  -> N
        "",             // 12 Dec  -> D
    };

    /**
     * Returns a compact axis label for the given month number (1-12).
     *
     * @param monthNumber Month number, 1 = January through 12 = December.
     * @return A single-letter label, with a Unicode superscript suffix for
     *         months whose first letter is shared by another month.
     * @throws IllegalArgumentException if monthNumber is not in 1..12.
     */
    public static String format(int monthNumber) {
        if (monthNumber < 1 || monthNumber > 12) {
            throw new IllegalArgumentException(
                "monthNumber must be between 1 and 12, got " + monthNumber);
        }
        return LETTERS[monthNumber] + SUPERSCRIPTS[monthNumber];
    }

    /**
     * Returns an unmodifiable list of 12 formatted month labels,
     * index 0 = January through index 11 = December.
     *
     * @return List of 12 strings.
     */
    public static List<String> allLabels() {
        List<String> labels = new ArrayList<>(12);
        for (int m = 1; m <= 12; m++) {
            labels.add(format(m));
        }
        return Collections.unmodifiableList(labels);
    }
}
