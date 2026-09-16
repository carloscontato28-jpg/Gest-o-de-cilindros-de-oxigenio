---
name: Oxigênio Domiciliar Caieiras
colors:
  surface: '#f8f9ff'
  surface-dim: '#d0dbed'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dee9fc'
  surface-container-highest: '#d9e3f6'
  on-surface: '#121c2a'
  on-surface-variant: '#434655'
  inverse-surface: '#27313f'
  inverse-on-surface: '#eaf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#1d4ed8'
  on-secondary: '#ffffff'
  secondary-container: '#4069f2'
  on-secondary-container: '#fffbff'
  tertiary: '#006329'
  on-tertiary: '#ffffff'
  tertiary-container: '#007f36'
  on-tertiary-container: '#c7ffca'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#dce1ff'
  secondary-fixed-dim: '#b7c4ff'
  on-secondary-fixed: '#001551'
  on-secondary-fixed-variant: '#0039b5'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#f8f9ff'
  on-background: '#121c2a'
  surface-variant: '#d9e3f6'
  status-success-bg: '#dcfce7'
  status-success-text: '#166534'
  status-warning-bg: '#fef9c3'
  status-warning-border: '#ca8a04'
  status-warning-text: '#854d0e'
  status-danger-bg: '#fee2e2'
  status-danger-border: '#dc2626'
  status-danger-text: '#991b1b'
  surface-page: '#f9fafb'
  surface-card: '#ffffff'
  surface-subtle: '#f3f4f6'
  border-subtle: '#e5e7eb'
  text-muted: '#6b7280'
typography:
  headline-xl:
    fontFamily: Poppins
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Poppins
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Poppins
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: 0em
  headline-sm:
    fontFamily: Poppins
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0em
  metric-display:
    fontFamily: Poppins
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  body-lg:
    fontFamily: Open Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Open Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Open Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
  table-cell-condensed:
    fontFamily: Open Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: -0.01em
  label-md:
    fontFamily: Open Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Open Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.01em
  badge-status:
    fontFamily: Open Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  space-xxs: 0.125rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-base: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 3rem
  gutter-desktop: 1.5rem
  gutter-mobile: 0.75rem
  max-width-content: 1440px
---

## Brand & Style

This design system serves the Municipal Government of Caieiras specifically for monitoring and managing home oxygen therapy logistics (`Oxigenoterapia Domiciliar`). The brand archetype is that of an authoritative, dependable municipal health provider where precision, speed of assessment, and absolute operational clarity are paramount.

### Design Tone & Personality
- **Institutional & Trustworthy:** Built around clean civic governance tones, conveying reliability, compliance, and clinical reassurance.
- **Utilitarian & Minimalist:** Free of decorative noise, promotional distraction, or playful embellishments. Functional clarity takes precedence over ornamentation.
- **Strictly Professional:** Uses zero emojis across all workflows; visual status is conveyed strictly via rigorous semantic color codes, structured typographic weights, and Phosphor/Google Icons.

### Design Movement
The interface adheres to **Corporate / Modern Minimalism** with high-density data handling. It combines crisp 1px borders, subtle neutral surfaces (`#f9fafb`, `#f3f4f6`), and refined micro-interactions. Dynamic visual feedback is reserved exclusively for validation statuses, operational triage, and delivery confirmations.

## Colors

The palette balances institutional public health authority with critical operational signaling:

- **Primary (`#2563eb`) & Dark Variant (`#1d4ed8`):** Represents public trust, civic health management, and foundational actions (primary buttons, active tab indicators, selected states).
- **Validation / Sucesso (`#16a34a`):** Confirmed deliveries, prescription adherence, and verified oxygen cylinder stock. Paired with soft tint `#dcfce7` and dark ink `#166534` for accessible badges.
- **Alerta / Pendência (`#ca8a04`):** Pending route confirmations, nearing cylinder expiration, or awaiting medical sign-off. Paired with background `#fef9c3` and text `#854d0e`.
- **Divergência / Crítico (`#dc2626`):** Discrepancies in delivered volume, failed home visits, or emergency delivery alerts. Paired with background `#fee2e2` and text `#991b1b`.
- **Neutrals & Surfaces:** Pure white (`#ffffff`) for elevated modules, slate-light (`#f9fafb`) for page canvas, `#f3f4f6` for alternate rows and disabled fills, and deep slate (`#1f2937`) for crisp, legible body typography meeting WCAG AAA contrast standards.

## Typography

The typography system strictly uses **Poppins** for headings and key metrics, paired with **Open Sans** for functional readouts, forms, and data tables:

- **Headlines (Poppins):** Modern, geometric, and clear. Gives structure to the application top bars, modal titles, and KPI values (`metric-display`).
- **Body & Forms (Open Sans):** Unsurpassed legibility for extensive reading, patient clinical records, and prescription observations.
- **Condensed & Dense Variants:** For high-density screens (e.g., patient route tables, telemetry logs, cylinder lot trackers), use `table-cell-condensed` with reduced horizontal tracking (`letterSpacing: -0.01em`) and `Open Sans` 12px/13px medium variants to avoid horizontal scrolling while keeping numbers legible.
- **No Emojis Rule:** System interfaces must not render emojis. Replace all communicative cues with standardized monochrome or semantic Phosphor/Google Material symbols.

## Layout & Spacing

The layout philosophy is based on a **12-column fluid grid system** contained within a maximum width of `1440px`, suited for municipal desktop workstations while remaining completely responsive for field inspectors using mobile tablets or phones:

- **Desktop (1024px+):** Fixed 260px collapsable navigation sidebar, fluid workspace with `gutter-desktop` (24px) gutters, and 12-column dynamic partitioning. KPI metric ribbons span 3 or 4 columns per card.
- **Tablet (768px - 1023px):** 8-column layout, compact sidebar collapsed to icons only, with 16px lateral padding. KPI cards reflow to a 2x2 grid.
- **Mobile (< 768px):** 4-column single-stack layout, full-width cards, edge margins of `0.75rem` (12px), fixed sticky bottom action bars for field delivery actions.
- **Vertical Rhythm:** Rooted on a 4px/8px incremental rhythm (`space-xs` = 4px, `space-sm` = 8px, `space-base` = 16px). Table cells adhere strictly to a compact height of 40px to maximize visible rows per viewport.

## Elevation & Depth

This system avoids heavy, artificial dropshadows in favor of a **crisp, low-contrast structural outline architecture** suited for municipal administrative dashboards:

- **Layer 0 (Canvas):** `#f9fafb` page surface.
- **Layer 1 (Card & Module Surfaces):** Solid `#ffffff` backed by a 1px border (`#e5e7eb`) and an ultra-subtle diffuse ambient shadow: `0 1px 2px 0 rgba(0, 0, 0, 0.04)`.
- **Layer 2 (Dropdowns, Popovers & Context Menus):** `#ffffff` with a defined border (`#d1d5db`) and a focused shadow: `0 4px 6px -1px rgba(0, 0, 0, 0.08), 0 2px 4px -2px rgba(0, 0, 0, 0.04)`.
- **Layer 3 (Modals & Critical Dialogs):** Solid background with backdrop blur overlay (`rgba(15, 23, 42, 0.45)` with `backdrop-filter: blur(2px)`), casting `0 20px 25px -5px rgba(0, 0, 0, 0.1)`.

Depth is established by physical layering and crisp dividers rather than high-contrast shadows.

## Shapes

The design system adopts a **Balanced Roundedness (Level 2)** geometry:
- **Interactive Controls (Buttons, Inputs, Selects):** `rounded-lg` (8px / `0.5rem`), matching the structural aesthetic of modern productivity software.
- **Containers & KPI Cards:** `rounded-xl` (12px / `0.75rem`) to frame operational metrics and data tables smoothly without looking bubbly.
- **Badges & Pills:** `rounded-full` (9999px) for status indicators, highlighting delivery validations, alerts, and vehicle statuses.
- **Dividers & Borders:** Strictly solid 1px geometric borders (`#e5e7eb`), ensuring maximum data density with zero visual bleed.

## Components

### 1. Buttons
- **Primary:** Background `#2563eb`, text `#ffffff`, height 40px, padding horizontal 16px, font Open Sans 14px Semibold. Micro-interaction: hover to `#1d4ed8` with `transition: background-color 150ms ease-in-out`.
- **Secondary / Outline:** Background `#ffffff`, border 1px solid `#d1d5db`, text `#1f2937`. Hover: background `#f3f4f6`.
- **Danger:** Background `#dc2626`, hover `#b91c1c`, text `#ffffff`. Used for delivery cancellation or flagging discrepancies.
- **Icon Placement:** Phosphor/Google Icons placed with `0.5rem` (8px) gap. Never use emoji symbols inside buttons.

### 2. Status Badges & Chips
- **Conferência Validada:** Background `#dcfce7`, text `#166534`, border 1px solid `#bbf7d0`.
- **Pendente:** Background `#fef9c3`, text `#854d0e`, border 1px solid `#fef08a`.
- **Divergente:** Background `#fee2e2`, text `#991b1b`, border 1px solid `#fecaca`.
- **Structure:** `rounded-full`, padding `0.125rem 0.625rem`, typography `badge-status` (11px uppercase/semibold). Include a 6px solid dot or Phosphor indicator icon before the label.

### 3. KPI Metric Cards
- Surface `#ffffff`, border 1px solid `#e5e7eb`, border radius 12px, padding 20px.
- Left/top side: 40px icon container with `#eff6ff` fill and `#2563eb` icon glyph.
- Metrics figure: 30px Poppins Bold (`#111827`).
- Subtitle: 13px Open Sans (`#6b7280`).
- Micro-interaction: Subtle `translate-y-[-1px]` on hover with `transition: transform 150ms ease`.

### 4. Input Fields & Selects
- Height 40px, background `#ffffff`, border 1px solid `#d1d5db`, border radius 8px, font Open Sans 14px.
- Focus state: border color `#2563eb`, outline ring `2px solid rgba(37, 99, 235, 0.2)`.
- Integrated search inputs support immediate debouncing (`300ms`) with clear icon clearers.

### 5. High-Density Data Tables (Delivery & Patient Registry)
- Header row: background `#f9fafb`, border bottom 1px solid `#e5e7eb`, font 12px Open Sans Semibold, text uppercase `#4b5563`.
- Row height: strictly 44px for standard and 36px for dense mode. Alternate row hover: `#f8fafc`.
- Numeric columns (Cylinder Liters, Batch No., Delivery Time) use condensed tabular numbers.

### 6. Modal Dialogs & Feedback Banners
- Alerts contain direct action triggers, an icon badge in the respective status color, and dismissible buttons.
- Route transition loading states feature a crisp 32px spinner (`border-4 border-blue-600 border-t-transparent animate-spin`).