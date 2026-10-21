import AppKit

/// A single active provider, with independent saved configurations. Changes
/// apply to the next recognition request; in-flight work keeps its snapshot.
final class OCRSettingsPane: NSView, NSTextFieldDelegate {
    private var kind = Defaults.ocrProviderKind
    private let providerPopup = NSPopUpButton()
    private let descriptionLabel = NSTextField(wrappingLabelWithString: "")
    private let statusLabel = NSTextField(wrappingLabelWithString: "")
    private let apiKeyField = OCRSecureField()
    private let secretKeyField = OCRSecureField()
    private let regionField = OCREditableField()
    private var labels: [String: NSTextField] = [:]
    private var rows: [String: NSView] = [:]

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        buildUI()
        loadConfig()
        refreshLocalization()
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged),
                                               name: .languageDidChange, object: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit { NotificationCenter.default.removeObserver(self) }

    private func buildUI() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -22)
        ])

        providerPopup.target = self
        providerPopup.action = #selector(providerChanged)
        stack.addArrangedSubview(makeRow("provider", field: providerPopup))

        for label in [descriptionLabel, statusLabel] {
            label.font = .systemFont(ofSize: 12)
            label.textColor = .secondaryLabelColor
            label.maximumNumberOfLines = 0
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        stack.addArrangedSubview(descriptionLabel)
        for (key, field) in [("apiKey", apiKeyField as NSTextField), ("secretKey", secretKeyField),
                             ("region", regionField)] {
            field.delegate = self
            field.font = .systemFont(ofSize: 12)
            field.lineBreakMode = .byTruncatingMiddle
            field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            let row = makeRow(key, field: field)
            rows[key] = row
            stack.addArrangedSubview(row)
        }
        stack.addArrangedSubview(statusLabel)
        for view in stack.arrangedSubviews {
            view.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }
    }

    private func makeRow(_ key: String, field: NSView) -> NSView {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        labels[key] = label
        let row = NSStackView(views: [label, field])
        row.orientation = .vertical
        row.alignment = .leading
        row.spacing = 6
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalTo: row.widthAnchor).isActive = true
        return row
    }

    private var config: OCRProviderConfig {
        OCRProviderConfig(apiKey: apiKeyField.stringValue, secretKey: secretKeyField.stringValue,
                          region: regionField.stringValue).normalized()
    }

    private func loadConfig() {
        let config = OCRConfigStore.load(kind)
        apiKeyField.stringValue = config.apiKey
        secretKeyField.stringValue = config.secretKey
        regionField.stringValue = config.region
    }

    func controlTextDidChange(_ obj: Notification) {
        OCRConfigStore.save(config, for: kind)
        refreshStatus()
    }

    @objc private func providerChanged() {
        let index = providerPopup.indexOfSelectedItem
        guard OCRProviderKind.allCases.indices.contains(index) else { return }
        OCRConfigStore.save(config, for: kind)
        kind = OCRProviderKind.allCases[index]
        Defaults.ocrProviderKind = kind
        loadConfig()
        refreshLocalization()
    }

    @objc private func languageChanged() { refreshLocalization() }

    private func refreshLocalization() {
        providerPopup.removeAllItems()
        providerPopup.addItems(withTitles: OCRProviderKind.allCases.map(\.displayName))
        providerPopup.selectItem(at: OCRProviderKind.allCases.firstIndex(of: kind) ?? 0)
        labels["provider"]?.stringValue = L10n.ocrProviderLabel
        labels["apiKey"]?.stringValue = kind == .tencent ? "SecretId" : "API Key"
        labels["secretKey"]?.stringValue = kind == .tencent ? "SecretKey" : "Secret Key"
        labels["region"]?.stringValue = L10n.ocrRegionLabel
        apiKeyField.placeholderString = ""
        regionField.placeholderString = "ap-guangzhou"
        rows["apiKey"]?.isHidden = kind == .apple
        rows["secretKey"]?.isHidden = !kind.needsSecret
        rows["region"]?.isHidden = kind != .tencent
        descriptionLabel.stringValue = kind == .apple ? L10n.ocrLocalDescription : L10n.ocrCloudDescription
        refreshStatus()
    }

    private func refreshStatus() {
        do {
            try config.validate(for: kind)
            statusLabel.stringValue = L10n.ocrSettingsSaved
            statusLabel.textColor = .secondaryLabelColor
        } catch {
            statusLabel.stringValue = error.localizedDescription
            statusLabel.textColor = .systemOrange
        }
    }
}

private func ocrEditingShortcut(_ event: NSEvent) -> Bool {
    guard event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command else { return false }
    let selector: Selector
    switch event.charactersIgnoringModifiers {
    case "a": selector = #selector(NSText.selectAll(_:))
    case "c": selector = #selector(NSText.copy(_:))
    case "v": selector = #selector(NSText.paste(_:))
    case "x": selector = #selector(NSText.cut(_:))
    default: return false
    }
    return NSApp.sendAction(selector, to: nil, from: nil)
}

private final class OCREditableField: NSTextField {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        ocrEditingShortcut(event) || super.performKeyEquivalent(with: event)
    }
}

private final class OCRSecureField: NSSecureTextField {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        ocrEditingShortcut(event) || super.performKeyEquivalent(with: event)
    }
}
