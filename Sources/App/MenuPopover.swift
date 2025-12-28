import Gtk
import Domain
import Foundation

/// Main popup menu - replicates MenuContentView from SwiftUI
final class MenuPopover {
    private let appState: AppState
    private var window: Window!
    private var selectedProviderId: String = "claude"
    private var settingsDialog: SettingsDialog?

    // UI Elements
    private var providerPillBox: Box!
    private var contentBox: Box!
    private var statusLabel: Label!

    init(appState: AppState) {
        self.appState = appState
        setupWindow()
    }

    private func setupWindow() {
        // Create window
        window = Window(type: .toplevel)
        window.setTitle("ClaudeBar")
        window.setDefaultSize(width: 380, height: 500)
        window.setResizable(false)

        // Add window style class
        window.styleContext.addClass(className: "menu-window")

        // Main container
        let mainBox = Box(orientation: .vertical, spacing: 0)
        window.add(mainBox)

        // Header
        let header = createHeader()
        mainBox.packStart(child: header, expand: false, fill: true, padding: 16)

        // Provider pills
        providerPillBox = createProviderPills()
        mainBox.packStart(child: providerPillBox, expand: false, fill: true, padding: 0)

        // Scrollable content area
        let scrolled = ScrolledWindow()
        scrolled.setPolicy(hscrollbarPolicy: .never, vscrollbarPolicy: .automatic)
        scrolled.setSizeRequest(width: -1, height: 380)

        contentBox = Box(orientation: .vertical, spacing: 12)
        contentBox.setMarginStart(margin: 16)
        contentBox.setMarginEnd(margin: 16)
        contentBox.setMarginBottom(margin: 16)
        scrolled.add(contentBox)

        mainBox.packStart(child: scrolled, expand: true, fill: true, padding: 0)

        // Action bar
        let actionBar = createActionBar()
        mainBox.packStart(child: actionBar, expand: false, fill: true, padding: 16)

        // Load initial data
        Task {
            await refresh(providerId: selectedProviderId)
        }
    }

    private func createHeader() -> Box {
        let header = Box(orientation: .horizontal, spacing: 12)

        // Provider icon
        let icon = Image()
        icon.setFromIconName(iconName: providerIconName(selectedProviderId), size: 38)
        icon.styleContext.addClass(className: "provider-icon")
        header.packStart(child: icon, expand: false, fill: false, padding: 0)

        // Title and subtitle
        let titleBox = Box(orientation: .vertical, spacing: 2)

        let titleLabel = Label(str: "ClaudeBar")
        titleLabel.setHalign(align: .start)
        titleLabel.styleContext.addClass(className: "title-text")
        titleLabel.styleContext.addClass(className: "text-primary")
        titleBox.packStart(child: titleLabel, expand: false, fill: false, padding: 0)

        let subtitleLabel = Label(str: "AI Usage Monitor")
        subtitleLabel.setHalign(align: .start)
        subtitleLabel.styleContext.addClass(className: "caption-text")
        subtitleLabel.styleContext.addClass(className: "text-secondary")
        titleBox.packStart(child: subtitleLabel, expand: false, fill: false, padding: 0)

        header.packStart(child: titleBox, expand: false, fill: false, padding: 0)

        // Spacer
        let spacer = Box(orientation: .horizontal, spacing: 0)
        header.packStart(child: spacer, expand: true, fill: true, padding: 0)

        // Status badge
        statusLabel = Label(str: statusText)
        statusLabel.styleContext.addClass(className: "status-badge")
        statusLabel.styleContext.addClass(className: statusClass)
        header.packStart(child: statusLabel, expand: false, fill: false, padding: 0)

        return header
    }

    private func createProviderPills() -> Box {
        let box = Box(orientation: .horizontal, spacing: 6)
        box.setMarginStart(margin: 16)
        box.setMarginEnd(margin: 16)
        box.setMarginBottom(margin: 16)

        for provider in appState.providers {
            let pill = createProviderPill(provider: provider)
            box.packStart(child: pill, expand: false, fill: false, padding: 0)
        }

        return box
    }

    private func createProviderPill(provider: any AIProvider) -> Button {
        let button = Button(label: provider.name)
        button.styleContext.addClass(className: "provider-pill")

        if provider.id == selectedProviderId {
            button.styleContext.addClass(className: "selected")
        }

        button.clicked {
            [weak self] in
            self?.selectProvider(providerId: provider.id)
        }

        return button
    }

