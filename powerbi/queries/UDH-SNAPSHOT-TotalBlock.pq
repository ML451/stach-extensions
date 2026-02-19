// UDH - SNAPSHOT (Total Block)
// Extracts the 1YR snapshot from the UDH "Total" block.
// No fallback logic — uses the fixed "1YR" label.
// Depends on: 2FA - UDH

let
    Source = #"2FA - UDH",

    // Clean headers (UDH has date-range and Total tokens in headers)
    CleanCols =
        Table.TransformColumnNames(
            Source,
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
        ),

    IdCols = {"Ticker","total0","group1"},

    // Keep only identifiers + Total-period columns (those start with "Total | ")
    KeepCols =
        List.Select(
            Table.ColumnNames(CleanCols),
            (cn) => List.Contains(IdCols, cn) or Text.StartsWith(cn, "Total | ")
        ),

    TotalOnly = Table.SelectColumns(CleanCols, KeepCols),

    Unpivoted =
        Table.UnpivotOtherColumns(
            TotalOnly,
            IdCols,
            "Attribute",
            "Value"
        ),

    // "Total | <Portfolio vs Benchmark> | <Metric>"
    SplitAttr =
        Table.SplitColumn(
            Unpivoted,
            "Attribute",
            Splitter.SplitTextByDelimiter(" | ", QuoteStyle.Csv),
            {"PeriodToken","PortfolioVsBenchmark","Metric"}
        ),

    FilterTotal = Table.SelectRows(SplitAttr, each [PeriodToken] = "Total"),

    SplitPvB =
        Table.SplitColumn(
            FilterTotal,
            "PortfolioVsBenchmark",
            Splitter.SplitTextByDelimiter(" vs. ", QuoteStyle.Csv),
            {"Portfolio","Benchmark"}
        ),

    CleanText =
        Table.TransformColumns(
            SplitPvB,
            {
                {"Ticker", each if _=null then null else Text.Trim(Text.From(_)), type text},
                {"total0", each if _=null then null else Text.Trim(Text.From(_)), type text},
                {"group1", each if _=null then null else Text.Trim(Text.From(_)), type text},
                {"Portfolio", each if _=null then null else Text.Trim(_), type text},
                {"Benchmark", each if _=null then null else Text.Trim(_), type text},
                {"Metric", each if _=null then null else Text.Trim(_), type text}
            }
        ),

    // Fixed 1YR label (no fallback/overrides)
    AddHorizon = Table.AddColumn(CleanText, "Horizon", each "1YR", type text),

    Typed = Table.TransformColumnTypes(AddHorizon, {{"Value", type number}}),
    Final = Table.RemoveColumns(Typed, {"PeriodToken"})
in
    Final
