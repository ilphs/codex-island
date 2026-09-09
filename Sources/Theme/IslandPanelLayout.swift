import Foundation

enum IslandPanelLayout {
    static let horizontalInset: CGFloat = 24
    static let columnInset: CGFloat = 12
    static let tileHeight: CGFloat = 96
    static let footerHeight: CGFloat = 44

    /// Peek-state pill slot — one per side, outboard of each logo tab.
    /// Single source of truth: `IslandModel.pillSlotWidth` grows the
    /// silhouette by this much per side and `NotchPeekPill`'s overlay
    /// insets and width clamp read it back, so the pill can never spill
    /// past the slot into the logo (it used to, once the warning glyph
    /// appeared alongside a three-character countdown).
    ///
    /// Sized to the widest reachable content at `Typography.pillNumber`
    /// with 3pt item spacing — "⚠ 100% · 23h" measures 64.5pt — so every
    /// state renders at full size and the clamp stays a safety net.
    static let peekPillSlot: CGFloat = 76
    static let peekPillInset: CGFloat = 10
    static var peekPillContentWidth: CGFloat { peekPillSlot - peekPillInset }

    /// Line-box height of `Typography.pillNumber`, used to center the pill
    /// vertically in the silhouette. Tied to the type size — 10pt SF Mono
    /// lays out in a 13pt box (11pt was 14pt).
    static let peekPillHeight: CGFloat = 13

    static func headerHeight(notch: NotchInfo) -> CGFloat { max(32, notch.height) }
}