    private func createActionBar() -> Box {
        let box = Box(orientation: .horizontal, spacing: 10)

        // Dashboard button
        let dashboardBtn = Button(label: "Dashboard")
        dashboardBtn.styleContext.addClass(className: "action-button")
        dashboardBtn.clicked { [weak self] in
            self?.openDashboard()
        }
        box.packStart(child: dashboardBtn, expand: false, fill: false, padding: 0)

        // Refresh button
        let refreshBtn = Button(label: appState.isRefreshing ? "Syncing..." : "Refresh")
        refreshBtn.styleContext.addClass(className: "action-button")
        refreshBtn.clicked { [weak self] in
            Task { await self?.refresh() }
        }
        box.packStart(child: refreshBtn, expand: false, fill: false, padding: 0)

        // Spacer
        let spacer = Box(orientation: .horizontal, spacing: 0)
        box.packStart(child: spacer, expand: true, fill: true, padding: 0)

        // Settings button
        let settingsBtn = Button()
        let settingsIcon = Image()
        settingsIcon.setFromIconName(iconName: "emblem-system-symbolic", size: 16)
        settingsBtn.setImage(image: settingsIcon)
        settingsBtn.styleContext.addClass(className: "icon-button")
        settingsBtn.clicked { [weak self] in
            self?.showSettings()
        }
        box.packStart(child: settingsBtn, expand: false, fill: false, padding: 0)

        // Quit button
        let quitBtn = Button()
        let quitIcon = Image()
        quitIcon.setFromIconName(iconName: "window-close-symbolic", size: 16)
        quitBtn.setImage(image: quitIcon)
        quitBtn.styleContext.addClass(className: "icon-button")
        quitBtn.clicked {
            Application.getDefault()?.quit()
        }
        box.packStart(child: quitBtn, expand: false, fill: false, padding: 0)

        return box
    }

    private func selectProvider(providerId: String) {
        selectedProviderId = providerId

        // Update pills
        recreateProviderPills()

        // Refresh content
        Task {
            await refresh(providerId: providerId)
        }
    }

    private func recreateProviderPills() {
        // Remove old pills
        if let parent = providerPillBox.parent {
            parent.remove(providerPillBox)
        }

        // Create new pills
        let newPills = createProviderPills()
        if let parent = window.child as? Box {
            parent.packStart(child: newPills, expand: false, fill: true, padding: 0)
            parent.reorderChild(child: newPills, position: 1)
        }
        providerPillBox = newPills
    }

    private func updateContent(for provider: any AIProvider) {
        // Clear existing content
        contentBox.foreach { widget in
            contentBox.remove(widget)
        }

        guard let snapshot = provider.snapshot else {
            showEmptyState()
            return
        }

        // Account card
        if let displayName = snapshot.accountEmail ?? snapshot.accountOrganization {
            let accountCard = createAccountCard(displayName: displayName, snapshot: snapshot)
            contentBox.packStart(child: accountCard, expand: false, fill: true, padding: 0)
        }

        // Quota cards
        for quota in snapshot.quotas {
            let quotaCard = createQuotaCard(quota: quota)
            contentBox.packStart(child: quotaCard, expand: false, fill: true, padding: 0)
        }

        // Cost card if available
        if let costUsage = snapshot.costUsage {
            let settings = AppSettings.shared
            let budget = settings.claudeApiBudgetEnabled ? settings.claudeApiBudget : nil
            let costCard = createCostCard(costUsage: costUsage, budget: budget)
            contentBox.packStart(child: costCard, expand: false, fill: true, padding: 0)
        }

        contentBox.showAll()
    }

    private func createAccountCard(displayName: String, snapshot: UsageSnapshot) -> Box {
        let card = Box(orientation: .horizontal, spacing: 10)
        card.styleContext.addClass(className: "glass-card")
        card.setMarginTop(margin: 10)
        card.setMarginBottom(margin: 10)

        // Avatar
        let avatar = Label(str: String(displayName.prefix(1)).uppercased())
        avatar.styleContext.addClass(className: "avatar")
        card.packStart(child: avatar, expand: false, fill: false, padding: 0)

        // Name and update time
        let infoBox = Box(orientation: .vertical, spacing: 2)

        let nameLabel = Label(str: displayName)
        nameLabel.setHalign(align: .start)
        nameLabel.styleContext.addClass(className: "text-primary")
        infoBox.packStart(child: nameLabel, expand: false, fill: false, padding: 0)

        let updateLabel = Label(str: "Updated \(snapshot.ageDescription)")
        updateLabel.setHalign(align: .start)
        updateLabel.styleContext.addClass(className: "text-tertiary")
        infoBox.packStart(child: updateLabel, expand: false, fill: false, padding: 0)

        card.packStart(child: infoBox, expand: true, fill: true, padding: 0)

        return card
    }

    private func createQuotaCard(quota: UsageQuota) -> Box {
        let card = Box(orientation: .vertical, spacing: 6)
        card.styleContext.addClass(className: "glass-card")
        card.setMarginTop(margin: 6)
        card.setMarginBottom(margin: 6)

        // Header row
        let header = Box(orientation: .horizontal, spacing: 0)

        let typeLabel = Label(str: quota.quotaType.displayName.uppercased())
        typeLabel.setHalign(align: .start)
        typeLabel.styleContext.addClass(className: "caption-text")
        typeLabel.styleContext.addClass(className: "text-secondary")
        header.packStart(child: typeLabel, expand: true, fill: true, padding: 0)

        let statusBadge = Label(str: quota.status.badgeText)
        statusBadge.styleContext.addClass(className: "status-badge")
        statusBadge.styleContext.addClass(className: statusClassForQuota(quota.status))
        header.packStart(child: statusBadge, expand: false, fill: false, padding: 0)

        card.packStart(child: header, expand: false, fill: true, padding: 0)

        // Percentage
        let percentLabel = Label(str: "\(Int(quota.percentRemaining))%")
        percentLabel.setHalign(align: .start)
        percentLabel.styleContext.addClass(className: "stat-text")
        percentLabel.styleContext.addClass(className: "text-primary")
        card.packStart(child: percentLabel, expand: false, fill: false, padding: 0)

        // Progress bar
        let progress = ProgressBar()
        progress.setFraction(fraction: quota.percentRemaining / 100.0)
        progress.styleContext.addClass(className: "progress-bar")
        card.packStart(child: progress, expand: false, fill: true, padding: 0)

        // Reset info
        if let resetText = quota.resetText ?? quota.resetDescription {
            let resetLabel = Label(str: resetText)
            resetLabel.setHalign(align: .start)
            resetLabel.styleContext.addClass(className: "text-tertiary")
            card.packStart(child: resetLabel, expand: false, fill: false, padding: 0)
        }

        return card
    }

