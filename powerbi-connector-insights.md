# Power BI Native Connector - Insights from STACH Extensions

## Overview

This document captures applicable insights from the `stach-extensions` codebase for building a Power BI native connector for FactSet data ETL. The STACH (Structured Table CHunks) extensions library provides proven patterns for parsing FactSet's protobuf-based tabular data format into consumable table structures across Python, Java, C#/.NET, and R.

---

## 1. Data Format Understanding

### STACH Has Two Organization Modes
The connector must handle **both** data organizations returned by FactSet APIs:

| Mode | Description | Use Case |
|------|-------------|----------|
| **Column-Organized** | Data stored as column arrays (like columnar databases) | Bulk data, analytics results |
| **Row-Organized** | Data stored row-by-row with explicit row definitions | Hierarchical/grouped results |

**Power BI Implication**: Power Query's `Table.FromColumns` maps naturally to column-organized STACH; `Table.FromRows` maps to row-organized. The connector should detect the organization mode and route to the appropriate parser.

### Two Active Schema Versions
- **V1** (legacy): Column-organized only, uses `fds.protobuf.stach` schema
- **V2** (current): Both column and row-organized, uses `fds.protobuf.stach.v2` schema

The V2 format also has a **simplified row format** variant (no explicit header rows — headers are derived from column definitions). The connector must handle all three sub-formats.

---

## 2. Key Data Structures to Map to Power BI Tables

### Package → Navigation Table
A STACH `Package` contains multiple tables referenced by `primaryTableIds`. In Power BI, this maps to a **navigation table** pattern where each primary table ID becomes a selectable table in the connector's navigator.

```
Package
├── primaryTableIds: ["table-1", "table-2"]   → Navigation table entries
└── tables: {
    "table-1": { definition, data, metadata } → Power BI Table
    "table-2": { definition, data, metadata } → Power BI Table
    "header-table": { ... }                   → Consumed internally for column names
}
```

### Column Definitions → Power BI Schema
Each table's `definition.columns` provides the schema. Key properties to map:

| STACH Property | Power BI Equivalent |
|---------------|-------------------|
| `column.id` | Internal column identifier |
| `column.name` | Technical column name |
| `column.description` | Display-friendly column name (prefer this over `name` when available) |
| `column.type` (`string`, `real`, `int32`, `int64`, `bool`, `timestamp`, `duration`) | `type text`, `type number`, `Int64.Type`, `type logical`, `type datetime`, `type duration` |
| `column.isDimension` | Mark as dimension vs. measure in data model |
| `column.format.nullFormat` (e.g., `"--"`, `"@NA"`) | Replace nulls with this display string, or handle as `null` in Power BI |
| `column.format.format` (e.g., `"{0:0.00;-0.00;--}"`) | Post-load formatting in Power BI data model |
| `column.format.halign` (`RIGHT`, `LEFT`) | Report-level formatting hint |
| `column.headerId` | Links data columns to header table rows for multi-level headers |
| `column.parentId` | Establishes hierarchy between dimension columns |

### Row Organization → Table Rows
- **Column-organized**: Iterate `data.columns[columnId].values` arrays in parallel, indexed by `data.rows[i].id`
- **Row-organized**: Iterate `data.rows[i].values` maps, keying by `column.id`
- **Simplified row-organized**: Same as row-organized but with no header rows; headers come from column definitions

---

## 3. ETL Pipeline Design

### Extract Phase

**Input Formats**: The existing library accepts three input types per builder:
1. Native protobuf objects
2. JSON strings
3. Plain objects/dictionaries

For a Power BI connector, **JSON string input** is the most practical since Power Query M language has native JSON parsing via `Json.Document()`. The connector should:
1. Call FactSet REST API → receive JSON response
2. Pass the JSON to the STACH parsing logic

**Reference**: See builder pattern in `StachExtensionFactory` — the `.SetPackage(string)` overload handles JSON deserialization:
- .NET: `dotnet/StachExtensions/.../V2/ColumnOrganizedStachBuilder.cs`
- .NET: `dotnet/StachExtensions/.../V2/RowOrganizedStachBuilder.cs`

### Transform Phase

The core transformation logic from the .NET implementation (most relevant for Power BI) follows this pipeline:

```
JSON Response
  │
  ├─ Detect format (column-organized vs. row-organized)
  │
  ├─ If compressed: Decompress columns via range expansion
  │   (See: V2/ColumnOrganizedStachUtilities.cs)
  │
  ├─ Extract headers:
  │   ├─ From header table (if headerTableId exists)
  │   ├─ From column descriptions (fallback)
  │   └─ Handle multi-level headers with rowspan/colspan
  │
  ├─ Extract data rows:
  │   ├─ Column-organized: Pivot column arrays into rows
  │   └─ Row-organized: Map row.values by column.id
  │
  ├─ Type conversion:
  │   ├─ Protobuf Value → native types
  │   ├─ Null handling with format.nullFormat
  │   └─ Scientific notation suppression for doubles
  │
  └─ Extract metadata (table-level key-value pairs)
```

