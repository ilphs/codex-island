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
    /// 2pt item spacing — "100% 23h" measures 41.0pt — so every state
    /// renders at full size and the clamp stays a safety net. The warning
    /// glyph takes the countdown's place instead of adding to the line, so
    /// the alert state ("⚠ 100%", 29.7pt) is narrower, not wider.
    static let peekPillSlot: CGFloat = 49
    static let peekPillInset: CGFloat = 6
    static var peekPillContentWidth: CGFloat { peekPillSlot - peekPillInset }

    /// Logo geometry in the collapsed silhouette. 16pt is the macOS
    /// menu-bar icon size; the expanded panel and Settings keep the 20pt
    /// `ProviderMark` default, where width is not scarce. Every point here
    /// is a point of visible silhouette — the part over the physical notch
    /// is a display cutout with no pixels, so the extension left of it is
    /// the whole visible width.
    static let peekLogoSize: CGFloat = 16
    static let peekLogoInset: CGFloat = 6
    /// Gap kept between the logo's trailing edge and the notch's leading
    /// edge, so the mark never touches the cutout.
    static let peekLogoClearance: CGFloat = 3
    static var logoTabWidth: CGFloat { peekLogoSize + peekLogoInset + peekLogoClearance }

    /// Height of the pill's two stacked window lines, used to center it
    /// vertically in the silhouette. Tied to the type size — 9pt SF Mono
    /// lays out in an 11pt box, so two lines are 22pt. That leaves 5pt above
    /// and below inside a 32pt menu bar, the shortest bar the app targets.
    static let peekPillHeight: CGFloat = 22

    static func headerHeight(notch: NotchInfo) -> CGFloat { max(32, notch.height) }
}
