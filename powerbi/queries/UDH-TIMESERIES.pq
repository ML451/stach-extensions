// UDH - TIMESERIES
// Normalized long table from 2FA - UDH for line charts (Cumulative TSR)
// and monthly active bars. Uses FactSet's pre-calculated series.
//
// Excludes the "Total" block (used only in UDH-SNAPSHOT-TotalBlock).
// Parses PeriodEnd date from "dd-MMM-yyyy to dd-MMM-yyyy" tokens.
//
// Output columns:
//   Ticker, total0, group1, Portfolio, Benchmark, Metric, PeriodToken, Date, Value
//
// Depends on: 2FA - UDH

let
    Source = #"2FA - UDH",

    // Clean headers (UDH has "PeriodToken | PvB | Metric")
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

    IdColsWanted   = {"Ticker","total0","group1"},
    IdColsExisting = List.Intersect({IdColsWanted, Table.ColumnNames(CleanCols)}),

    Unpivoted =
        Table.UnpivotOtherColumns(
            CleanCols,
            IdColsExisting,
            "Attribute",
            "Value"
        ),

    // UDH attribute: "Start to End | Portfolio vs Benchmark | Metric" OR "Total | ..."
    SplitAttr =
        Table.SplitColumn(
            Unpivoted,
            "Attribute",
            Splitter.SplitTextByDelimiter(" | ", QuoteStyle.Csv),
            {"PeriodToken","PortfolioVsBenchmark","Metric"}
        ),

    // Keep only Range periods (exclude Total block for time-series charts)
    RangeOnly = Table.SelectRows(SplitAttr, each [PeriodToken] <> "Total"),

    SplitPvB =
        Table.SplitColumn(
            RangeOnly,
            "PortfolioVsBenchmark",
            Splitter.SplitTextByDelimiter(" vs. ", QuoteStyle.Csv),
            {"Portfolio","Benchmark"}
        ),

    // Parse PeriodEnd (token looks like "dd-MMM-yyyy to dd-MMM-yyyy")
    AddPeriodEnd =
        Table.AddColumn(
            SplitPvB,
            "Date",
            each
                let parts = Text.Split([PeriodToken], " to "),
                    e = if List.Count(parts) >= 2 then parts{1} else null
                in try Date.FromText(e, "en-US") otherwise null,
            type date
        ),

    CleanText =
        Table.TransformColumns(
            AddPeriodEnd,
            {
                {"Ticker", each if _=null then null else Text.Trim(Text.From(_)), type text},
                {"total0", each if _=null then null else Text.Trim(Text.From(_)), type text},
                {"group1", each if _=null then null else Text.Trim(Text.From(_)), type text},
                {"Portfolio", each if _=null then null else Text.Trim(_), type text},
                {"Benchmark", each if _=null then null else Text.Trim(_), type text},
                {"Metric", each if _=null then null else Text.Trim(_), type text}
            }
        ),

    Typed = Table.TransformColumnTypes(CleanText, {{"Value", type number}}),

    // Keep PeriodToken for audit trail
    Final = Typed
in
    Final
