import Gtk
import Domain
import Foundation

/// Controller for system tray status icon
final class StatusIconController {
    private let appState: AppState
    private var statusIcon: StatusIcon!
    private var menu: MenuPopover!

    init(appState: AppState) {
        self.appState = appState
    }

    func show() {
        // Create status icon for system tray
        statusIcon = StatusIcon()
        statusIcon.setFromIconName(iconName)
        statusIcon.setTooltipText("ClaudeBar - AI Usage Monitor")

        // Create popup menu
        menu = MenuPopover(appState: appState)

        // Connect activate signal to show menu
        statusIcon.onActivate { [weak self] _ in
            self?.showMenu()
        }

        // Start periodic status updates
        startStatusUpdates()
    }

    private func showMenu() {
        menu.popup()
    }

    private var iconName: String {
        let settings = AppSettings.shared
        let isChristmas = ThemeMode(rawValue: settings.themeMode) == .christmas

        if isChristmas {
            return "weather-snow-symbolic"
        }

        switch appState.overallStatus {
        case .healthy:
            return "emblem-default-symbolic"
        case .warning:
            return "dialog-warning-symbolic"
        case .critical:
            return "dialog-warning-symbolic"
        case .depleted:
            return "dialog-error-symbolic"
        }
    }

    private func startStatusUpdates() {
        // Update status icon every 5 seconds
        GLib.timeoutAdd(interval: 5000) { [weak self] in
            self?.updateStatusIcon()
            return true // Continue
        }
    }

    private func updateStatusIcon() {
        statusIcon.setFromIconName(iconName)
    }
}