### Load Phase

For Power BI, the final output should be `Table.Type` with:
- Typed columns matching STACH column definitions
- Proper null handling
- Metadata attached via `Value.Metadata` in M language

---

## 4. Critical Implementation Patterns

### 4.1 Decompression (Must Implement)

STACH supports **range-based column compression**. Compressed columns use a `ranges` map where keys are decompressed indices and values are repeat counts.

**Example** from `V2StachWithCompressedColumn.json`:
```json
{
  "ranges": { "1": 3 },
  "values": ["Port.+Weight", "Bench.+Weight"]
}
```
Decompresses to: `["Port.+Weight", "Bench.+Weight", "Bench.+Weight", "Bench.+Weight"]`

**Reference Implementation**: `V2/ColumnOrganizedStachUtilities.cs` lines 61-83

In Power Query M, this would need a custom function:
```m
DecompressColumn = (values as list, ranges as record) =>
    // Expand values by inserting repeats at specified decompressed indices
```

### 4.2 Multi-Level Header Resolution

Column-organized tables can have a separate **header table** that provides multi-level column names. The link works as follows:

1. Primary table columns have a `headerId` pointing to a row in the header table
2. The header table's columns provide different header levels
3. Dimension columns use `description` (or `name` fallback) instead of header lookup

**Reference**: `V2/ColumnOrganizedStachExtension.cs` lines 56-100

For Power BI, multi-level headers can be:
- Flattened into single-level headers (concatenated with separator)
- Represented using column groups in the data model
- Stored as column metadata for report-level display

### 4.3 Row/Column Span Handling

Row-organized format supports `rowspan` and `colspan` in header rows via `headerCellDetails`. The existing implementation uses a `RowSpanSpread` tracking list to propagate spanned values across rows.

**Reference**: `V2/RowOrganizedStachExtension.cs` lines 62-125 and `RowSpanSpread.cs`

For Power BI, this is primarily relevant when generating display-friendly tables. The connector should flatten spans into repeated values.

### 4.4 Type Conversion Map

The .NET `StachUtilities.ValueToString()` and `ValueToObject()` methods (`V2/StachUtilities.cs`) handle protobuf Value → .NET type conversion:

| Protobuf Value Kind | .NET Type | Power BI M Type |
|---------------------|-----------|-----------------|
| `BoolValue` | `bool` | `type logical` |
| `NumberValue` | `double` | `type number` |
| `StringValue` | `string` | `type text` |
| `NullValue` / `None` | `null` | `null` |
| `ListValue` | `string` (serialized) | `type text` or `type list` |
| `StructValue` | `string` (JSON) | `type text` or `type record` |

**V1 has additional explicit types**: `INT32`, `INT64`, `FLOAT`, `DOUBLE`, `STRING`, `BOOL`, `DURATION`, `TIMESTAMP` with dedicated null checks (e.g., NaN for floats, specific sentinel values for ints).

### 4.5 Null Format Handling

STACH columns can define a `nullFormat` string (e.g., `"--"`, `"@NA"`) that indicates how nulls should be displayed. The connector has two options:
1. **Keep Power BI nulls**: Leave null values as `null` and let report formatting handle display (recommended for data model integrity)
2. **Apply null format**: Replace nulls with the format string for display-only scenarios

### 4.6 Metadata Extraction

Each table carries metadata (e.g., Portfolio Holdings Date, Currency, Calendar, Benchmark info). Metadata is organized by location:
- `table` level: General report metadata
- `column` level: Per-column metadata
- `row` level: Per-row metadata

**For Power BI**:
- Table-level metadata → Power BI table description or custom metadata table
- Expose as a separate "Metadata" table in the navigation tree
- Key metadata fields like `Currency ISO Code`, `Calendar`, `Report Frequency` are useful for DAX calculations and report context

**Reference**: Metadata extraction pattern in `V2/ColumnOrganizedStachExtension.cs` lines 116-143

---

## 5. Architecture Recommendations for Power BI Connector

### 5.1 Leverage the .NET Implementation Directly

