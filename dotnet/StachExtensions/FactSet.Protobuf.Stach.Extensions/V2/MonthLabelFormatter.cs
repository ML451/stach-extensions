using System;
using System.Collections.Generic;

namespace FactSet.Protobuf.Stach.Extensions.V2
{
    /// <summary>
    /// Generates compact, unambiguous single-letter month axis labels using Unicode
    /// superscript characters to disambiguate months that share the same first
    /// letter (J=Jan/Jun/Jul, M=Mar/May, A=Apr/Aug).
    ///
    /// Result: J¹ F M¹ A¹ M² J² J³ A² S O N D
    /// </summary>
    public static class MonthLabelFormatter
    {
        private static readonly string[] Letters =
        {
            null, "J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"
        };

        // Unicode superscripts: \u00b9 = ¹, \u00b2 = ², \u00b3 = ³
        private static readonly string[] Superscripts =
        {
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

        /// <summary>
        /// Returns a compact axis label for the given month number (1-12).
        /// </summary>
        /// <param name="monthNumber">Month number, 1 = January through 12 = December.</param>
        /// <returns>A single-letter label, with a Unicode superscript suffix for
        /// months whose first letter is shared by another month.</returns>
        /// <exception cref="ArgumentOutOfRangeException">Thrown when monthNumber is not in 1..12.</exception>
        public static string Format(int monthNumber)
        {
            if (monthNumber < 1 || monthNumber > 12)
            {
                throw new ArgumentOutOfRangeException(
                    nameof(monthNumber),
                    monthNumber,
                    "monthNumber must be between 1 and 12");
            }

            return Letters[monthNumber] + Superscripts[monthNumber];
        }

        /// <summary>
        /// Returns a read-only list of 12 formatted month labels,
        /// index 0 = January through index 11 = December.
        /// </summary>
        /// <returns>List of 12 strings.</returns>
        public static IReadOnlyList<string> AllLabels()
        {
            var labels = new List<string>(12);
            for (int m = 1; m <= 12; m++)
            {
                labels.Add(Format(m));
            }

            return labels.AsReadOnly();
        }
    }
}
