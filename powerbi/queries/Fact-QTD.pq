// Fact - QTD
// Normalized QTD (Quarter-to-Date) snapshot from FactSet connector output.
// Depends on: fn2FA_SnapshotNormalize, 2FA - QTD

let
    Out = fn2FA_SnapshotNormalize(#"2FA - QTD", "QTD")
in
    Out
