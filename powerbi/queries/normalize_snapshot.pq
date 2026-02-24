// normalize_snapshot
// Normalizes a FactSet snapshot horizon table into long format.
// Composes clean_headers + #unpivot_columns, then splits "Portfolio vs. Benchmark".
//
// Usage: normalize_snapshot(#"2FA - MTD", "MTD")
//
// Output columns:
//   Ticker, total0, group1, Portfolio, Benchmark, Metric, Horizon, Value
//
// Depends on: clean_headers, #unpivot_columns (existing utility)

let
    normalize_snapshot = (source as table, horizon as text) as table =>
    let
        cleaned   = clean_headers(source),
        unpivoted = #unpivot_columns(cleaned, {"PortfolioVsBenchmark", "Metric"}, true),

        split_vs  = Table.SplitColumn(
                        unpivoted, "PortfolioVsBenchmark",
                        Splitter.SplitTextByDelimiter(" vs. ", QuoteStyle.None),
                        {"Portfolio", "Benchmark"}
                    ),

        add_hz    = Table.AddColumn(split_vs, "Horizon", each horizon, type text),

        // Drop rows where Portfolio didn't parse or Value is null
        filtered  = Table.SelectRows(add_hz, each [Portfolio] <> null and [Value] <> null)
    in
        filtered
in
    normalize_snapshot
