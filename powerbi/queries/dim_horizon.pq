// dim_horizon
// Horizon sort order dimension.
// In Power BI: select the Horizon column → "Sort by Column" → SortOrder.
// Without this, horizons render alphabetically (1YR, MTD, QTD, YTD) which is wrong.

let
    source =
        #table(
            type table [Horizon = text, SortOrder = Int64.Type],
            {
                {"MTD", 1},
                {"QTD", 2},
                {"YTD", 3},
                {"1YR", 4}
            }
        )
in
    source
