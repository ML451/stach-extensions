// Fact - YTD
// Normalized YTD (Year-to-Date) snapshot from FactSet connector output.
// Depends on: fn2FA_SnapshotNormalize, 2FA - YTD

let
    Out = fn2FA_SnapshotNormalize(#"2FA - YTD", "YTD")
in
    Out
