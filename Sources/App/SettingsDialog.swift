import Gtk
import Domain
import Foundation

/// Settings dialog - replicates SettingsView from SwiftUI
final class SettingsDialog {
    private let appState: AppState
    private weak var parentWindow: Window?
    private var dialog: Dialog!

    // UI Elements
    private var copilotTokenEntry: Entry!
    private var githubUsernameEntry: Entry!
    private var budgetEntry: Entry!
    private var copilotSwitch: Switch!
    private var budgetSwitch: Switch!

    init(appState: AppState, parentWindow: Window?) {
        self.appState = appState
        self.parentWindow = parentWindow
        setupDialog()
    }

    private func setupDialog() {
        dialog = Dialog()
        dialog.setTitle("Settings")
        dialog.setTransientFor(parent: parentWindow)
        dialog.setModal(modal: true)
        dialog.setDefaultSize(width: 400, height: 600)

        // Content area
        let contentArea = dialog.getContentArea()
        let scrolled = ScrolledWindow()
        scrolled.setPolicy(hscrollbarPolicy: .never, vscrollbarPolicy: .automatic)

        let mainBox = Box(orientation: .vertical, spacing: 12)
        mainBox.setMarginStart(margin: 16)
        mainBox.setMarginEnd(margin: 16)
        mainBox.setMarginTop(margin: 16)
        mainBox.setMarginBottom(margin: 16)

        // Theme settings
        let themeCard = createThemeCard()
        mainBox.packStart(child: themeCard, expand: false, fill: true, padding: 0)

        // Claude API Budget
        let budgetCard = createBudgetCard()
        mainBox.packStart(child: budgetCard, expand: false, fill: true, padding: 0)

        // GitHub Copilot
        let copilotCard = createCopilotCard()
        mainBox.packStart(child: copilotCard, expand: false, fill: true, padding: 0)

        scrolled.add(mainBox)
        contentArea.add(scrolled)

        // Buttons
        dialog.addButton(buttonText: "Close", responseId: ResponseType.close.rawValue)

        dialog.response { [weak self] _, response in
            if response == ResponseType.close.rawValue {
                self?.dialog.hide()
            }
        }

        dialog.showAll()
    }

    private func createThemeCard() -> Box {
        let card = Box(orientation: .vertical, spacing: 12)
        card.styleContext.addClass(className: "glass-card")

        // Header
        let header = Label(str: "Appearance")
        header.setHalign(align: .start)
        header.styleContext.addClass(className: "title-text")
        header.styleContext.addClass(className: "text-primary")
        card.packStart(child: header, expand: false, fill: false, padding: 0)

        let subtitle = Label(str: "Choose your theme")
        subtitle.setHalign(align: .start)
        subtitle.styleContext.addClass(className: "caption-text")
        subtitle.styleContext.addClass(className: "text-tertiary")
        card.packStart(child: subtitle, expand: false, fill: false, padding: 0)

        // Theme buttons
        let themesBox = Box(orientation: .vertical, spacing: 6)

        let settings = AppSettings.shared
        let currentMode = ThemeMode(rawValue: settings.themeMode) ?? .system

        for mode in ThemeMode.allCases {
            let button = createThemeButton(mode: mode, isSelected: currentMode == mode)
            themesBox.packStart(child: button, expand: false, fill: true, padding: 0)
        }

        card.packStart(child: themesBox, expand: false, fill: true, padding: 0)

        return card
    }

    private func createThemeButton(mode: ThemeMode, isSelected: Bool) -> Button {
        let button = Button(label: mode.displayName)

        if isSelected {
            button.styleContext.addClass(className: "selected")
        }

        button.clicked { [weak self] in
            self?.selectTheme(mode: mode)
        }

        return button
    }

