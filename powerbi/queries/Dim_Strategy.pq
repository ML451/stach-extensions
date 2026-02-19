// Dim_Strategy
// Strategy inception dates dimension table.
// Used by Fact_ExecMatrix to display inception dates in the executive matrix.
//
// IMPORTANT: Replace placeholder dates below with actual strategy inception dates.

let
    Dim_Strategy =
        #table(
            type table [Portfolio = text, StrategyInceptionDate = date],
            {
                // Replace with real inception dates
                {"LARGE_PAPER", #date(2018, 1, 1)},
                {"SMID_PAPER", #date(2019, 1, 1)},
                {"CONCENTRATED_PAPER", #date(2020, 1, 1)},
                {"LargeCapSelect_PAPER", #date(2021, 1, 1)}
            }
        )
in
    Dim_Strategy
