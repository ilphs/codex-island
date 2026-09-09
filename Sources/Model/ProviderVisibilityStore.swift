import Foundation

/// The island carries exactly one provider, in the left slot.
///
/// It used to carry two — one either side of the physical notch — so the
/// persisted value is still an array of raw values. An existing
/// two-provider preference therefore degrades to its LEFT entry on first
/// launch after upgrade (silent migration, no opt-in) rather than
/// resetting to the default, and `init` rewrites the key in the new
/// single-element shape.
@MainActor
final class ProviderVisibilityStore: ObservableObject {
    static let shared = ProviderVisibilityStore()
    static let selectionKey = "MacIsland.selectedProviders"

    @Published private(set) var provider: IslandProvider
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let saved = defaults.stringArray(forKey: Self.selectionKey) {
            self.provider = Self.normalized(saved.compactMap(IslandProvider.init(rawValue:)))
        } else {
            let legacy: [IslandProvider] = [.claude, .codex].filter {
                defaults.object(forKey: "MacIsland.\($0.rawValue)Visible") as? Bool ?? true
            }
            self.provider = Self.normalized(legacy)
        }
        persist()
    }

    /// One-element view of the selection. Kept because the aggregate call
    /// sites — usage fetch fan-out, alert inputs, footer sync state — are
    /// written as loops over the selection and read the same whether the
    /// island shows one provider or several.
    var selected: [IslandProvider] { [provider] }
    var left: IslandProvider { provider }
    var claudeVisible: Bool { provider == .claude }
    var codexVisible: Bool { provider == .codex }

    /// First recognized entry wins; an empty or fully unrecognized list
    /// falls back to Claude, so a corrupt preference still renders an
    /// island instead of nothing.
    static func normalized(_ providers: [IslandProvider]) -> IslandProvider {
        providers.first ?? .claude
    }

    func select(_ provider: IslandProvider) {
        guard provider != self.provider else { return }
        self.provider = provider
        persist()
    }

    private func persist() {
        defaults.set([provider.rawValue], forKey: Self.selectionKey)
    }
}