    private func createBudgetCard() -> Box {
        let card = Box(orientation: .vertical, spacing: 12)
        card.styleContext.addClass(className: "glass-card")

        // Header row
        let header = Box(orientation: .horizontal, spacing: 10)

        let titleBox = Box(orientation: .vertical, spacing: 2)
        let title = Label(str: "Claude API Budget")
        title.setHalign(align: .start)
        title.styleContext.addClass(className: "title-text")
        title.styleContext.addClass(className: "text-primary")
        titleBox.packStart(child: title, expand: false, fill: false, padding: 0)

        let subtitle = Label(str: "Cost threshold warnings")
        subtitle.setHalign(align: .start)
        subtitle.styleContext.addClass(className: "caption-text")
        subtitle.styleContext.addClass(className: "text-tertiary")
        titleBox.packStart(child: subtitle, expand: false, fill: false, padding: 0)

        header.packStart(child: titleBox, expand: true, fill: true, padding: 0)

        // Toggle switch
        budgetSwitch = Switch()
        let settings = AppSettings.shared
        budgetSwitch.setActive(isActive: settings.claudeApiBudgetEnabled)
        budgetSwitch.stateSet { [weak self] _, state in
            self?.toggleBudget(enabled: state)
            return false
        }
        header.packStart(child: budgetSwitch, expand: false, fill: false, padding: 0)

        card.packStart(child: header, expand: false, fill: true, padding: 0)

        // Budget input (only if enabled)
        if settings.claudeApiBudgetEnabled {
            let inputBox = Box(orientation: .vertical, spacing: 6)

            let inputLabel = Label(str: "MONTHLY BUDGET (USD)")
            inputLabel.setHalign(align: .start)
            inputLabel.styleContext.addClass(className: "caption-text")
            inputLabel.styleContext.addClass(className: "text-secondary")
            inputBox.packStart(child: inputLabel, expand: false, fill: false, padding: 0)

            budgetEntry = Entry()
            budgetEntry.setPlaceholderText(text: "10.00")
            budgetEntry.setText(text: String(describing: settings.claudeApiBudget))
            budgetEntry.changed { [weak self] entry in
                if let text = entry.getText(), let value = Decimal(string: String(text)) {
                    AppSettings.shared.claudeApiBudget = value
                }
            }
            inputBox.packStart(child: budgetEntry, expand: false, fill: true, padding: 0)

            card.packStart(child: inputBox, expand: false, fill: true, padding: 0)
        }

        return card
    }

