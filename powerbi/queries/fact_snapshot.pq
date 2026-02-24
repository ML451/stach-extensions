// fact_snapshot
// Combined normalized snapshot across horizons: MTD, QTD, YTD, 1YR.
// Retains all grains (security, sector, total) for drilldown.
//
// To add a horizon:
//   1. Create raw query (e.g. 2FA - ITD)
//   2. Add staging query: _snap_itd = Table.Buffer(normalize_snapshot(#"2FA - ITD", "ITD"))
//   3. Append it to the list below
//
// Depends on: _snap_mtd, _snap_qtd, _snap_ytd, _udh_1yr

Table.Combine({_snap_mtd, _snap_qtd, _snap_ytd, _udh_1yr})