    private func createCostCard(costUsage: CostUsage, budget: Decimal?) -> Box {
        let card = Box(orientation: .vertical, spacing: 6)
        card.styleContext.addClass(className: "glass-card")
        card.setMarginTop(margin: 6)
        card.setMarginBottom(margin: 6)

        let title = Label(str: "EXTRA USAGE COST")
        title.setHalign(align: .start)
        title.styleContext.addClass(className: "caption-text")
        title.styleContext.addClass(className: "text-secondary")
        card.packStart(child: title, expand: false, fill: false, padding: 0)

        let costLabel = Label(str: "$\(costUsage.totalCost)")
        costLabel.setHalign(align: .start)
        costLabel.styleContext.addClass(className: "stat-text")
        costLabel.styleContext.addClass(className: "text-primary")
        card.packStart(child: costLabel, expand: false, fill: false, padding: 0)

        if let budget = budget {
            let budgetLabel = Label(str: "Budget: $\(budget)")
            budgetLabel.setHalign(align: .start)
            budgetLabel.styleContext.addClass(className: "text-tertiary")
            card.packStart(child: budgetLabel, expand: false, fill: false, padding: 0)
        }

        return card
    }

    private func showEmptyState() {
        let label = Label(str: "\(selectedProvider?.name ?? selectedProviderId) Unavailable")
        label.styleContext.addClass(className: "text-primary")
        contentBox.packStart(child: label, expand: true, fill: true, padding: 20)
        contentBox.showAll()
    }

    private func refresh() async {
        await refresh(providerId: selectedProviderId)
    }

    private func refresh(providerId: String) async {
        guard let provider = appState.providers.first(where: { $0.id == providerId }) else {
            return
        }

        guard !provider.isSyncing else { return }

        do {
            try await provider.refresh()
            appState.lastError = nil

            // Update UI on main thread
            await MainActor.run {
                updateContent(for: provider)
                updateStatusBadge()
            }
        } catch {
            appState.lastError = error.localizedDescription
        }
    }

    private func updateStatusBadge() {
        statusLabel.setText(str: statusText)
        statusLabel.styleContext.removeClass(className: "status-healthy")
        statusLabel.styleContext.removeClass(className: "status-warning")
        statusLabel.styleContext.removeClass(className: "status-critical")
        statusLabel.styleContext.addClass(className: statusClass)
    }

    private func openDashboard() {
        guard let provider = selectedProvider,
              let url = provider.dashboardURL else { return }

        // Open URL in default browser
        do {
            try AppInfo.launchDefaultForUri(uri: url.absoluteString, context: nil)
        } catch {
            print("Failed to open dashboard: \(error)")
        }
    }

    private func showSettings() {
        if settingsDialog == nil {
            settingsDialog = SettingsDialog(appState: appState, parentWindow: window)
        }
        settingsDialog?.show()
    }

    // MARK: - Helpers

    private var selectedProvider: (any AIProvider)? {
        appState.providers.first { $0.id == selectedProviderId }
    }

    private var selectedProviderStatus: QuotaStatus {
        selectedProvider?.snapshot?.overallStatus ?? .healthy
    }

    private var statusText: String {
        if selectedProvider?.isSyncing == true {
            return "Syncing..."
        }
        return selectedProviderStatus.badgeText
    }

    private var statusClass: String {
        switch selectedProviderStatus {
        case .healthy: return "status-healthy"
        case .warning: return "status-warning"
        case .critical: return "status-critical"
        case .depleted: return "status-critical"
        }
    }

    private func statusClassForQuota(_ status: QuotaStatus) -> String {
        switch status {
        case .healthy: return "status-healthy"
        case .warning: return "status-warning"
        case .critical: return "status-critical"
        case .depleted: return "status-critical"
        }
    }

    private func providerIconName(_ providerId: String) -> String {
        switch providerId {
        case "claude": return "face-smile-symbolic"
        case "codex": return "utilities-terminal-symbolic"
        case "gemini": return "emblem-default-symbolic"
        case "copilot": return "applications-development-symbolic"
        default: return "applications-other-symbolic"
        }
    }

    func popup() {
        window.present()
    }
}
