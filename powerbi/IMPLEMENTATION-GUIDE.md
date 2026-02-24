# Power BI FactSet Shell — Implementation Guide (v2)

## Architecture Overview

Three fact tables, two dimensions, and QA measures:

| Query | Type | Description |
|---|---|---|
| `fact_snapshot` | Fact | Combined normalized snapshot across horizons (MTD/QTD/YTD + 1YR from UDH Total block). All grains retained for drilldown. |
| `fact_timeseries` | Fact | Long table from UDH for line charts (Cumulative TSR) and monthly active bars. |
| `fact_exec_matrix` | Fact | Total-grain only, Horizons QTD/YTD/1YR, Columns Port/Bench/Δ (Δ = Total Effect, not arithmetic). |
| `dim_port_slicer` | Dimension | Portfolio / Benchmark slicer, derived from data via `#add_port_slicer`. |
| `dim_horizon` | Dimension | Horizon sort order (MTD=1, QTD=2, YTD=3, 1YR=4). |

Plus QA measures with a **200 bps alert threshold**. Note: 50-100 bps residual is normal (attribution math ≠ arithmetic Port - Bench).

---

## Dependency Graph

```
Raw FactSet connectors              Your existing utility functions
─────────────────────               ──────────────────────────────
2FA - MTD ─┐                        #unpivot_columns
2FA - QTD ─┤                        #add_port_slicer
2FA - YTD ─┤                        (#format_datarange — optional)
2FA - UDH ─┘                        (#format_all_cols — optional)

                    Shell queries
                    ─────────────
          clean_headers ← extracted header-cleaning function
          normalize_snapshot ← composes clean_headers + #unpivot_columns
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
_snap_mtd   _snap_qtd   _snap_ytd     _udh_1yr
    │           │           │             │
    └─────────┬─┘───────────┘─────────────┘
              ▼
        fact_snapshot ─────────► fact_exec_matrix
              │
              ▼
        dim_port_slicer (via headers from 2FA - MTD)

        2FA - UDH ──► fact_timeseries

        dim_horizon (static sort table)
```

---

## Naming Convention

| Layer | Prefix | Example | Notes |
|---|---|---|---|
| Raw (connector) | none | `2FA - MTD` | Keep FactSet-given names |
| Utility function | none | `clean_headers` | snake_case, verb-first |
| Staging | `_` | `_snap_mtd` | `_` prefix = don't load to model |
| Fact | `fact_` | `fact_snapshot` | snake_case |
| Dimension | `dim_` | `dim_port_slicer` | snake_case |

---

## Assumptions

### Source Queries (FactSet Connector Outputs)

Snapshot horizon queries (raw, wide format):
- `2FA - MTD`, `2FA - QTD`, `2FA - YTD`

UDH query (raw, wide format):
- `2FA - UDH`

### Existing Utility Functions (your library)

These must already exist in the Power BI file:
- `#unpivot_columns` — unpivots columns containing `" | "`, splits headers, optionally types values
- `#add_port_slicer` — creates VS/Portfolio/Benchmark slicer table from `"X vs. Y"` strings

Optional (referenced but not required):
- `#format_datarange` — splits `"Start to End"` date ranges
- `#format_all_cols` — auto-detects and applies column types

### Identifiers (consistent across all tables)

- `Ticker`, `total0`, `group1`

### Column Header Formats

Snapshot headers (after `clean_headers`):
```
<Portfolio vs Benchmark> | <Metric>
e.g. "LARGE_PAPER vs. Russell 1000 | Port. Total Return"
```

UDH headers (after `clean_headers`):
```
<PeriodToken> | <Portfolio vs Benchmark> | <Metric>
e.g. "31-DEC-2024 to 31-JAN-2025 | LARGE_PAPER vs. Russell 1000 | Port. Total Return"
     "Total | LARGE_PAPER vs. Russell 1000 | Port. Total Return"
```

---

## File Index

### Power Query M Files (`queries/`)

| File | Query Name | Load? | Purpose |
|---|---|---|---|
| `clean_headers.pq` | `clean_headers` | No | Header-cleaning function (single source of truth) |
| `normalize_snapshot.pq` | `normalize_snapshot` | No | Wraps `clean_headers` + `#unpivot_columns` + vs-split |
| `_snap_mtd.pq` | `_snap_mtd` | No | Buffered MTD staging |
| `_snap_qtd.pq` | `_snap_qtd` | No | Buffered QTD staging |
| `_snap_ytd.pq` | `_snap_ytd` | No | Buffered YTD staging |
| `_udh_1yr.pq` | `_udh_1yr` | No | Buffered 1YR staging from UDH Total block |
| `fact_snapshot.pq` | `fact_snapshot` | **Yes** | Combined snapshot (all horizons, all grains) |
| `fact_timeseries.pq` | `fact_timeseries` | **Yes** | UDH time series for charts |
| `fact_exec_matrix.pq` | `fact_exec_matrix` | **Yes** | Executive matrix (Total grain, QTD/YTD/1YR) |
| `dim_port_slicer.pq` | `dim_port_slicer` | **Yes** | Portfolio/Benchmark slicer (data-driven) |
| `dim_horizon.pq` | `dim_horizon` | **Yes** | Horizon sort order |

### DAX Measures (`measures/`)

| File | Measures |
|---|---|
| `exec_measures.dax` | `Exec Value`, `Exec Port`, `Exec Bench`, `Exec Δ`, `QA Residual (bps)`, `QA Alert? (200 bps)` |

---

## Setup Instructions

### Step 1: Ensure Utility Functions Exist

Verify these already exist in your Power BI file:
- `#unpivot_columns`
- `#add_port_slicer`

