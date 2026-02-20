class MonthLabelFormatter:
    """Generates compact, unambiguous single-letter month axis labels using
    Unicode superscript characters to disambiguate months that share the same
    first letter (J=Jan/Jun/Jul, M=Mar/May, A=Apr/Aug).

    Result: J\u00b9 F M\u00b9 A\u00b9 M\u00b2 J\u00b2 J\u00b3 A\u00b2 S O N D
    """

    _LETTERS = {
        1: "J", 2: "F", 3: "M", 4: "A", 5: "M", 6: "J",
        7: "J", 8: "A", 9: "S", 10: "O", 11: "N", 12: "D",
    }

    # Unicode superscripts: \u00b9 = ¹, \u00b2 = ², \u00b3 = ³
    _SUPERSCRIPTS = {
        1: "\u00b9",   # Jan  -> J¹
        6: "\u00b2",   # Jun  -> J²
        7: "\u00b3",   # Jul  -> J³
        3: "\u00b9",   # Mar  -> M¹
        5: "\u00b2",   # May  -> M²
        4: "\u00b9",   # Apr  -> A¹
        8: "\u00b2",   # Aug  -> A²
    }

    @staticmethod
    def format(month_number):
        """Return a compact axis label for the given month number (1-12).

        :param month_number: Month number, 1 = January through 12 = December.
        :return: A single-letter label, with a Unicode superscript suffix for
                 months whose first letter is shared by another month.
        :raises ValueError: If month_number is not in 1..12.
        """
        if month_number < 1 or month_number > 12:
            raise ValueError(
                f"month_number must be between 1 and 12, got {month_number}"
            )
        letter = MonthLabelFormatter._LETTERS[month_number]
        sup = MonthLabelFormatter._SUPERSCRIPTS.get(month_number, "")
        return letter + sup

    @staticmethod
    def all_labels():
        """Return a list of 12 formatted month labels, index 0 = January.

        :return: List of 12 strings.
        """
        return [MonthLabelFormatter.format(m) for m in range(1, 13)]
