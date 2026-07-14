# UI Audit

Phase: Visual Verification and UI/UX Audit  
Date: 2026-07-14  
Evidence reviewed:

- `docs/screenshots/Screenshot 2026-07-14 120812.png` at 1272x832.
- `docs/screenshots/Screenshot 2026-07-14 120833.png` at 1275x832.
- `docs/screenshots/Screenshot 2026-07-14 121019.png` at 1571x968.
- `scripts/main.gd`
- `main.tscn`

## Summary

The current application is functionally usable and the wardrobe structure remains data-driven. The main UI problems are not gameplay failures; they are visual hierarchy, state clarity, and layout polish issues. The biggest confirmed layout defect was the root scene being shifted upward by negative offsets, which clipped the header and the `LOCAL ONLY` badge in every screenshot.

## Critical

### Header Is Clipped At The Top

- Type: layout bug.
- Description: The app root was shifted upward, causing the main title area to be hidden by the window title bar. The subtitle and `LOCAL ONLY` badge appeared at or beyond the top edge.
- Evidence: All screenshots show the top title text missing or clipped. Source confirmed `main.tscn` had `offset_top = -45.0` and matching negative offsets.
- User impact: Players may miss the product identity and privacy reassurance. The first viewport feels broken before interaction begins.
- Proposed handling: Remove the negative root offsets and reserve stable header height.
- Status: fixed.

## High

### Active Category State Is Too Subtle

- Type: usability issue.
- Description: Active category buttons used nearly the same gray treatment as inactive buttons.
- Evidence: In screenshots, `Áo` and `Đầm` tabs are only slightly darker than neighboring tabs.
- User impact: Players can lose track of the active wardrobe category, especially with many tabs.
- Proposed handling: Apply a distinct pressed style with accent fill and white text.
- Status: fixed.

### Selected Item State Is Too Subtle

- Type: usability issue.
- Description: Selected item buttons relied on a minor shade change.
- Evidence: `Sơ mi` and `Đầm sơ mi` are visible as selected only after careful comparison.
- User impact: Players may not know which item is currently worn.
- Proposed handling: Apply the same high-contrast pressed style to selected item buttons.
- Status: fixed.

### Disabled Button State Could Be Mistaken For Enabled

- Type: usability issue.
- Description: The disabled `Làm lại` button still appeared close to regular action buttons.
- Evidence: Screenshots show `Làm lại` as pale gray but without a clear disabled surface treatment.
- User impact: Players may click unavailable actions and feel the UI is unresponsive.
- Proposed handling: Add an explicit disabled style with muted readable text.
- Status: fixed.

## Medium

### Lock Control Has Low Contrast

- Type: usability issue.
- Description: The `Khóa` label and switch were visually faint compared with the category header.
- Evidence: Screenshots show `Khóa` near the right side of the header in very light gray.
- User impact: Random lock behavior is important, but the control is easy to overlook.
- Proposed handling: Increase label contrast, reserve a stable control width, and keep pressed color aligned with the accent.
- Status: fixed.

### Action Buttons Lack Visual Priority

- Type: usability issue.
- Description: All action buttons had similar gray weight, even though `Ngẫu nhiên`, `Lưu PNG`, and `Xóa dữ liệu lưu` have different importance and risk.
- Evidence: Action grid in all screenshots reads as one flat group.
- User impact: Primary actions are slower to find; destructive local-data clearing does not feel distinct.
- Proposed handling: Style `Ngẫu nhiên` as primary, `Lưu PNG` as strong, and `Xóa dữ liệu lưu` as a bordered caution action.
- Status: fixed.

### Status Text Is Too Small And Detached

- Type: usability issue.
- Description: Status feedback sits at the bottom of the app as small loose text.
- Evidence: Screenshots show `Áo: Sơ mi` and `Đầm: Đầm sơ mi` far below the action area and stage.
- User impact: Feedback can be missed after item selection, save, reset, undo, or random.
- Proposed handling: Put status text in a small feedback bar with stronger text contrast and wrapping.
- Status: fixed.

### Sparse Categories Leave A Large Empty Item Area

- Type: layout/usability issue.
- Description: Categories with few items leave a large blank block between items and actions.
- Evidence: `Đầm` has five options and then a very large empty space before action buttons in all relevant screenshots.
- User impact: The blank area can make the wardrobe feel unfinished, though it does not block interaction.
- Proposed handling: Keep actions anchored at the bottom for now; later consider thumbnails, item descriptions, or a compact empty-state area when real art is available.
- Status: deferred.

## Low

### Placeholder Character Limits Visual Polish Judgement

- Type: aesthetic limitation.
- Description: The procedural placeholder is intentionally simple and cannot prove final art quality, layer aesthetics, or garment fit.
- Evidence: Screenshots use code-drawn body, clothing, hair, and accessories.
- User impact: Some visual roughness is expected and should not be confused with final asset quality.
- Proposed handling: Defer character art judgement until Phase 2 character anchor and proof pack.
- Status: deferred.

### Hover And Pressed States Need Manual Visual Verification

- Type: verification gap.
- Description: Static screenshots cannot show hover transitions or press feedback.
- Evidence: Screenshots only capture resting state.
- User impact: Hover and pressed states may still need tuning after hands-on testing.
- Proposed handling: Manually test mouse hover, click-down, selected, disabled, and locked states in Godot/browser.
- Status: deferred.

### Small Viewport Risk Still Needs Fresh Screenshots

- Type: verification gap.
- Description: Existing screenshots cover 1272x832, 1275x832, and 1571x968, but do not prove 1024x768 or browser chrome variations.
- Evidence: `docs/TEST_PLAN.md` lists 1280x720 and 1024x768 checks as targets.
- User impact: Text or action buttons may still feel crowded at smaller windows.
- Proposed handling: Re-capture screenshots after these fixes at 1440x900, 1280x720, and 1024x768.
- Status: deferred.
