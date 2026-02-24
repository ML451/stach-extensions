// dim_port_slicer
// Portfolio / Benchmark slicer dimension, derived from data.
// Uses #add_port_slicer to split "X vs. Y" header tokens.
//
// Output columns: VS, Portfolio, Benchmark
//
// Depends on: clean_headers, #add_port_slicer, 2FA - MTD (any snapshot source)

let
    // Extract "X vs. Y" tokens from raw snapshot headers
    headers = Table.ColumnNames(clean_headers(#"2FA - MTD")),

    vs_list = List.Transform(
        List.Select(headers, each Text.Contains(_, " vs. ")),
        each Text.BeforeDelimiter(_, " | ")
    ),

    source  = #add_port_slicer(vs_list)
in
    source