    private func createCopilotCard() -> Box {
        let card = Box(orientation: .vertical, spacing: 12)
        card.styleContext.addClass(className: "glass-card")

        // Header row
        let header = Box(orientation: .horizontal, spacing: 10)

        let titleBox = Box(orientation: .vertical, spacing: 2)
        let title = Label(str: "GitHub Copilot")
        title.setHalign(align: .start)
        title.styleContext.addClass(className: "title-text")
        title.styleContext.addClass(className: "text-primary")
        titleBox.packStart(child: title, expand: false, fill: false, padding: 0)

        let subtitle = Label(str: "Premium usage tracking")
        subtitle.setHalign(align: .start)
        subtitle.styleContext.addClass(className: "caption-text")
        subtitle.styleContext.addClass(className: "text-tertiary")
        titleBox.packStart(child: subtitle, expand: false, fill: false, padding: 0)

        header.packStart(child: titleBox, expand: true, fill: true, padding: 0)

        // Toggle switch
        copilotSwitch = Switch()
        let settings = AppSettings.shared
        copilotSwitch.setActive(isActive: settings.copilotEnabled)
        copilotSwitch.stateSet { [weak self] _, state in
            self?.toggleCopilot(enabled: state)
            return false
        }
        header.packStart(child: copilotSwitch, expand: false, fill: false, padding: 0)

        card.packStart(child: header, expand: false, fill: true, padding: 0)

        // Copilot config (only if enabled)
        if settings.copilotEnabled {
            let configBox = Box(orientation: .vertical, spacing: 12)

            // Username
            let usernameBox = Box(orientation: .vertical, spacing: 6)
            let usernameLabel = Label(str: "GITHUB USERNAME")
            usernameLabel.setHalign(align: .start)
            usernameLabel.styleContext.addClass(className: "caption-text")
            usernameLabel.styleContext.addClass(className: "text-secondary")
            usernameBox.packStart(child: usernameLabel, expand: false, fill: false, padding: 0)

            githubUsernameEntry = Entry()
            githubUsernameEntry.setPlaceholderText(text: "username")
            githubUsernameEntry.setText(text: settings.githubUsername)
            githubUsernameEntry.changed { entry in
                if let text = entry.getText() {
                    AppSettings.shared.githubUsername = String(text)
                }
            }
            usernameBox.packStart(child: githubUsernameEntry, expand: false, fill: true, padding: 0)
            configBox.packStart(child: usernameBox, expand: false, fill: true, padding: 0)

            // Token
            let tokenBox = Box(orientation: .vertical, spacing: 6)
            let tokenLabel = Label(str: "PERSONAL ACCESS TOKEN")
            tokenLabel.setHalign(align: .start)
            tokenLabel.styleContext.addClass(className: "caption-text")
            tokenLabel.styleContext.addClass(className: "text-secondary")
            tokenBox.packStart(child: tokenLabel, expand: false, fill: false, padding: 0)

            let tokenInputBox = Box(orientation: .horizontal, spacing: 6)
            copilotTokenEntry = Entry()
            copilotTokenEntry.setPlaceholderText(text: "ghp_xxxx...")
            copilotTokenEntry.setVisibility(visible: false) // Password field
            tokenInputBox.packStart(child: copilotTokenEntry, expand: true, fill: true, padding: 0)

            let saveBtn = Button(label: "Save")
            saveBtn.styleContext.addClass(className: "action-button")
            saveBtn.clicked { [weak self] in
                self?.saveCopilotToken()
            }
            tokenInputBox.packStart(child: saveBtn, expand: false, fill: false, padding: 0)

            tokenBox.packStart(child: tokenInputBox, expand: false, fill: true, padding: 0)

            // Help text
            let helpLabel = Label(str: "Create a fine-grained PAT with 'Plan: read' permission")
            helpLabel.setHalign(align: .start)
            helpLabel.styleContext.addClass(className: "caption-text")
            helpLabel.styleContext.addClass(className: "text-tertiary")
            tokenBox.packStart(child: helpLabel, expand: false, fill: false, padding: 0)

            configBox.packStart(child: tokenBox, expand: false, fill: true, padding: 0)

            card.packStart(child: configBox, expand: false, fill: true, padding: 0)
        }

        return card
    }

    private func selectTheme(mode: ThemeMode) {
        AppSettings.shared.themeMode = mode.rawValue
        ThemeManager.shared.loadTheme()

        // Recreate dialog to apply new theme
        dialog.destroy()
        setupDialog()
    }

    private func toggleBudget(enabled: Bool) {
        AppSettings.shared.claudeApiBudgetEnabled = enabled

        // Recreate card
        dialog.destroy()
        setupDialog()
    }

    private func toggleCopilot(enabled: Bool) {
        AppSettings.shared.copilotEnabled = enabled

        if enabled {
            let copilotProvider = CopilotProvider(probe: CopilotUsageProbe())
            appState.addProvider(copilotProvider)

            Task {
                try? await copilotProvider.refresh()
            }
        } else {
            appState.removeProvider(id: "copilot")
        }

        // Recreate card
        dialog.destroy()
        setupDialog()
    }

    private func saveCopilotToken() {
        guard let token = copilotTokenEntry.getText(), !String(token).isEmpty else {
            return
        }

        AppSettings.shared.saveCopilotToken(String(token))
        copilotTokenEntry.setText(text: "")

        // Show success message
        let messageDialog = MessageDialog(
            parent: dialog,
            flags: .modal,
            type: .info,
            buttons: .ok,
            messageFormat: "Token saved successfully!"
        )
        messageDialog.run()
        messageDialog.destroy()
    }

    func show() {
        dialog.present()
    }
}
