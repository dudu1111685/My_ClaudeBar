import Domain
import Gtk
import Foundation

/// Linux notification observer using GNotification
final class LinuxNotificationObserver: StatusChangeObserver {
    private var lastNotifiedStatus: [String: QuotaStatus] = [:]
    private var permissionGranted = false

    /// Request notification permission (always granted on Linux)
    func requestPermission() async -> Bool {
        permissionGranted = true
        return true
    }

    /// Called when quota status changes
    func quotaStatusChanged(provider: any AIProvider, from oldStatus: QuotaStatus, to newStatus: QuotaStatus) {
        // Only notify if status degraded
        guard newStatus > oldStatus else { return }

        // Check if we've already notified for this provider at this status
        if let lastStatus = lastNotifiedStatus[provider.id], lastStatus == newStatus {
            return
        }

        // Send notification
        sendNotification(for: provider, status: newStatus)

        // Remember we notified
        lastNotifiedStatus[provider.id] = newStatus
    }

    private func sendNotification(for provider: any AIProvider, status: QuotaStatus) {
        let title = "\(provider.name) Quota Alert"
        let body = notificationBody(for: status, provider: provider)

        // Create GNotification
        let notification = Notification(title: title)
        notification.setBody(body)
        notification.setPriority(priority: notificationPriority(for: status))

        // Set icon based on status
        let iconName = notificationIcon(for: status)
        let icon = ThemedIcon(name: iconName, useDefaultFallbacks: true)
        notification.setIcon(icon: icon)

        // Send notification
        let app = Application.getDefault()
        app?.sendNotification(id: "quota-\(provider.id)", notification: notification)
    }

    private func notificationBody(for status: QuotaStatus, provider: any AIProvider) -> String {
        switch status {
        case .depleted:
            return "\(provider.name) quota is completely depleted!"
        case .critical:
            return "\(provider.name) quota is critically low!"
        case .warning:
            return "\(provider.name) quota is running low."
        case .healthy:
            return "\(provider.name) quota is healthy."
        }
    }

    private func notificationPriority(for status: QuotaStatus) -> GLib.NotificationPriority {
        switch status {
        case .depleted:
            return .urgent
        case .critical:
            return .high
        case .warning:
            return .normal
        case .healthy:
            return .low
        }
    }

    private func notificationIcon(for status: QuotaStatus) -> String {
        switch status {
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
}
