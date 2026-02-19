# Power BI FactSet Shell — Implementation Guide

## Architecture Overview

Three core deliverables:

| Deliverable | Description |
|---|---|
| **2FA - COMBINED** | Single normalized snapshot fact table across horizons (WTD/MTD/QTD/YTD + 1YR from UDH Total block) |
| **UDH - TIMESERIES** | Normalized long table from `2FA - UDH` for line charts / monthly active bars, using FactSet's pre-calculated Cumulative TSR series |
| **Fact_ExecMatrix** | Exec-only table derived from `2FA - COMBINED`: Total-grain only, Horizons QTD/YTD/1YR, Columns Port/Bench/Δ (Δ = Total Effect, not arithmetic), includes Strategy Inception Date |

Plus QA measures with a **200 bps alert threshold** to catch data misalignment.

---

## Assumptions

### Source Queries (FactSet Connector Outputs)

Snapshot horizon queries:
- `2FA - WTD`, `2FA - MTD`, `2FA - QTD`, `2FA - YTD`

UDH query:
- `2FA - UDH`

### Identifiers (consistent across all tables)

- `Ticker`, `total0`, `group1`

### Snapshot Horizon Column Structure

```
<Portfolio vs Benchmark> | <Metric>
e.g. "LARGE_PAPER vs. Russell 1000 | Port. Total Return"
```

### UDH Column Structure

```
<DateRange or "Total"> | <Portfolio vs Benchmark> | <Metric>
e.g. "31-DEC-2024 to 31-JAN-2025 | LARGE_PAPER vs. Russell 1000 | Port. Total Return"
     "Total | LARGE_PAPER vs. Russell 1000 | Port. Total Return"
```

---

## File Index

### Power Query M Files (`queries/`)

| File | Query Name in Power BI | Purpose |
|---|---|---|
| `fn2FA_SnapshotNormalize.pq` | `fn2FA_SnapshotNormalize` | Core normalization function for snapshot horizons |
| `Fact-WTD.pq` | `Fact - WTD` | WTD wrapper |
| `Fact-MTD.pq` | `Fact - MTD` | MTD wrapper |
| `Fact-QTD.pq` | `Fact - QTD` | QTD wrapper |
| `Fact-YTD.pq` | `Fact - YTD` | YTD wrapper |
| `UDH-SNAPSHOT-TotalBlock.pq` | `UDH - SNAPSHOT (Total Block)` | 1YR snapshot from UDH Total block |
| `2FA-COMBINED.pq` | `2FA - COMBINED` | Combined snapshot fact across all horizons |
| `UDH-TIMESERIES.pq` | `UDH - TIMESERIES` | Time series for charts |
| `Dim_Strategy.pq` | `Dim_Strategy` | Strategy inception dates dimension |
| `Fact_ExecMatrix.pq` | `Fact_ExecMatrix` | Executive matrix fact table |

### DAX Measures (`measures/`)

| File | Measures |
|---|---|
| `exec-measures.dax` | `Exec Value`, `Exec Port`, `Exec Bench`, `Exec Δ`, `QA Residual (bps)`, `QA Alert? (200 bps)` |

---

## Setup Instructions

### Step 1: Create the Core Function

1. In Power BI Desktop, open Power Query Editor
2. Create a new Blank Query
3. Rename it to `fn2FA_SnapshotNormalize`
4. Paste the contents of `queries/fn2FA_SnapshotNormalize.pq`

### Step 2: Create Horizon Wrappers

For each horizon (WTD, MTD, QTD, YTD):
1. Create a new Blank Query
2. Name it `Fact - WTD` (etc.)
3. Paste the corresponding `.pq` file contents

### Step 3: Create UDH Queries

1. Create `UDH - SNAPSHOT (Total Block)` from `UDH-SNAPSHOT-TotalBlock.pq`
2. Create `UDH - TIMESERIES` from `UDH-TIMESERIES.pq`

### Step 4: Create Combined Fact

1. Create `2FA - COMBINED` from `2FA-COMBINED.pq`

### Step 5: Create Dimension & Exec Tables

1. Create `Dim_Strategy` from `Dim_Strategy.pq`
   - **Update the placeholder inception dates** with real values
2. Create `Fact_ExecMatrix` from `Fact_ExecMatrix.pq`

### Step 6: Add DAX Measures

1. In the model view, create the measures from `measures/exec-measures.dax`
2. Add them to an appropriate measure table or to `Fact_ExecMatrix`

---

## Model Relationships

```
Dim_Strategy[Portfolio] ──(Many-to-one)──> Fact_ExecMatrix[Portfolio]
```

Optional additions:
- `Dim_Date` for UDH timeseries using `Date` column
- `Dim_Horizon` for sorting (QTD → YTD → 1YR) if text order is insufficient

---

## Visual Implementation (Report Pages)

### Page 1 — Executive Summary (Total grain only)

**A) Exec Matrix** (from `Fact_ExecMatrix`)
- Rows: `Portfolio`, `StrategyInceptionDate`, `Horizon`
- Columns: `ExecMetric` (Port / Bench / Δ)
- Values: `Sum(Value)`

**B) KPI Cards** (optional)
- 1YR Port: filter `Horizon=1YR` and `ExecMetric=Port`
- 1YR Bench: filter `Horizon=1YR` and `ExecMetric=Bench`
- 1YR Δ: filter `Horizon=1YR` and `ExecMetric=Δ`

### Page 2 — Rolling 12M / UDH Time Series (Total grain fixed)

Use `UDH - TIMESERIES` with page filter: Total grain only (`total0 = "Total"` OR `Ticker = "Total"`).

**Line Chart**
- X: `Date`
- Values:
  - Port cumulative TSR: filter `Metric = "Port. Cumulative Total Return"`
  - Bench cumulative TSR: filter `Metric = "Bench. Cumulative Total Return"`

**Bar Chart**
- X: `Date`
- Value: Monthly active — use `Metric = "Total Effect"` (attribution-consistent)

### Page 3 — Drilldown (optional)

Use `2FA - COMBINED` with slicers for:
- `total0` (sector)
- `Ticker`
- `Metric` (effects, returns, etc.)

### QA Page (hidden)

Display `QA Residual (bps)` and `QA Alert? (200 bps)` by Portfolio × Horizon to spot duplication or grain issues.

---

## Refresh & Maintenance Workflow

1. **Refresh** pulls raw FactSet tables: `2FA - WTD`, `2FA - MTD`, `2FA - QTD`, `2FA - YTD`, `2FA - UDH`
2. `2FA - COMBINED` rebuilds automatically
3. `Fact_ExecMatrix` updates automatically
4. QA page highlights unexpected drift (200 bps threshold)

### Adding a New Horizon

1. Create the raw query `2FA - <HORIZON>` (e.g., `2FA - ITD`)
2. Add wrapper: `Fact - <HORIZON>` using `fn2FA_SnapshotNormalize`
3. Append it in `2FA - COMBINED`
4. (Optional) Add it to the exec matrix horizon filter in `Fact_ExecMatrix`

No upstream refactoring required.

---

## Design Decision: Total Grain Filter

The Total grain filter (`IsTotalGrain`) is **contained only in `Fact_ExecMatrix`**, keeping the architecture at its simplest. The `2FA - COMBINED` table retains all grains (security, sector, total) for drilldown use on Page 3.
