import Gtk
import Domain
import Infrastructure
import Foundation

/// GTK4 Application for ClaudeBar
/// Linux port with identical functionality to macOS version
@main
struct ClaudeBarApp {
    static func main() {
        // Initialize GTK
        let app = Application(applicationId: "com.claudebar.linux")

        // Create app state
        let appState = AppState()

        // Handle activation
        app.onActivate { _ in
            // Load CSS theme
            ThemeManager.shared.loadTheme()

            // Create and show status icon
            let statusIcon = StatusIconController(appState: appState)
            statusIcon.show()
        }

        // Run the application
        let status = app.run(CommandLine.argc, CommandLine.unsafeArgv)
        exit(Int32(status))
    }
}

/// Shared app state - observable by all views
final class AppState {
    /// The registered providers (rich domain models)
    var providers: [any AIProvider] = []

    /// The monitor service
    var monitor: QuotaMonitor!

    /// Notification observer
    private let notificationObserver: StatusChangeObserver

    /// The overall status across all providers
    var overallStatus: QuotaStatus {
        providers
            .compactMap(\.snapshot?.overallStatus)
            .max() ?? .healthy
    }

    /// Whether any provider is currently refreshing
    var isRefreshing: Bool {
        providers.contains { $0.isSyncing }
    }

    /// Last error message, if any
    var lastError: String?

    init() {
        // Create notification observer
        self.notificationObserver = LinuxNotificationObserver()

        // Create providers with their probes
        var providers: [any AIProvider] = [
            ClaudeProvider(probe: ClaudeUsageProbe()),
            CodexProvider(probe: CodexUsageProbe()),
            GeminiProvider(probe: GeminiUsageProbe()),
        ]

        // Add Copilot provider if configured
        if AppSettings.shared.copilotEnabled && AppSettings.shared.hasCopilotToken {
            providers.append(CopilotProvider(probe: CopilotUsageProbe()))
        }

        // Register providers for global access
        AIProviderRegistry.shared.register(providers)

        // Store providers in app state
        self.providers = providers

        // Initialize the domain service with notification observer
        self.monitor = QuotaMonitor(
            providers: providers,
            statusObserver: notificationObserver
        )

        // Request notification permission
        Task {
            await (notificationObserver as? LinuxNotificationObserver)?.requestPermission()
        }
    }

    /// Adds a provider if not already present
    func addProvider(_ provider: any AIProvider) {
        guard !providers.contains(where: { $0.id == provider.id }) else { return }
        providers.append(provider)
        AIProviderRegistry.shared.register([provider])
    }

    /// Removes a provider by ID
    func removeProvider(id: String) {
        providers.removeAll { $0.id == id }
    }
}
