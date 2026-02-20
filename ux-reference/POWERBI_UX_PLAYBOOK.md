# Power BI UX Playbook — Personal Preference Library

> A living reference of preferred dashboard patterns, visual treatments, and
> interaction conventions curated from best-in-class Power BI and Tableau examples.

---

## Table of Contents

1. [KPI Cards](#1-kpi-cards)
2. [Conditional Formatting](#2-conditional-formatting)
3. [Bar Charts](#3-bar-charts)
4. [Time-Series & Trend Lines](#4-time-series--trend-lines)
5. [Heatmaps](#5-heatmaps)
6. [Tables & Grids](#6-tables--grids)
7. [Filters & Slicers](#7-filters--slicers)
8. [Layout & Composition](#8-layout--composition)
9. [Typography & Number Formatting](#9-typography--number-formatting)
10. [Color System](#10-color-system)
11. [Color Philosophy — "Color as Highlight"](#11-color-philosophy--color-as-highlight)
12. [Small Multiples](#12-small-multiples)
13. [Regional Breakdown with Sparklines](#13-regional-breakdown-with-sparklines)

---

## 1. KPI Cards

### 1a. Hero KPI with Delta Badge

Large headline number with a contextual change indicator and descriptive subtitle.

```
 ┌─────────────────────────────────┐
 │  Sales                          │
 │  $597,851        ▲ +30.4%       │
 │  more than same period prev yr  │
 └─────────────────────────────────┘
```

**Preferred elements:**
- Primary metric: large, bold, left-aligned
- Delta badge: green `▲ +X.X%` / red `▼ -X.X%` inline to the right
- Subtitle: muted gray, contextualizes the comparison ("vs Last 21 Days", "more than same period previous year")
- Optional inline sparkline (small 7-bar chart) beneath the number for recent trend

**Reference:** Tableau Sales KPI card, NovaCart E-Commerce dashboard

### 1b. KPI Row Grid

Multiple KPIs arranged in a horizontal row, each with a sparkline or mini-chart.

```
 ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐
 │ Gross Rev  │ │ Total Ord  │ │ Avg Order  │ │ Avg Deliv  │
 │ $1,201,846 │ │ 10,694     │ │ $680       │ │ 67 Days    │
 │ ▁▃▅▆▇█▇   │ │ ▁▂▃▅▆▇█   │ │ ▅▆▄▅▆▇▆   │ │ █▇▆▅▄▃▂   │
 └────────────┘ └────────────┘ └────────────┘ └────────────┘
```

**Preferred elements:**
- 3–5 cards in a row, equally spaced
- Each card: label (muted, small) → value (bold, large) → sparkline (tiny bars or area)
- Consistent height; no borders or very subtle rounded containers
- No heavy shadows — flat or single-pixel border

**Reference:** NovaCart header row, Aurora Bank KPI cards

### 1c. Performance KPI with YoY Comparison

Full-width rows combining a KPI, its delta, and a contextual bar chart.

```
 Sales     $733,215   ▲ 20.4% YoY  ║████████████████░░░░░░║  ← goal line
 Profit     $93,439   ▲ 14.2% YoY  ║██████████░░░░░░░░░░░░║
 Orders       1,687   ▲ 28.3% YoY  ║████████████████████░░║
 Customers      875   ▲ 22.9% YoY  ║██████████████░░░░░░░░║
```

**Preferred elements:**
- Left column: metric label + value + delta (all on one row)
- Right column: horizontal progress/bar showing magnitude relative to a target or prior period
- Subtle reference/goal line overlaid on bars
- Period label at the end (e.g., "Jan – Sep 2024")

**Reference:** Performance Overview grid dashboard

---

## 2. Conditional Formatting

### 2a. Period-Over-Period Color (IF / PREVIOUS)

Bars change color based on whether a value increased or decreased relative to the prior period.

```dax
Bar Color =
  IF(
    [Sales] > PREVIOUS([Sales]),
    "LightGreen",    -- Increase
    "LightCoral"     -- Decrease
  )
```

**Preferred treatment:**
- Green (`#90EE90` / LightGreen) for improvement
- Coral (`#F08080` / LightCoral) for decline
- Applied per-bar so the user immediately sees direction without reading numbers

**Reference:** Power BI Visual Calculations — IF/PREVIOUS example

### 2b. Max / Min Highlighting (SWITCH / MAXX / MINX)

Identify the single highest and lowest bars in a series and give them distinct colors.

```dax
Bar Color =
  SWITCH(
    TRUE(),
    [Sales] = MAXX(ALLSELECTED(...), [Sales]), "Green",
    [Sales] = MINX(ALLSELECTED(...), [Sales]), "Red",
    "SteelBlue"     -- Default
  )
```

**Preferred treatment:**
- Max bar: solid green
- Min bar: solid red or coral
- All other bars: neutral blue/steel blue
- Keep it to one highlighted bar per direction — avoids visual noise

**Reference:** Power BI Visual Calculations — SWITCH/MAXX/MINX example

### 2c. Current vs Previous Year Bars

Side-by-side or overlaid bars comparing current and prior year.

```
        Current Year    Previous Year
 Jan    ████████████    ░░░░░░░░░░
 Feb    ██████████      ░░░░░░░░░░░░
 Mar    ████████████    ░░░░░░░░
 ...
```

**Preferred treatment:**
- Current year: dark navy/primary brand color (solid)
- Previous year: light gray (muted)
- When current < previous: current bar turns red to flag underperformance
- Legend placed inline above the chart, not in a separate box

**Reference:** Tableau Sales KPI comparative bars

---

## 3. Bar Charts

### 3a. Horizontal Multi-Metric Bars

Multiple measures displayed as segmented or grouped horizontal bars per dimension row.

```
 Territory A  ████ ████████ ██ █████████ ████████████
 Territory B  ██████ ██████ ████ ████████ ██████████
 Territory C  ███ ██████████ ██████ ███████ █████████████
               Accts  Pipeline  CY Spend  PY Spend  Lifetime
```

**Preferred elements:**
- Each measure gets a distinct, non-clashing color
- Legend at top with colored squares
- Sorted by a primary metric (e.g., total spend descending)
- Labels on axis, not inside bars
- Horizontal orientation preferred for category labels (easier to read)

**Reference:** Sales Territory Assignments dashboard

### 3b. Vertical Bars with Month-Letter Axis

Clean vertical bar chart with single-letter month labels.

```
  █
  █       █
  █   █   █   █
  █   █   █   █   █       █
  █   █   █   █   █   █   █   █
  J   F   M   A   M   J   J   A   S   O   N   D
```

**Preferred elements:**
- Single-letter month abbreviations (J F M A M J J A S O N D)
- Currency formatting: `FORMAT([Sales], "£,###")` — comma-separated, no decimals
- Minimal gridlines (horizontal only, light gray)
- No chart border or background fill

**Reference:** Power BI FORMAT function example

### 3c. Top-N Mini Bar Tables

Small ranked lists pairing a category with a bar and a percentage.

```
 Top 3 Channels          Orders    Change
 1. Organic Search        4,205    ▲ 3.2%
 2. Direct                3,118    ▼ 1.1%
 3. Social Media          2,371    ▲ 5.8%
```

**Preferred elements:**
- Rank number or position indicator
- Category name, numeric value, and directional delta
- Green arrow + percentage for positive, red for negative
- Compact — no more than 3–5 rows per mini table
- Multiple mini tables side by side (Channel, Payment, Country)

**Reference:** NovaCart Top 3 lists, Average Order Value detail card

---

## 4. Time-Series & Trend Lines

### 4a. Current vs Prior Year Overlay

Two lines or areas overlaid on the same axis, one for each period.

**Preferred elements:**
- Current year: solid line, primary color, thicker stroke
- Prior year: dashed or lighter line, muted color
- Shared month x-axis (Jan–Dec)
- Y-axis with abbreviated numbers (1K, 10K, 1M)
- Subtle shaded area under current year line for emphasis

**Reference:** Aurora Bank monthly transaction volume, NovaCart revenue charts

### 4b. Inline Sparklines

Tiny trend visualizations embedded in KPI cards or table cells.

**Preferred elements:**
- 7–12 data points (weekly or monthly)
- No axes, no labels — pure shape
- Match the card's accent color
- Height: ~20–30px equivalent

**Reference:** NovaCart KPI cards, Performance Overview rows

---

## 5. Heatmaps

### 5a. Day-of-Week x Hour-of-Day

Matrix showing activity intensity by time slot.

```
         6am  8am  10am  12pm  2pm  4pm  6pm  8pm
 Mon      ░    ▒    ▓     █    ▓    ▒    ░    ░
 Tue      ░    ▒    ▓     █    █    ▓    ▒    ░
 Wed      ░    ▒    █     █    ▓    ▓    ▒    ░
 ...
```

**Preferred elements:**
- Sequential color ramp: light (low) → dark (high) in a single hue
- Row = day of week (Mon–Sun), Column = hour of day
- Cell values shown on hover (tooltip), not printed in cells
- Clear axis labels; no rotated text
- Rounded or square cells with thin gaps

**Reference:** Aurora Bank "When are our Customers Transacting?" heatmap

---

## 6. Tables & Grids

### 6a. Revenue / Detail Table

Structured data table with formatted numbers and aligned columns.

**Preferred elements:**
- Right-aligned numeric columns
- Header row: bold, subtle background fill (light gray)
- Alternating row shading: white / off-white (very subtle)
- Number format: `{0:0.00;-0.00;--}` for financial data
- Null values displayed as `--`
- Compact row height — no excessive padding

**Reference:** Aurora Bank Revenue by Merchant, Sales Territory account table

### 6b. Demographic / Categorical Breakdown

Horizontal bars within a table or standalone, grouped by category.

```
 18-24   ████████████████████████  32%
 25-34   ██████████████████        26%
 35-44   ██████████████            20%
 45-54   ████████                  12%
 55+     ██████                    10%
```

**Preferred elements:**
- Horizontal bars with percentage labels at the end
- Sorted by value descending (largest group on top)
- Subtle category labels to the left
- Single color or graduated shade

**Reference:** Aurora Bank Age Group breakdown

---

## 7. Filters & Slicers

### 7a. Right-Side Filter Panel

Vertical filter panel docked to the right edge of the dashboard.

**Preferred elements:**
- Collapsible sections per filter dimension
- Year/period toggle buttons at the top (e.g., `[2023] [2024]`)
- Dropdown selectors for categorical filters (Region, Product, etc.)
- "Clear all" link at the top of the panel
- Panel width: ~20% of canvas
- Muted background (slightly darker than canvas)

**Reference:** Sales Territory Assignments filter panel, Aurora Bank filters

### 7b. Inline Slicer Chips

Horizontal filter chips/buttons embedded in the header area.

**Preferred elements:**
- Pill-shaped buttons for mutually exclusive selections
- Active state: filled primary color with white text
- Inactive state: outlined, muted text
- Placed directly above the chart they control

---

## 8. Layout & Composition

### 8a. Dashboard Anatomy

```
 ┌──────────────────────────────────────────┬───────────┐
 │  Title Bar / Page Navigation             │           │
 ├────────┬────────┬────────┬────────┐      │  Filters  │
 │ KPI 1  │ KPI 2  │ KPI 3  │ KPI 4  │      │  Panel    │
 ├────────┴────────┴────────┴────────┤      │           │
 │                                    │      │  Year     │
 │   Primary Chart Area               │      │  Region   │
 │   (bar chart / line chart)         │      │  Product  │
 │                                    │      │  ...      │
 ├──────────────────┬─────────────────┤      │           │
 │  Secondary Viz   │  Detail Table   │      │           │
 │  (map / heatmap) │  or Top-N list  │      │           │
 └──────────────────┴─────────────────┴───────────────────┘
```

**Preferred principles:**
- KPI cards always at the top — first thing the eye hits
- Primary visualization takes the largest area (60%+ of width)
- Filter panel to the right (never bottom)
- Supporting visuals and detail tables in the lower portion
- 2–3 column grid maximum; avoid cluttering
- Consistent padding/margins (8–12px gaps)
- Page navigation: tabs or numbered pages at the top

**Reference:** All dashboards follow this general Z-pattern layout

### 8b. Information Hierarchy

1. **KPIs** — answer "what happened?" at a glance
2. **Trend charts** — answer "how is it changing?"
3. **Breakdown charts** — answer "where / who / why?"
4. **Detail tables** — answer "show me the specifics"
5. **Filters** — let the user drill into their own questions

---

## 9. Typography & Number Formatting

### Number Formats

| Context | Format | Example |
|---|---|---|
| Currency (large) | `$#,###` or `£,###` | $597,851 |
| Currency (precise) | `$#,##0.00` | $93,439.14 |
| Percentage | `+#0.0%; -#0.0%` | +30.4% |
| Count | `#,###` | 10,694 |
| Abbreviated | `#.#K` / `#.#M` | 1.2M |
| Null | `--` | -- |
| Duration | `## Days` | 67 Days |

### Font Hierarchy

| Element | Weight | Size (relative) |
|---|---|---|
| KPI value | Bold / Semibold | 2.0–2.5x base |
| KPI label | Regular | 0.85x base |
| KPI delta | Semibold | 1.0x base |
| Chart title | Semibold | 1.1x base |
| Axis labels | Regular | 0.85x base |
| Table header | Bold | 1.0x base |
| Table body | Regular | 1.0x base |
| Filter label | Regular | 0.9x base |

---

## 10. Color System

### Semantic Palette

| Role | Color | Hex | Usage |
|---|---|---|---|
| Positive / Up | Light Green | `#90EE90` | Increase deltas, above-target bars |
| Negative / Down | Light Coral | `#F08080` | Decrease deltas, below-target bars |
| Current Period | Dark Navy | `#1B2A4A` | Current year bars, primary lines |
| Prior Period | Light Gray | `#D0D0D0` | Previous year bars, muted lines |
| Default Bar | Steel Blue | `#4682B4` | Standard bars (no conditional logic) |
| Highlight Max | Green | `#2E8B57` | MAXX-highlighted bar |
| Highlight Min | Red | `#CD5C5C` | MINX-highlighted bar |
| Background | White | `#FFFFFF` | Canvas |
| Filter Panel BG | Off-White | `#F5F5F5` | Filter panel background |
| Muted Text | Gray | `#888888` | Subtitles, secondary labels |

### Multi-Metric Series Palette

For charts with 3–6 distinct measures, use a palette with enough contrast:

```
#1B2A4A  (navy)
#4682B4  (steel blue)
#5DADE2  (sky blue)
#48C9B0  (teal)
#F5B041  (amber)
#E74C3C  (red — only if needed for negatives)
```

---

## 11. Color Philosophy — "Color as Highlight"

> "Color is not decoration — it's a tool."

### 11a. Grayscale-First Design

Start every dashboard in grayscale. Only add color when it serves a specific analytical purpose.

**Core principles:**
- Default state: all visuals in grayscale (black, white, grays)
- Add color ONLY to draw attention to what matters
- Every colored element should answer: "Why is this colored?"
- If everything is colorful, nothing stands out

**When to add color:**
1. **Distinguish categories** — when the user must tell groups apart (e.g., product lines on one chart)
2. **Highlight deviations** — values above/below a threshold (median, target, prior period)
3. **Signal status** — good/bad/warning semantic meaning

### 11b. Threshold-Based Highlighting

Color individual data points based on whether they exceed a statistical threshold (e.g., median, 90th percentile, target).

```
 Email Performance Dashboard (grayscale-first)

 ┌─────────────────────────────────────────┐
 │  Open Rate by Campaign                  │
 │  ░░░ ░░░ ░░░ ███ ░░░ ███ ░░░ ░░░ ███  │
 │                ▲         ▲           ▲   │
 │           (above avg — highlighted)      │
 └─────────────────────────────────────────┘
```

**Preferred treatment:**
- Default bars: neutral gray (`#C0C0C0`)
- Above-threshold bars: single accent color (e.g., purple `#7B68EE` or brand color)
- Threshold line: dashed, labeled ("Avg", "Median", "Target")
- Limit highlighted bars to roughly 20–30% of the total — keeps the signal strong
- Avoid using two highlight colors; one accent vs. gray is enough

**Reference:** BI Bites "Color as Highlight" article, Email Performance dashboard

---

## 12. Small Multiples

### 12a. Regional / Dimensional Grid

A grid of identical chart panels — one per dimension value — enabling at-a-glance comparison across all segments.

```
 ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
 │ Great Lakes   │ │ Midsouth     │ │ Northeast    │
 │ 2017: $1.28  │ │ 2017: $1.31  │ │ 2017: $1.64  │
 │ 2016: $1.20  │ │ 2016: $1.23  │ │ 2016: $1.56  │
 │ Chg: +6.7%   │ │ Chg: +6.5%   │ │ Chg: +5.1%   │
 │ ██ ░░ (vol)  │ │ ██ ░░ (vol)  │ │ ██ ░░ (vol)  │
 │ ╱‾‾╲ (trend) │ │ ╱‾‾╲ (trend) │ │ ╱‾‾╲ (trend) │
 ├──────────────┤ ├──────────────┤ ├──────────────┤
 │ Plains       │ │ South Central│ │ Southeast    │
 │ ...          │ │ ...          │ │ ...          │
 ├──────────────┤ ├──────────────┤ ├──────────────┤
 │ Total US     │ │ West         │ │ (empty cell) │
 │ ...          │ │ ...          │ │              │
 └──────────────┘ └──────────────┘ └──────────────┘
```

**Preferred elements:**
- 3×3 or 4×3 grid — one panel per region/segment
- Each panel has identical structure: KPI values → comparison bars → trend line
- Current period vs prior period shown as side-by-side bars (colored vs gray)
- Change percentage with directional formatting (green positive, red negative)
- Consistent y-axis scale across ALL panels (critical for honest comparison)
- Panel titles: bold, top-left within each cell
- Minimal internal chrome — no individual legends, axes shared or implied
- Total / aggregate panel included in the grid for context

**When to use:**
- Comparing the same metric across 5–15 segments (regions, products, cohorts)
- When a single chart with 15 series would be unreadable
- When pattern shape matters as much as absolute values

**Reference:** Historical Avocado Price & Volume dashboard (Andy Kriebel / @VizWizBI)

---

## 13. Regional Breakdown with Sparklines

### 13a. Table with Inline Sparklines and Conditional MoM/YoY

A data table where each row is a dimension (region, product) and columns include KPI values, inline sparklines, and conditionally formatted period-over-period percentages.

```
 ┌──────────┬───────────┬─────────┬────────┬─────────┬────────┐
 │ Region   │ Revenue   │  Trend  │ MoM %  │ YoY %   │ Orders │
 ├──────────┼───────────┼─────────┼────────┼─────────┼────────┤
 │ North    │ $245,812  │ ▁▃▅▆▇█  │ +3.2%  │ +12.4%  │ 1,205  │
 │ South    │ $198,445  │ ▅▆▇▆▅▄  │ -1.8%  │  +8.1%  │   983  │
 │ East     │ $312,667  │ ▁▂▃▅▇█  │ +5.1%  │ +18.3%  │ 1,567  │
 │ West     │ $178,230  │ ▇▆▅▄▃▂  │ -4.2%  │  -2.1%  │   891  │
 └──────────┴───────────┴─────────┴────────┴─────────┴────────┘
                                    green    green
                                    red      green
                                    green    green
                                    red      red
```

**Preferred elements:**
- Sparkline column: 6–12 point trend embedded in the table cell
- MoM and YoY columns: conditionally colored text (green positive, red negative)
- Revenue / primary metric: bold, right-aligned
- Sparkline color matches the overall trend direction (green if trending up, gray/red if down)
- Sort by primary metric descending by default
- Header row with area chart or summary KPI above the table
- Period selector (MoM / QoQ / YoY) as inline toggle chips above the table

**Reference:** Sales dashboard with orange/blue theme, regional breakdown table

### 13b. Area Chart Header with MoM / YoY Indicators

A filled area chart at the top of the dashboard showing the primary metric over time, with MoM and YoY deltas overlaid or adjacent.

```
 ┌─────────────────────────────────────────┐
 │  Total Sales: $935,154                  │
 │  MoM: ▲ +2.8%    YoY: ▲ +14.1%        │
 │                                         │
 │  ╱‾‾‾╲    ╱‾‾‾‾‾╲                      │
 │ ╱      ╲╱╱        ╲╱‾‾‾‾╲    ╱‾‾╲      │
 │╱                          ╲╱╱     ╲     │
 │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   │
 │ Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  │
 └─────────────────────────────────────────┘
```

**Preferred elements:**
- Filled area (gradient fade from brand color to transparent)
- Total KPI value top-left, large and bold
- MoM and YoY badges next to the total (same delta badge style as KPI cards)
- Smooth curve (not stepped)
- X-axis: month abbreviations; Y-axis: hidden or minimal
- Orange or brand accent for the fill; white or light background

**Reference:** Sales dashboard area chart header

---

## Quick Reference: DAX Patterns

### Period-over-Period Conditional Color
```dax
Bar Color =
  IF(
    [Sales] > PREVIOUS([Sales]),
    "LightGreen",
    "LightCoral"
  )
```

### Max / Min Highlighting
```dax
Bar Color =
  SWITCH(
    TRUE(),
    [Sales] = MAXX(ALLSELECTED(Table[Category]), [Sales]), "Green",
    [Sales] = MINX(ALLSELECTED(Table[Category]), [Sales]), "Red",
    "SteelBlue"
  )
```

### Currency Formatting
```dax
Formatted Sales = FORMAT([Sales], "£,###")
```

### Year-Over-Year Difference (Absolute)
```dax
YOY Sales =
  VAR CY = [Sales]
  VAR PY =
    CALCULATE(
      [Sales],
      DATEADD('Date Table'[Date], -1, YEAR)
    )
  VAR _change = CY - PY
  RETURN
    FORMAT(_change, "$#,###;($#,###);$0")
```

### Year-Over-Year Percentage Change
```dax
YOY % =
  VAR CY = [Sales]
  VAR PY =
    CALCULATE(
      [Sales],
      DATEADD('Date Table'[Date], -1, YEAR)
    )
  RETURN
    DIVIDE(CY - PY, PY, 0)
```

---

## Changelog

| Date | Update |
|---|---|
| 2026-02-20 | Added Color Philosophy, Small Multiples, Regional Sparkline Tables, YOY DAX patterns (14 screenshots total) |
| 2026-02-20 | Initial playbook created from 10 reference screenshots |

---

*This is a living document. Add new patterns as you encounter dashboards worth emulating.*
