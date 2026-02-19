// fn2FA_SnapshotNormalize
// Core normalization function for FactSet snapshot horizon tables.
// Usage: fn2FA_SnapshotNormalize(#"2FA - WTD", "WTD")
//
// Inputs:
//   tbl     - A raw FactSet connector output table (e.g. 2FA - WTD)
//   horizon - A text label for the time horizon (e.g. "WTD", "MTD", "QTD", "YTD")
//
// Output:
//   A normalized long table with columns:
//     Ticker, total0, group1, Portfolio, Benchmark, Metric, Horizon, Value

let
    fn2FA_SnapshotNormalize = (tbl as table, horizon as text) as table =>
    let
        // Clean header artifacts seen in FactSet outputs (\ wraps, + tokenization)
        CleanCols =
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
            ),

        IdColsWanted   = {"Ticker","total0","group1"},
        IdColsExisting = List.Intersect({IdColsWanted, Table.ColumnNames(CleanCols)}),

        // Unpivot all metric columns into Attribute/Value
        Unpivoted =
            Table.UnpivotOtherColumns(
                CleanCols,
                IdColsExisting,
                "Attribute",
                "Value"
            ),

        // Snapshot attributes: "<Portfolio vs Benchmark> | <Metric>"
        SplitAttr =
            Table.SplitColumn(
                Unpivoted,
                "Attribute",
                Splitter.SplitTextByDelimiter(" | ", QuoteStyle.Csv),
                {"PortfolioVsBenchmark","Metric"}
            ),

        SplitPvB =
            Table.SplitColumn(
                SplitAttr,
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

        AddHorizon = Table.AddColumn(CleanText, "Horizon", each horizon, type text),
        Typed      = Table.TransformColumnTypes(AddHorizon, {{"Value", type number}}),

        // Safety: drop any junk rows where Portfolio didn't parse
        Filtered   = Table.SelectRows(Typed, each [Portfolio] <> null and Text.Trim([Portfolio]) <> "")
    in
        Filtered
in
    fn2FA_SnapshotNormalize
