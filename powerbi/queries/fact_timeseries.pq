// fact_timeseries
// Normalized long table from UDH for line charts (Cumulative TSR)
// and monthly active bars. Excludes the "Total" block (used in _udh_1yr).
//
// Output columns:
//   Ticker, total0, group1, Portfolio, Benchmark, Metric, Date, Value
//
// Depends on: clean_headers, #unpivot_columns, 2FA - UDH
// Note: #format_datarange can replace the inline date extraction if
//       you rename PeriodToken to "Date Range" first.

let
    cleaned    = clean_headers(#"2FA - UDH"),

    // UDH headers: "PeriodToken | PortfolioVsBenchmark | Metric"
    unpivoted  = #unpivot_columns(cleaned, {"PeriodToken", "PortfolioVsBenchmark", "Metric"}, true),

    // Exclude Total block (that's the 1YR snapshot in _udh_1yr)
    range_only = Table.SelectRows(unpivoted, each [PeriodToken] <> "Total"),

    split_vs   = Table.SplitColumn(
                     range_only, "PortfolioVsBenchmark",
                     Splitter.SplitTextByDelimiter(" vs. ", QuoteStyle.None),
                     {"Portfolio", "Benchmark"}
                 ),

    // Extract end date from "dd-MMM-yyyy to dd-MMM-yyyy"
    add_date   = Table.AddColumn(
                     split_vs, "Date",
                     each
                         let parts = Text.Split([PeriodToken], " to ")
                         in  if List.Count(parts) >= 2
                             then try Date.FromText(parts{1}, "en-US") otherwise null
                             else null,
                     type date
                 ),

    filtered   = Table.SelectRows(add_date, each [Portfolio] <> null and [Value] <> null),
    drop_token = Table.RemoveColumns(filtered, {"PeriodToken"})
in
    drop_token
