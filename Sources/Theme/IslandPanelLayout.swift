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
    /// Sized to the widest reachable line at `Typography.pillNumber` with
    /// 2pt item spacing — "⚠ 100% · 23h" measures 55.9pt — so every state
    /// renders at full size and the clamp stays a safety net.
    static let peekPillSlot: CGFloat = 68
    static let peekPillInset: CGFloat = 10
    static var peekPillContentWidth: CGFloat { peekPillSlot - peekPillInset }

    /// Height of the pill's two stacked window lines, used to center it
    /// vertically in the silhouette. Tied to the type size — 9pt SF Mono
    /// lays out in an 11pt box, so two lines are 22pt. That leaves 5pt above
    /// and below inside a 32pt menu bar, the shortest bar the app targets.
    static let peekPillHeight: CGFloat = 22

    static func headerHeight(notch: NotchInfo) -> CGFloat { max(32, notch.height) }
}
