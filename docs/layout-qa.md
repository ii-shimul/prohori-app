# Phase 5 layout QA

- Primary text token: `#2C2E2F` (`AppPalette.ink`).
- Description token: `#687173` (`AppPalette.inkMuted`).
- Interactive controls use Material 3 buttons, fields, `NavigationBar`, `SegmentedButton`, or `ListTile`; theme minimum button height is 48dp.
- Status UI always combines text with color: chips state `GOOD`, `DEGRADED`, `CRITICAL`; alert cards include severity text.
- Bengali selector uses the native `SegmentedButton`; localized dynamic case text uses `Flexible` or `TextOverflow.ellipsis`.
- Long alert, note, inbox, and case text has explicit overflow limits or scroll containment.
