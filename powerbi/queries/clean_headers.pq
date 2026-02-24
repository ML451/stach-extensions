// clean_headers
// Normalizes FactSet column headers by fixing backslash wraps,
// newlines, plus signs, and collapsing whitespace into pipe delimiters.
//
// Usage: clean_headers(#"2FA - MTD")
//
// Extracted as a single function to avoid duplication across queries.
// If FactSet changes their header escaping, fix it here once.

let
    clean_headers = (tbl as table) as table =>
        Table.TransformColumnNames(
            tbl,
            (c as text) =>
                let
                    c1 = Text.Replace(c, "#(lf)", " "),
                    c2 = Text.Replace(c1, "#(cr)", " "),
                    c3 = Text.Replace(c2, " \ ", " | "),
                    c4 = Text.Replace(c3, "\ ", " | "),
                    c5 = Text.Replace(c4, " \", " | "),
                    c6 = Text.Replace(c5, "\", " | "),
                    c7 = Text.Replace(c6, "+", " "),
                    c8 = Text.Trim(Text.Combine(List.Select(Text.SplitAny(c7, "  "), each _ <> ""), " "))
                in
                    c8
        )
in
    clean_headers
