// Fact - MTD
// Normalized MTD (Month-to-Date) snapshot from FactSet connector output.
// Depends on: fn2FA_SnapshotNormalize, 2FA - MTD

let
    Out = fn2FA_SnapshotNormalize(#"2FA - MTD", "MTD")
in
    Out