If not, create them as Blank Queries with the code from your Multi-Portfolio Demo.

### Step 2: Create Shell Functions

1. Create a new Blank Query → rename to `clean_headers` → paste `clean_headers.pq`
2. Create a new Blank Query → rename to `normalize_snapshot` → paste `normalize_snapshot.pq`
3. Disable load on both (right-click → uncheck "Enable load")

### Step 3: Create Staging Queries

For each staging query (`_snap_mtd`, `_snap_qtd`, `_snap_ytd`, `_udh_1yr`):
1. Create a new Blank Query
2. Name it exactly (e.g. `_snap_mtd`)
3. Paste the corresponding `.pq` file
4. Disable load on all four

### Step 4: Create Fact Tables

1. Create `fact_snapshot` from `fact_snapshot.pq` — **Enable load**
2. Create `fact_timeseries` from `fact_timeseries.pq` — **Enable load**
3. Create `fact_exec_matrix` from `fact_exec_matrix.pq` — **Enable load**

### Step 5: Create Dimensions

1. Create `dim_port_slicer` from `dim_port_slicer.pq` — **Enable load**
2. Create `dim_horizon` from `dim_horizon.pq` — **Enable load**
3. In Model view, select `dim_horizon[Horizon]` → "Sort by Column" → `SortOrder`

### Step 6: Add DAX Measures

1. In the model view, create the measures from `exec_measures.dax`
2. Add them to `fact_exec_matrix` or a dedicated measures table

---

## Model Relationships

```
dim_port_slicer[Portfolio]  ──(1:*)──►  fact_snapshot[Portfolio]
dim_port_slicer[Portfolio]  ──(1:*)──►  fact_exec_matrix[Portfolio]
dim_port_slicer[Portfolio]  ──(1:*)──►  fact_timeseries[Portfolio]
dim_horizon[Horizon]        ──(1:*)──►  fact_snapshot[Horizon]
dim_horizon[Horizon]        ──(1:*)──►  fact_exec_matrix[Horizon]
```

Optional:
- `Dim_Date[Date]` → `fact_timeseries[Date]` if you have a shared date dimension

---

## Visual Implementation (Report Pages)

### Page 1 — Executive Summary (Total grain only)

**A) Exec Matrix** (from `fact_exec_matrix`)
- Rows: `Portfolio`, `Horizon`
- Columns: `ExecMetric` (Port / Bench / Δ)
- Values: `[Exec Value]`
- Note: Horizon sorts correctly via `dim_horizon` relationship

**B) KPI Cards** (optional)
- 1YR Port: filter `Horizon=1YR` + `ExecMetric=Port`
- 1YR Bench: filter `Horizon=1YR` + `ExecMetric=Bench`
- 1YR Δ: filter `Horizon=1YR` + `ExecMetric=Δ`

### Page 2 — Rolling 12M / UDH Time Series (Total grain fixed)

Use `fact_timeseries` with page filter: Total grain only.

**Line Chart**
- X: `Date`
- Values: Port cumulative TSR + Bench cumulative TSR (filter by `Metric`)

**Bar Chart**
- X: `Date`
- Value: Monthly active via `Metric = "Total Effect"`

### Page 3 — Drilldown (optional)

Use `fact_snapshot` with slicers for:
- `dim_port_slicer[Portfolio]`
- `total0` (sector)
- `Ticker`
- `Metric`

### QA Page (hidden)

Display `QA Residual (bps)` and `QA Alert? (200 bps)` by Portfolio × Horizon.

---

## Refresh & Maintenance

1. **Refresh** pulls raw FactSet tables: `2FA - MTD`, `2FA - QTD`, `2FA - YTD`, `2FA - UDH`
2. Staging queries (`_snap_*`, `_udh_1yr`) rebuild with `Table.Buffer` to avoid duplicate source evaluation
3. `fact_snapshot`, `fact_timeseries`, `fact_exec_matrix` update automatically
4. `dim_port_slicer` updates automatically (data-driven, no hardcoded values)
5. QA page highlights unexpected drift (>200 bps threshold)

### Adding a New Horizon

1. Create raw query `2FA - <HORIZON>` via FactSet connector
2. Add staging query: `_snap_<hz>` = `Table.Buffer(normalize_snapshot(#"2FA - <HORIZON>", "<HZ>"))`
3. Append it in `fact_snapshot`
4. Add row to `dim_horizon` with next `SortOrder` value
5. (Optional) Add it to the exec matrix horizon filter in `fact_exec_matrix`

No upstream refactoring required.

---

## Design Decisions

| Decision | Rationale |
|---|---|
| `clean_headers` extracted as function | Eliminates copy/paste across 3+ queries. Single fix point for FactSet header changes. |
| `normalize_snapshot` wraps `#unpivot_columns` | Reuses tested utility code. Thin wrapper adds only the vs-split and horizon tag. |
| `dim_port_slicer` via `#add_port_slicer` | Self-maintaining, no hardcoded portfolio list. Stays current on refresh. |
| `dim_horizon` static sort table | Power BI needs a sort column. Alphabetical order (1YR, MTD, QTD, YTD) is wrong. |
| `Table.Buffer` on staging | Prevents Power BI from re-evaluating raw FactSet sources multiple times during refresh. |
| Null value filtering | `each [Value] <> null` after type conversion prevents blank rows in facts and exec matrix. |
| Total grain filter in `fact_exec_matrix` only | Keeps `fact_snapshot` at all grains for drilldown. Simplest architecture. |
| WTD excluded | Scope: MTD/QTD/YTD/1YR. Add back via staging query if needed. |
