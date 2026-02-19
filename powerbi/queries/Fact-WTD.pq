// Fact - WTD
// Normalized WTD (Week-to-Date) snapshot from FactSet connector output.
// Depends on: fn2FA_SnapshotNormalize, 2FA - WTD

let
    Out = fn2FA_SnapshotNormalize(#"2FA - WTD", "WTD")
in
    Out
