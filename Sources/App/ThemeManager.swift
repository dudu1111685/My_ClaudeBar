import Gtk
import Foundation

/// Theme modes for ClaudeBar
enum ThemeMode: String, CaseIterable {
    case light
    case dark
    case system

    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }

    var iconName: String {
        switch self {
        case .light: return "weather-clear-symbolic"
        case .dark: return "weather-clear-night-symbolic"
        case .system: return "emblem-system-symbolic"
        }
    }
}

/// Manages CSS themes for the GTK application
final class ThemeManager {
    static let shared = ThemeManager()

    private var cssProvider: CssProvider!

    private init() {
        cssProvider = CssProvider()
    }

    /// Load and apply the CSS theme
    func loadTheme() {
        let settings = AppSettings.shared
        let themeMode = ThemeMode(rawValue: settings.themeMode) ?? .system

        // Generate CSS based on theme
        let css = generateCSS(for: themeMode)

        // Load CSS
        cssProvider.loadFromData(data: css)

        // Apply to default screen
        if let display = Display.getDefault(), let screen = display.getDefaultScreen() {
            StyleContext.addProviderForScreen(
                screen: screen,
                provider: cssProvider,
                priority: UInt32(STYLE_PROVIDER_PRIORITY_APPLICATION)
            )
        }
    }

    private func generateCSS(for theme: ThemeMode) -> String {
        theme == .dark ? darkCSS : lightCSS
    }

    // MARK: - CSS Themes

    private var lightCSS: String {
        """
        /* ClaudeBar Light Theme */

        window {
            background: linear-gradient(135deg,
                rgb(250, 245, 255),
                rgb(242, 235, 250),
                rgb(250, 240, 247));
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid rgba(158, 107, 235, 0.18);
            border-radius: 14px;
            box-shadow: 0 4px 8px rgba(97, 56, 184, 0.12);
        }

        .provider-pill {
            background: rgba(255, 255, 255, 0.85);
            border: 1px solid rgba(158, 107, 235, 0.2);
            border-radius: 20px;
            padding: 6px 10px;
        }

        .provider-pill:hover {
            background: rgba(255, 255, 255, 0.95);
        }

        .provider-pill.selected {
            background: linear-gradient(135deg,
                rgb(158, 107, 235),
                rgb(217, 112, 184));
            border: 1px solid rgba(255, 255, 255, 0.5);
            color: white;
        }

        .text-primary {
            color: rgb(31, 20, 56);
        }

        .text-secondary {
            color: rgba(89, 71, 115, 0.85);
        }

        .text-tertiary {
            color: rgba(115, 97, 140, 0.7);
        }

        .status-healthy {
            color: rgb(38, 184, 133);
        }

        .status-warning {
            color: rgb(224, 148, 46);
        }

        .status-critical {
            color: rgb(224, 71, 97);
        }

        .progress-bar {
            background: rgba(97, 56, 184, 0.1);
            border-radius: 3px;
        }

        .progress-bar-fill {
            border-radius: 3px;
        }
        """
    }

    private var darkCSS: String {
        """
        /* ClaudeBar Dark Theme */

        window {
            background: linear-gradient(135deg,
                rgb(97, 56, 184),
                rgb(140, 82, 217),
                rgba(217, 89, 166, 0.8));
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.18);
            border: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 14px;
        }

        .provider-pill {
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 20px;
            padding: 6px 10px;
        }

        .provider-pill:hover {
            background: rgba(255, 255, 255, 0.18);
        }

        .provider-pill.selected {
            background: linear-gradient(135deg,
                rgb(158, 107, 235),
                rgb(217, 112, 184));
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: white;
        }

        .text-primary {
            color: white;
        }

        .text-secondary {
            color: rgba(255, 255, 255, 0.7);
        }

        .text-tertiary {
            color: rgba(255, 255, 255, 0.5);
        }

        .status-healthy {
            color: rgb(89, 235, 174);
        }

        .status-warning {
            color: rgb(250, 184, 89);
        }

        .status-critical {
            color: rgb(250, 107, 133);
        }

        .progress-bar {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 3px;
        }

        .progress-bar-fill {
            border-radius: 3px;
        }
        """
    }
}
}
