// _udh_1yr  [staging — do not load to model]
// Extracts the 1YR snapshot from UDH "Total" block.
// Depends on: clean_headers, #unpivot_columns, 2FA - UDH

let
    cleaned    = clean_headers(#"2FA - UDH"),

    // UDH headers: "PeriodToken | PortfolioVsBenchmark | Metric"
    unpivoted  = #unpivot_columns(cleaned, {"PeriodToken", "PortfolioVsBenchmark", "Metric"}, true),

    total_only = Table.SelectRows(unpivoted, each [PeriodToken] = "Total"),

    split_vs   = Table.SplitColumn(
                     total_only, "PortfolioVsBenchmark",
                     Splitter.SplitTextByDelimiter(" vs. ", QuoteStyle.None),
                     {"Portfolio", "Benchmark"}
                 ),

    add_hz     = Table.AddColumn(split_vs, "Horizon", each "1YR", type text),
    filtered   = Table.SelectRows(add_hz, each [Portfolio] <> null and [Value] <> null),
    drop_token = Table.RemoveColumns(filtered, {"PeriodToken"})
in
    Table.Buffer(drop_token)
