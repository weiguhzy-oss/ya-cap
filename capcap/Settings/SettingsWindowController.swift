import AppKit

private final class SettingsWindow: NSWindow {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let commandModifiers: NSEvent.ModifierFlags = [.command, .shift, .option, .control]
        let modifiers = event.modifierFlags.intersection(commandModifiers)
        if modifiers == .command,
           event.charactersIgnoringModifiers?.lowercased() == "w" {
            performClose(nil)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    var onMenuBarToggle: ((Bool) -> Void)?

    private var settingsView: SettingsView!

    private init() {
        let window = SettingsWindow(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = L10n.settingsTitle
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.appearance = NSAppearance(named: .darkAqua)
        window.backgroundColor = NSColor(calibratedRed: 0.09, green: 0.12, blue: 0.16, alpha: 1.0)
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .normal

        super.init(window: window)

        NotificationCenter.default.addObserver(forName: .languageDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.window?.title = L10n.settingsTitle
        }

        settingsView = SettingsView(frame: NSRect(x: 0, y: 0, width: 760, height: 560))
        settingsView.onMenuBarToggle = { [weak self] visible in
            self?.onMenuBarToggle?(visible)
        }
        window.contentView = settingsView
        window.initialFirstResponder = settingsView
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showAsSettings(focusingPermissions: Bool? = nil) {
        let shouldFocusPermissions = focusingPermissions ?? !AppPermissions.allRequiredGranted
        if shouldFocusPermissions {
            settingsView.showPermissionsTab()
        }
        // Settings is the one window that behaves like a regular app window, so
        // give the app a Dock icon while it is open. The policy switch must
        // happen before activation, otherwise the window opens behind whatever
        // app was frontmost.
        NSApp.setActivationPolicy(.regular)
        resetInitialFocus()
        showWindow(nil)
        resetInitialFocus()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func resetInitialFocus() {
        window?.initialFirstResponder = settingsView
        window?.makeFirstResponder(settingsView)
    }

    private func resizeWindow(height: CGFloat) {
        guard let window = window else { return }
        var frame = window.frame
        let delta = height - frame.size.height
        frame.size.height = height
        frame.origin.y -= delta
        window.setFrame(frame, display: true, animate: false)
    }
}

extension SettingsWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        settingsView.cancelToolbarShortcutRecording()
        settingsView.cancelShortcutRecording()
        settingsView.cancelClipboardShortcutRecording()
        settingsView.cancelFileSaveShortcutRecording()
        settingsView.closePermissionFlowPanel()

        // Drop back to the menu-bar-only policy so the Dock icon disappears
        // with the window. This runs before the window is actually gone, so
        // defer it until AppKit has finished closing.
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
