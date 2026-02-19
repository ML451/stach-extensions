// Fact_ExecMatrix
// Executive summary matrix fact table.
// Derived from 2FA - COMBINED, filtered to:
//   - Total grain only (robust across sources)
//   - Horizons: QTD, YTD, 1YR
//   - Metrics: Port (Port. Total Return), Bench (Bench. Total Return), Delta (Total Effect)
//   - Includes Strategy Inception Date via Dim_Strategy join
//
// Output columns:
//   Portfolio, Benchmark, StrategyInceptionDate, Horizon, ExecMetric, Value
//
// Depends on: 2FA - COMBINED, Dim_Strategy

let
    Source = #"2FA - COMBINED",

    // Robust Total-grain: snapshot totals often appear as total0="Total" (Ticker may be blank)
    AddIsTotalGrain =
        Table.AddColumn(
            Source,
            "IsTotalGrain",
            each
                let
                    t = try Text.Upper(Text.Trim(Text.From([Ticker]))) otherwise "",
                    s = try Text.Upper(Text.Trim(Text.From([total0]))) otherwise ""
                in
                    (t = "TOTAL") or (s = "TOTAL"),
            type logical
        ),

    FilterTotal = Table.SelectRows(AddIsTotalGrain, each [IsTotalGrain] = true),

    // Exec horizons (fixed)
    FilterHorizons = Table.SelectRows(FilterTotal, each List.Contains({"QTD","YTD","1YR"}, [Horizon])),

    // Exec metrics only (Delta is Total Effect, not arithmetic)
    FilterMetrics =
        Table.SelectRows(
            FilterHorizons,
            each List.Contains({"Port. Total Return","Bench. Total Return","Total Effect"}, [Metric])
        ),

    // Map to short display labels: Port / Bench / Delta
    AddExecMetric =
        Table.AddColumn(
            FilterMetrics,
            "ExecMetric",
            each
                if [Metric] = "Port. Total Return" then "Port"
                else if [Metric] = "Bench. Total Return" then "Bench"
                else if [Metric] = "Total Effect" then "Δ"
                else null,
            type text
        ),

    // Merge inception dates
    MergeS = Table.NestedJoin(AddExecMetric, {"Portfolio"}, Dim_Strategy, {"Portfolio"}, "S", JoinKind.LeftOuter),
    ExpandS = Table.ExpandTableColumn(MergeS, "S", {"StrategyInceptionDate"}, {"StrategyInceptionDate"}),

    KeepCols =
        Table.SelectColumns(
            ExpandS,
            {"Portfolio","Benchmark","StrategyInceptionDate","Horizon","ExecMetric","Value"}
        )
in
    KeepCols
