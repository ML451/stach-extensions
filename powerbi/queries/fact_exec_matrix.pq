// fact_exec_matrix
// Executive summary matrix: Total grain, exec horizons, pivoted metrics.
// Δ = Total Effect (attribution-derived, not arithmetic Port - Bench).
//
// Output columns:
//   Portfolio, Benchmark, Horizon, ExecMetric, Value
//
// Depends on: fact_snapshot

let
    source = fact_snapshot,

    // Total grain: Ticker or total0 = "Total" (case-insensitive)
    add_flag =
        Table.AddColumn(
            source, "IsTotalGrain",
            each
                let
                    t = try Text.Upper(Text.Trim(Text.From([Ticker]))) otherwise "",
                    s = try Text.Upper(Text.Trim(Text.From([total0]))) otherwise ""
                in
                    (t = "TOTAL") or (s = "TOTAL"),
            type logical
        ),

    total_only = Table.SelectRows(add_flag, each [IsTotalGrain]),

    // Exec horizons
    hz_filter =
        Table.SelectRows(total_only, each List.Contains({"QTD", "YTD", "1YR"}, [Horizon])),

    // Exec metrics → short display labels
    metric_filter =
        Table.SelectRows(
            hz_filter,
            each List.Contains({"Port. Total Return", "Bench. Total Return", "Total Effect"}, [Metric])
        ),

    add_label =
        Table.AddColumn(
            metric_filter, "ExecMetric",
            each
                if [Metric] = "Port. Total Return" then "Port"
                else if [Metric] = "Bench. Total Return" then "Bench"
                else if [Metric] = "Total Effect" then "Δ"
                else null,
            type text
        ),

    keep_cols =
        Table.SelectColumns(
            add_label,
            {"Portfolio", "Benchmark", "Horizon", "ExecMetric", "Value"}
        )
in
    keep_cols