The existing .NET `FactSet.Protobuf.Stach.Extensions` NuGet package can be consumed directly in a Power BI custom connector (built with the Power Query SDK in C#). This avoids reimplementing:
- Protobuf deserialization
- Decompression logic
- Header resolution
- Type conversion

**Dependencies to include**:
```xml
<PackageReference Include="FactSet.Protobuf.Stach.Extensions" Version="1.3.0" />
<PackageReference Include="FactSet.Protobuf.Stach" Version="1.0.1" />
<PackageReference Include="FactSet.Protobuf.Stach.V2" Version="1.0.0" />
```

### 5.2 If Pure M Language Implementation Required

Power BI certified connectors may require pure M language (no external .NET DLLs). In this case:
- Implement JSON-based parsing (skip protobuf binary, work with JSON responses)
- Use `ColumnOrganizedStachUtilities.Decompress()` pattern (which already works on JSON strings via Newtonsoft.Json)
- Map the column-iteration and row-construction logic from `GenerateTable()` to M functions

### 5.3 Suggested Connector Structure

```
PowerBIConnector/
├── FactSetConnector.pq          # Main connector entry point
├── StachParser.pq               # STACH format parser
│   ├── ParseColumnOrganized()   # From ColumnOrganizedStachExtension
│   ├── ParseRowOrganized()      # From RowOrganizedStachExtension
│   ├── DecompressColumns()      # From ColumnOrganizedStachUtilities
│   └── ResolveHeaders()         # Header table resolution
├── TypeMapping.pq               # STACH type → M type conversion
├── MetadataExtractor.pq         # Table metadata extraction
└── Navigation.pq                # Navigation table builder from primaryTableIds
```

### 5.4 Data Flow in Power BI

```
FactSet API (REST/JSON)
    │
    ▼
Power Query Source Function
    │ Json.Document(response)
    ▼
Format Detection
    │ Check for "primaryTableIds" (column) vs "tables" with row data
    ▼
STACH Parser
    │ Decompress → Resolve Headers → Build Rows → Apply Types
    ▼
Power BI Table(s)
    │ With typed columns, metadata, navigation table
    ▼
Data Model
    │ Dimension/measure classification from isDimension flag
    ▼
Reports & Dashboards
```

---

## 6. Dimension vs. Measure Column Classification

STACH column definitions include an `isDimension` boolean. This directly maps to Power BI's data categorization:
- `isDimension: true` → Text/category columns (row labels, grouping levels)
- `isDimension: false` → Numeric measure columns

The `parentId` field on dimension columns establishes a **drill-down hierarchy** (e.g., `total0` → `group1` → `group2` in the test data), which can be automatically configured as a Power BI hierarchy.

---

## 7. Hierarchical Data Support

The test data reveals FactSet returns hierarchical/grouped data with:
- Group totals (e.g., "Communications" sector total)
- Sub-group breakdowns (e.g., "Wireless Telecommunications" industry)
- Individual securities (e.g., "Bharti Airtel Limited")

This is represented via parent-child dimension columns. For Power BI:
- These map naturally to **matrix visuals** with expand/collapse
- Consider creating a **level** column to enable filtering by hierarchy depth
- The `parentId` chain: `group2.parentId → group1.id`, `group1.parentId → total0.id`

---

## 8. Test Data Insights

The test data represents FactSet Portfolio Analytics (PA) output with:

| Data Characteristic | Value |
|---|---|
| Domain | Portfolio weights analysis |
| Dimension columns | 3 levels (sector → industry → security) |
| Measure columns | Port.+Weight, Bench.+Weight, Difference |
| Typical row count | 60 rows per table |
| Metadata fields | 18 items (dates, sources, currency, calendar, etc.) |
| Null density | High in benchmark column (sparse data pattern) |
| Number format | High-precision doubles (15+ decimal places) |

**Power BI considerations**:
- Apply rounding/formatting after load to avoid display noise
- Handle sparse benchmark data gracefully (many null columns)
- Currency metadata should drive report-level formatting

---

## 9. Summary of Actionable Insights

| # | Insight | Priority | Effort |
|---|---------|----------|--------|
| 1 | Reuse .NET `FactSet.Protobuf.Stach.Extensions` NuGet directly if custom DLLs are permitted | High | Low |
| 2 | Implement decompression for range-compressed columns | High | Medium |
| 3 | Handle both column-organized and row-organized formats | High | Medium |
| 4 | Map `column.type` to Power BI types, handle `nullFormat` | High | Low |
| 5 | Build navigation table from `primaryTableIds` | Medium | Low |
| 6 | Resolve multi-level headers from header tables | Medium | Medium |
| 7 | Extract metadata as a companion table or table annotations | Medium | Low |
| 8 | Auto-create hierarchies from `parentId` dimension chains | Medium | Low |
| 9 | Use `isDimension` to classify columns in the data model | Low | Low |
| 10 | Handle rowspan/colspan in row-organized header rows | Low | High |

---

## 10. Key Source Files Reference

| File | Relevance |
|------|-----------|
| `dotnet/.../V2/ColumnOrganizedStachExtension.cs` | Core column-organized table generation logic |
| `dotnet/.../V2/RowOrganizedStachExtension.cs` | Core row-organized table generation with span handling |
| `dotnet/.../V2/StachUtilities.cs` | Protobuf value → .NET type conversion |
| `dotnet/.../V2/ColumnOrganizedStachUtilities.cs` | JSON-based decompression (directly usable) |
| `dotnet/.../Models/Table.cs` | Output model: Rows, Cells, Metadata |
| `dotnet/.../StachExtensionFactory.cs` | Factory pattern for builder instantiation |
| `python/tests/resources/*.json` | Test data representing real FactSet API responses |
