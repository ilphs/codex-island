import SwiftUI

/// Glance-state usage stack that lives outboard of the provider logo while
/// the island is in `.peek`. No background of its own — text painted
/// directly on the dark silhouette, like the logo.
///
/// Two stacked window lines: the primary window the alert engine tracks
/// (Claude's 5h, Codex's peek window, a connected provider's first metric)
/// over the secondary one (weekly, or the second metric). The secondary is
/// dimmer so the line that alerts still reads first. Providers that report
/// only one window pass `secondary: nil` and render a single line.
///
/// Each line renders one of two states:
///   • value:    "32% · 2h" (active countdown) or "0% · 5h" (window-length
///               fallback at lower opacity when no active resetAt is known)
///   • errored:  "—%"       (no reading to show)
///
/// The cold-start spinner replaces the whole stack, not a single line.
///
/// Stateless — pure function of inputs. The parent owns visibility/animation.
struct NotchPeekPill: View {
    let primary: WindowUsage
    /// nil when the provider reports a single window — renders one line.
    let secondary: WindowUsage?
    let loading: Bool
    let tint: Color
    let alignment: HorizontalAlignment
    /// Provider-level severity, which the alert engine computes from the
    /// PRIMARY window only — so the warning glyph rides the primary line
    /// and the secondary never carries one.
    var severity: AlertEngine.Severity = .none
    /// Window-length glyphs shown when no active countdown is known — must
    /// match the window actually displayed on that line ("5h" / "7d").
    var primaryFallback: String = "5h"
    var secondaryFallback: String = "7d"
    @ObservedObject private var usageDisplay = UsageDisplayModeStore.shared

    var body: some View {
        Group {
            if showSpinner {
                LoadingDot()
            } else {
                VStack(alignment: alignment, spacing: 0) {
                    WindowLine(usage: primary, tint: effectiveTint, alignment: alignment,
                               severity: severity, fallback: primaryFallback,
                               mode: usageDisplay.mode)
                    if let secondary {
                        WindowLine(usage: secondary, tint: tint.opacity(0.62),
                                   alignment: alignment, severity: .none,
                                   fallback: secondaryFallback, mode: usageDisplay.mode)
                    }
                }
            }
        }
        .monospacedDigit()
        // Overflow guard. The slot is sized so every reachable line fits at
        // full size, but a `.fixedSize()` here used to let an unforeseen
        // combination (it was ⚠ + a three-character countdown + "100%")
        // silently spill outboard into the provider logo instead of being
        // reined in. Clamp to the slot and let type scale a few percent in
        // that corner case.
        .minimumScaleFactor(0.85)
        .frame(
            maxWidth: IslandPanelLayout.peekPillContentWidth,
            alignment: alignment == .leading ? .leading : .trailing
        )
    }

    /// Brand tint by default; alert color when above threshold so the
    /// percent + warning glyph share a consistent severity color.
    private var effectiveTint: Color {
        switch severity {
        case .none:     return tint
        case .warning:  return IslandColor.alertAmber
        case .critical: return IslandColor.alertRed
        }
    }

    /// Spinner only fires for the cold-start case (loading AND we have
    /// nothing to show on either line). If we have a prior value, keep
    /// showing it during refresh — same principle as UsageStore.isErrorOnly's
    /// "don't blank the panel" rule.
    private var showSpinner: Bool {
        guard loading, primary.usedPercent == 0, primary.error == nil else { return false }
        guard let secondary else { return true }
        return secondary.usedPercent == 0 && secondary.error == nil
    }
}

/// One window's "percent · countdown" row. Split out of `NotchPeekPill` so
/// the two stacked windows share one rendering rule rather than duplicating
/// the reading/fallback/error branches.
private struct WindowLine: View {
    let usage: WindowUsage
    let tint: Color
    let alignment: HorizontalAlignment
    let severity: AlertEngine.Severity
    let fallback: String
    let mode: UsageDisplayMode

    var body: some View {
        Group {
            if showDash {
                Text("—%")
                    .font(Typography.pillNumber)
                    .foregroundStyle(.white.opacity(0.40))
            } else {
                HStack(spacing: 2) {
                    if alignment == .leading {
                        // Left pill: percent on the outside (left), time
                        // remaining on the inside (toward the notch).
                        if severity != .none { warningGlyph }
                        percentLabel
                        separator
                        resetLabel
                    } else {
                        // Right pill: mirrored so percent stays on the
                        // outside (right) and time remaining stays inside.
                        resetLabel
                        separator
                        percentLabel
                        if severity != .none { warningGlyph }
                    }
                }
            }
        }
        .lineLimit(1)
    }

    private var warningGlyph: some View {
        Text("⚠")
            .font(Typography.pillNumber)
            .foregroundStyle(tint)
    }

    private var percentLabel: some View {
        Text("\(usage.displayedPercentInt(mode: mode))%")
            .font(Typography.pillNumber)
            .foregroundStyle(tint)
    }

    private var separator: some View {
        Text("·")
            .font(Typography.pillNumber)
            .foregroundStyle(.white.opacity(0.40))
    }

    /// Lower opacity on the fallback differentiates a passive "5-hour
    /// window" label from an active "5h until reset" countdown — same
    /// glyph shape, weaker visual presence.
    private var resetLabel: some View {
        Text(resetText ?? fallback)
            .font(Typography.pillNumber)
            .foregroundStyle(.white.opacity(resetText == nil ? 0.45 : 0.70))
    }

    private var showDash: Bool {
        // No measurement to show — a failed fetch, or a window the parsed
        // response doesn't report at all (permanent on single-window Codex
        // plans since mid-2026). The old "no data" carve-out rendered the
        // sentinel as a value, which fabricated a steady "0% · 5h" — a full
        // budget under the `remaining` toggle — for a window the plan
        // doesn't have.
        !usage.hasReading
    }

    /// Largest-unit countdown (`Nm` / `Nh` / `Nd`) — `Duration.coarse`,
    /// not `.compact`, so the pill slot doesn't have to be sized for the
    /// two-unit `10d 19h` form. Returns nil if there's no resetAt or the
    /// reset has already passed (happens transiently when a window rolls
    /// over before the next fetch lands).
    private var resetText: String? {
        guard let resetAt = usage.resetAt else { return nil }
        let remaining = resetAt.timeIntervalSinceNow
        guard remaining > 0 else { return nil }
        return Duration.coarse(remaining)
    }
}

private struct LoadingDot: View {
    @State private var pulsing = false

    var body: some View {
        Circle()
            .fill(.white.opacity(0.55))
            .frame(width: 6, height: 6)
            .opacity(pulsing ? 0.30 : 0.85)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}
