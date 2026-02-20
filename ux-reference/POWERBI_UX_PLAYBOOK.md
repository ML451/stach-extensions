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
14. [Variance Analysis (IBCS / Zebra BI Style)](#14-variance-analysis-ibcs--zebra-bi-style)
15. [Master-Detail & Linked Panels](#15-master-detail--linked-panels)
16. [Dark Theme Dashboards](#16-dark-theme-dashboards)
17. [Treemaps & Proportional Views](#17-treemaps--proportional-views)
18. [Scatter & Bubble Charts](#18-scatter--bubble-charts)
19. [Editorial / Journalistic Chart Style](#19-editorial--journalistic-chart-style)

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

### 12b. Asymmetric / Weighted Small Multiples

Small multiples where one dominant panel is larger than the others, reflecting that category's outsized proportion or importance.

```
 Share of new S&P 500 directors by demographic

 ┌───────────────────────────┐  ┌────────────┐
 │  White                    │  │  Asian     │
 │  100%─                    │  │  50%─      │
 │       █ █ █ █ █ █ █ █ █  │  │   █ █ █ █  │
 │       █ █ █ █ █ █ █ █ █  │  │   █ █ █ █  │
 │       █ █ █ █ █ █ █ █ █  │  │            │
 │   0%─                     │  │  0%─       │
 │       '16    '20    '26*  │  │  '16  '26* │
 │                    81.4%  │  │       8.9% │
 ├───────────────────────────┤  ├────────────┤
 │                           │  │  Hispanic  │
 │    (larger panel for      │  │  50%─      │
 │     dominant category)    │  │   █ █ █ █  │
 │                           │  │  0%─  5.3% │
 │                           │  ├────────────┤
 │                           │  │  Black     │
 │                           │  │  50%─      │
 │                           │  │   █ █ 2.7% │
 │                           │  │  0%─       │
 └───────────────────────────┘  └────────────┘
    ← dominant ~60% width →      ← 40% →
```

**Preferred elements:**
- Dominant category gets a larger panel (50–60% of total width) with its own y-axis scale (e.g., 0–100%)
- Remaining categories share a column of smaller panels with a different, zoomed-in scale (e.g., 0–50%) so their trends are readable
- All panels share the same x-axis (time) and bar style
- Single color for all bars — no conditional formatting; the shape tells the story
- End-value callout: the most recent bar annotated with a large, bold number (e.g., `81.4%`)
- Yearly bars with abbreviated year labels (`'16`, `'18`, `'20`, `'22`, `'24`, `'26*`)
- Asterisk footnote for incomplete periods (`*Through Feb. 17`)
- Grouping label for related panels (e.g., "People of color" brackets Asian + Hispanic + Black)

**When to use:**
- One category dominates (>60%) and others are much smaller
- Equal-sized panels would compress the smaller categories into unreadable slivers
- The story is about both the dominant share AND the trends in smaller segments

**When NOT to use:**
- Categories are roughly equal in magnitude — use equal-sized panels (12a) instead
- More than 5–6 panels — becomes too fragmented

**Reference:** WSJ "Share of new S&P 500 directors by demographic" (Stephanie Stamm)

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

## 14. Variance Analysis (IBCS / Zebra BI Style)

> IBCS (International Business Communication Standards) — a notation system for
> business charts and tables that prioritizes clarity, consistency, and comparability.

### 14a. Waterfall Charts (Actual vs Plan / Actual vs Prior Year)

Bridge charts showing how a starting value transforms into an ending value through incremental positive/negative changes.

```
 Actual vs Previous Year                Actual vs Plan
 ┌──────────────────────────┐           ┌──────────────────────────┐
 │  PY     +Δ        AC     │           │  PL     +Δ        AC     │
 │ ┌───┐            ┌───┐   │           │ ┌───┐            ┌───┐   │
 │ │567│  ┌─────┐   │928│   │           │ │922│   ┌───┐    │928│   │
 │ │   │  │+361 │   │   │   │           │ │   │   │ +5│    │   │   │
 │ │   │  │green│   │   │   │           │ │   │   │grn│    │   │   │
 │ └───┘  └─────┘   └───┘   │           │ └───┘   └───┘    └───┘   │
 │         +63.6%            │           │         +0.6%            │
 └──────────────────────────┘           └──────────────────────────┘
```

**Preferred elements:**
- Three-bar bridge: start value (gray) → delta bar (green positive / red negative) → end value (gray/black)
- Delta bar labeled with absolute value AND percentage
- Positive delta: green fill; negative delta: red fill
- Start/end bars: neutral gray or dark
- Title states the comparison clearly: "Actual vs Previous Year", "Actual vs Plan"
- Side-by-side waterfalls for PY and Plan comparisons on the same row
- Percentage change displayed prominently below or beside the delta bar

**Reference:** Zebra BI Sales dashboard — dual waterfall layout

### 14b. Monthly Variance Bars (AC vs PY with Green/Red Deltas)

Paired bar chart showing actual (AC) values alongside the variance (delta) from a reference period, month by month.

```
 AC and PY by Month (in K)

 Jan    ██████ +12%   ████████▓▓▓
 Feb    █████  +8%    ███████▓▓
 Mar    ███████ +15%  █████████▓▓▓▓
 Apr    ████   -3%    ██████▒▒
 May    ██████ +10%   ████████▓▓▓
 ...
        ──AC──         ──PY── ──Δ──
                       green=positive  red=negative
```

**Preferred elements:**
- Each month shows: AC bar (solid) + delta annotation (% above/beside)
- Delta is visualized as a colored extension: green for positive variance, red for negative
- PY shown as a reference mark or lighter bar behind the AC bar
- Percentage labels directly above or beside each month pair
- Compact horizontal layout — all months visible without scrolling
- Consistent scale across months

**Reference:** Zebra BI "AC and PY by Month" chart

### 14c. Integrated Variance Table (Delta Bars + Lollipop Indicators)

A table combining absolute values, inline delta bars, and lollipop/dot indicators for percentage variance.

```
 ┌───────────────┬────────┬────────────────┬──────────────────┐
 │ Group         │   AC   │    ΔPL         │    ΔPL%          │
 ├───────────────┼────────┼────────────────┼──────────────────┤
 │ Prod Grp A    │   425  │ ▓▓▓▓▓▓▓  +38  │  ────●  +9.8%   │
 │ Prod Grp B    │   312  │ ▓▓▓▓  +22     │  ──●    +7.6%   │
 │ Prod Grp C    │   191  │ ▒▒▒  -15      │  ●──    -7.3%   │
 ├───────────────┼────────┼────────────────┼──────────────────┤
 │ Total         │   928  │ ▓  +5         │  ●      +0.6%   │
 └───────────────┴────────┴────────────────┴──────────────────┘
                            green=positive    ● = lollipop dot
                            red=negative      line from zero
```

**Preferred elements:**
- AC column: right-aligned absolute values
- ΔPL column: inline horizontal bar showing magnitude of variance (green positive, red negative)
- ΔPL% column: lollipop/dot chart — a dot on a line anchored at zero, extending left (negative) or right (positive)
- Total row at the bottom, visually distinct (bold or separator line)
- Sortable by any column
- Product category or group in leftmost column
- No background fills on rows — let the inline charts carry the visual weight
- Compact: each row ~24–30px height

**DAX concept for variance:**
```dax
ΔPL = [Actual] - [Plan]
ΔPL% = DIVIDE([Actual] - [Plan], [Plan], 0)
```

**Reference:** Zebra BI "AC, PY, PL by Group" and "by Product Category" tables

### 14d. Filter Bar with Metric / Period / Aggregation Toggles

A horizontal filter strip at the top that controls the entire dashboard view.

```
 ┌──────────────────────────────────────────────────────┐
 │  [Revenue ▼]  [Oct ▼]  [2018 ▼]  [Month] [YTD]     │
 └──────────────────────────────────────────────────────┘
```

**Preferred elements:**
- Dropdown selectors for: Metric (Revenue, Profit, Units), Month, Year
- Toggle buttons for aggregation: Month vs YTD (mutually exclusive, pill-style)
- Single horizontal row — never stacked
- Placed at the very top, spanning full width
- Muted background, aligned left

**Reference:** Zebra BI dashboard filter bar

---

## 15. Master-Detail & Linked Panels

### 15a. Click-to-Filter Security/Entity Panel

A ranked bar chart on the left that, when clicked, drives detail charts on the right.

```
 ┌──────────────────────┐  ┌───────────────────────────────┐
 │ Performance by       │  │ RRC — Detail View             │
 │ Security             │  │                               │
 │                      │  │ Security Price                │
 │ RRC  ████████ $409M  │  │ ╱‾‾╲╱‾‾‾‾╲                  │
 │ TWTR ███████  $367M  │  │                               │
 │ CLF  ██████   $312M  │  │ $ Exposure                   │
 │ CHK  █████    $278M  │  │ ▓▓▓ ▓▓▓ ███ ███ ▓▓▓ ███     │
 │ VALE ████     $245M  │  │ Short=orange  Long=blue       │
 │ ...                  │  │                               │
 │                      │  │ Cumulative Alpha              │
 │ [Click a security    │  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ (area)      │
 │  to view trends]     │  │                               │
 │                      │  │ Cumulative RoR                │
 │ Filter by Sector ▼   │  │ ░░░░░░░░░░░░░░░ (area)       │
 │ Date Range    ▼      │  │                               │
 └──────────────────────┘  └───────────────────────────────┘
```

**Preferred elements:**
- Left panel (30–35% width): ranked horizontal bars sorted by primary metric descending
- Multi-metric bars per row (e.g., Alpha in amber, Exposure in teal, RoR in green)
- Right panel (65–70% width): 3–4 vertically stacked time-series charts, each focused on a different measure
- Stacked panels share the same x-axis (time) — aligned vertically for easy cross-metric comparison
- Click instruction text: "Click a security to view trends" — discoverable interaction cue
- Sector/date filters at the bottom of the left panel
- Values formatted with abbreviated currency: `$409M`, `$1.2B`
- Hover tooltip on each bar for exact figures

### 15b. Stacked Vertical Time-Series Panels

Multiple time-series charts stacked vertically with a shared time axis, each showing a different metric for the selected entity.

```
 ┌─────────────────────────────┐
 │ Security Price              │
 │ ╱‾╲  ╱‾‾‾╲    ╱‾╲          │
 │╱    ╲╱      ╲╱╱    ╲        │
 ├─────────────────────────────┤
 │ $ Exposure (Long/Short)     │
 │ ▓▓▓ ▓▓▓ ███ ███ ▓▓▓ ███   │
 │ orange=Short  blue=Long     │
 ├─────────────────────────────┤
 │ Cumulative Alpha            │
 │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓ (green area)│
 ├─────────────────────────────┤
 │ Cumulative RoR              │
 │ ░░░░░░░░░░░░░░ (gray area) │
 └─────────────────────────────┘
  2018     2019     2020    2021
```

**Preferred elements:**
- 3–4 panels stacked, equal height
- Shared x-axis at the bottom only (avoid repeating on each panel)
- Each panel: single chart type (line, bar, area) with its own y-axis
- Chart type varies by measure: line for price, bar for exposure (with Long/Short color split), area for cumulative metrics
- Thin horizontal dividers between panels
- No per-panel legends — use a shared legend at the top or color-code the chart titles

**Reference:** Security Exposures & Performance dashboard — right detail panel

---

## 16. Dark Theme Dashboards

### 16a. Investment / Portfolio Dark Theme

A dark-background dashboard for financial or portfolio data.

```
 ┌─────────────────────────────────────────────────────────┐
 │  ▪ Dark BG (#1A1A2E or #0F0F1A)                        │
 │                                                         │
 │ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────┐│
 │ │ Investment │ │ Portfolio  │ │ Today G/L  │ │Total G/L││
 │ │ ₹17,041   │ │ ₹18,413   │ │ -₹70.7     │ │₹1,372  ││
 │ │            │ │            │ │ -1.3% red  │ │+8.1% grn││
 │ └────────────┘ └────────────┘ └────────────┘ └────────┘│
 │                                                         │
 │  Total Gain/Loss (purple area chart)                    │
 │  ╱‾‾╲    ╱‾‾‾‾╲╱‾╲                                    │
 │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ (purple gradient)                │
 │ - - - - - - - - - -  (dashed zero/reference line)      │
 │                                                         │
 │ ┌─ My Holdings ────────────────────────────────────┐    │
 │ │ AAPL   $187.2  +15.1%  ▁▃▅▆▇█  green            │    │
 │ │ GOOG   $142.8  +10.0%  ▁▂▅▆▇█  green            │    │
 │ │ ITC    $418.5  -10.5%  █▇▅▃▂▁  red              │    │
 │ └──────────────────────────────────────────────────┘    │
 │                                                         │
 │ ┌─ Top Gainers ─┐  ┌─ Top Losers ──┐  ┌─ Sector ──┐   │
 │ │ AAPL  +15.1%  │  │ ITC   -10.5%  │  │ Tech  60% │   │
 │ │ GOOG  +10.0%  │  │ JPM    -2.9%  │  │ Fin   18% │   │
 │ │ MSFT  +28.5%  │  │ XOM    -1.0%  │  │ Cons  16% │   │
 │ └───────────────┘  └───────────────┘  │ Energy 6% │   │
 │                                        └───────────┘   │
 └─────────────────────────────────────────────────────────┘
```

**Dark theme color palette:**

| Role | Color | Hex | Usage |
|---|---|---|---|
| Background | Deep Navy | `#1A1A2E` | Canvas / page background |
| Card BG | Dark Slate | `#16213E` | Card and panel backgrounds |
| Text Primary | White | `#EAEAEA` | KPI values, headers |
| Text Secondary | Muted Gray | `#8892A0` | Labels, subtitles |
| Accent / Trend | Purple | `#7B68EE` | Area fills, sparklines, brand accent |
| Positive | Green | `#00C853` | Gains, positive deltas |
| Negative | Red/Coral | `#FF5252` | Losses, negative deltas |
| Dividers | Subtle | `#2A2A4A` | Card borders, separators |

**Preferred elements:**
- High contrast: white/light text on dark backgrounds
- Reduce brightness: use muted greens (`#00C853`) instead of neon
- Purple or teal as the brand accent (avoid blue-on-blue clashes)
- Cards slightly lighter than the background (`#16213E` on `#1A1A2E`) for layering
- Dashed reference/zero lines visible against dark background
- Sparklines in the holdings table match the gain/loss color per row
- Top Gainers (green-titled) and Top Losers (red-titled) as paired mini-tables

**When to use dark theme:**
- Financial / trading / portfolio dashboards where users work long sessions
- Real-time monitoring dashboards
- Presentation mode / executive briefings on large screens

**Reference:** Investment Portfolio dashboard

---

## 17. Treemaps & Proportional Views

### 17a. Category Treemap

A space-filling rectangular layout showing proportional sizes of categories.

```
 Ventes by Catégorie
 ┌──────────────────┬────────────┬───────┐
 │                  │            │       │
 │      ERP         │   Ventes   │  CRM  │
 │    (largest)     │            │       │
 │                  ├────────┬───┤       │
 │                  │Planif. │Fin│       │
 └──────────────────┴────────┴───┴───────┘
```

**Preferred elements:**
- Each rectangle proportional to its metric value (revenue, count, etc.)
- Category label inside each rectangle (truncate if too small)
- Value shown inside or on hover
- Color: either a single-hue gradient (larger = darker) or distinct category colors
- No more than 8–12 categories — beyond that, group small ones into "Other"
- No heavy borders; thin white gaps between rectangles

**When to use:**
- Showing part-to-whole relationships across many categories
- When a pie chart would have too many slices
- Comparing relative sizes at a glance

**When NOT to use:**
- When precise comparison matters (bar charts are better for that)
- When categories are similarly sized (differences become invisible)

**Reference:** Démo Le CFO masqué — "Ventes by Catégorie" treemap, Executive Metrics treemap

---

## 18. Scatter & Bubble Charts

### 18a. Multi-Dimension Bubble Chart

A scatter plot where the x-axis, y-axis, and bubble size each encode a different metric. Color encodes category.

```
                 High Margin
                    │
                    │       ○ ERP
                    │    (large bubble = high qty)
                    │
     Low Revenue ───┼─────────────── High Revenue
                    │
                    │  ● CRM
                    │  (small bubble = low qty)
                    │
                 Low Margin
```

**Preferred elements:**
- X-axis: primary metric (Revenue, Sales)
- Y-axis: secondary metric (Margin, Profit %)
- Bubble size: volume metric (Quantity, Count)
- Bubble color: category (product line, segment)
- Semi-transparent fills so overlapping bubbles remain readable
- Quadrant lines or reference lines to segment performance zones
- Tooltip on hover: category name + all three metric values
- Limit to 15–20 bubbles maximum

**When to use:**
- Exploring relationships between 2–3 metrics simultaneously
- Identifying outliers (e.g., high revenue but low margin)
- Portfolio or product performance matrix

**Reference:** Démo Le CFO masqué — "Ventes, Marge brute, Qté by Catégorie" bubble chart

### 18b. Dual-Axis Dot + Line Chart

Combining dots (one measure) with a line (another measure) on a shared time axis to show two related metrics.

```
 Ventes, Marge by Mois

 $│         ●              ●
  │    ●         ●    ●
  │ ●                          ●    ← dots = Ventes
  │╱‾‾‾╲╱‾‾‾╲╱‾‾‾╲╱‾‾‾╲╱‾‾╲
  │                                  ← line = Marge
  └─────────────────────────────
    Jan  Feb  Mar  Apr  May  Jun
```

**Preferred elements:**
- Dots: larger, filled circles for the primary metric (easier to read individually)
- Line: continuous thin line for the secondary metric (shows trend)
- Separate y-axes if scales differ significantly (left axis for dots, right for line)
- Color-differentiated: dots in one color, line in another
- Avoid more than 2 series — dual-axis charts become confusing with 3+

**Reference:** Démo Le CFO masqué — "Ventes, Marge by Mois" chart

---

## 19. Editorial / Journalistic Chart Style

> Inspired by WSJ, NYT, and FT data visualization teams — clean, purposeful,
> typography-forward charts designed for a wide audience.

### 19a. Core Principles

**Simplicity over decoration:**
- One chart = one message. No dual-purpose visuals.
- Remove all non-essential elements: gridlines, borders, backgrounds, legends (if only one series)
- Let the data shape carry the narrative

**Typography does the heavy lifting:**
- Large, clear chart title that states the insight (not just the topic)
  - Good: "White directors still dominate S&P 500 boards"
  - Weak: "Share of directors by demographic"
- Subtitle provides context, time range, or methodology note
- End-value annotations: the most recent data point labeled in bold, directly on the chart
- Axis labels: minimal, abbreviated (`'16`, `'18`, `'20` not `2016`, `2018`, `2020`)

**Color restraint:**
- Single hue for all bars/lines (e.g., teal `#2E8B8B`, WSJ blue `#0274B6`)
- Color only introduced to distinguish when absolutely necessary
- Gray for reference, context, or secondary data
- Consistent with the "Color as Highlight" philosophy (Section 11)

### 19b. End-Value Annotation Pattern

The most recent data point is called out with a prominent number placed at the end of the series.

```
 █                              81.4%
 █  █                           ←── large, bold
 █  █  █  █                         annotation at
 █  █  █  █  █  █  █  █  █  █      final bar
 '16   '18   '20   '22   '24  '26*
```

**Preferred elements:**
- Final bar slightly separated or same spacing as others
- Value label: bold, 1.5–2x axis label font size, positioned to the right of or above the final bar
- No other bars labeled (avoid clutter) — previous values available on hover/tooltip
- Asterisk on incomplete periods with footnote below

### 19c. Footnotes & Source Attribution

Every editorial chart includes proper attribution below the visual.

```
 ┌─────────────────────────────────────────────┐
 │  [Chart content]                            │
 │                                             │
 │  *Through Feb. 17                           │
 │  Source: ISS Corporate                      │
 │  Stephanie Stamm / WSJ                      │
 └─────────────────────────────────────────────┘
```

**Preferred elements:**
- Footnotes: italic or smaller text, asterisk-keyed, directly below the chart
- Source line: "Source: [Data Provider]" in muted text
- Author/publication credit: smallest text, bottom-right or bottom-left
- In Power BI: use a text box or card visual below the chart for attribution
- Keep all three lines compact — they inform but don't compete with the data

### 19d. Grouped Category Labels

When small multiples represent sub-groups of a larger category, use a bracket or header label to show the grouping.

```
                     ┌── People of color ──┐
 ┌──────────┐        ┌──────┐ ┌──────┐ ┌──────┐
 │  White   │        │Asian │ │Hisp. │ │Black │
 │  (main)  │        │      │ │      │ │      │
 └──────────┘        └──────┘ └──────┘ └──────┘
```

**Preferred elements:**
- Group label above or to the left of the sub-panels
- Subtle bracket or line connecting the grouped panels
- Group label in lighter weight than individual panel titles
- Helps the reader understand the taxonomy without a separate legend

**Reference:** WSJ "Share of new S&P 500 directors by demographic" (Stephanie Stamm)

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

### Actual vs Plan Variance
```dax
ΔPL = [Actual] - [Plan]

ΔPL% = DIVIDE([Actual] - [Plan], [Plan], 0)
```

### Actual vs Prior Year Variance
```dax
ΔPY =
  VAR _AC = [Actual]
  VAR _PY =
    CALCULATE(
      [Actual],
      DATEADD('Date Table'[Date], -1, YEAR)
    )
  RETURN
    _AC - _PY

ΔPY% =
  VAR _AC = [Actual]
  VAR _PY =
    CALCULATE(
      [Actual],
      DATEADD('Date Table'[Date], -1, YEAR)
    )
  RETURN
    DIVIDE(_AC - _PY, _PY, 0)
```

### Waterfall Bridge Value (for Zebra BI)
```dax
-- Use as a measure in Zebra BI waterfall visual:
-- Column 1: PY or Plan (reference)
-- Column 2: This variance measure (auto-bridges)
-- Column 3: AC (result)
-- Zebra BI handles the waterfall rendering natively.
Variance = [Actual] - [Plan]
```

### Today's Gain/Loss (Portfolio)
```dax
Today G/L =
  VAR _current = [Current Price] * [Shares]
  VAR _prevClose = [Previous Close] * [Shares]
  RETURN
    _current - _prevClose

Today G/L % = DIVIDE([Today G/L], [Previous Close] * [Shares], 0)
```

---

## Changelog

| Date | Update |
|---|---|
| 2026-02-20 | Added Asymmetric Small Multiples, Editorial/Journalistic Chart Style (20 screenshots total) |
| 2026-02-20 | Added Variance Analysis/IBCS, Master-Detail Panels, Dark Theme, Treemaps, Scatter/Bubble Charts (19 screenshots total) |
| 2026-02-20 | Added Color Philosophy, Small Multiples, Regional Sparkline Tables, YOY DAX patterns (14 screenshots total) |
| 2026-02-20 | Initial playbook created from 10 reference screenshots |

---

*This is a living document. Add new patterns as you encounter dashboards worth emulating.*
