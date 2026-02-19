// 2FA - COMBINED
// Single normalized snapshot fact table across all horizons:
//   WTD, MTD, QTD, YTD (from snapshot queries)
//   1YR (from UDH Total block)
//
// To add a new horizon:
//   1. Create raw query (e.g. 2FA - ITD)
//   2. Add wrapper: Fact - ITD = fn2FA_SnapshotNormalize(#"2FA - ITD", "ITD")
//   3. Append it to the list below

let
    Combined =
        Table.Combine(
            {
                #"Fact - WTD",
                #"Fact - MTD",
                #"Fact - QTD",
                #"Fact - YTD",
                #"UDH - SNAPSHOT (Total Block)"
            }
        )
in
    Combined
