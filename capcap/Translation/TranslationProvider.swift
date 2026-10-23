import Foundation

// MARK: - Target language

/// Languages the OCR text can be translated into. The source language is
/// detected locally before the provider request, so only the target is configurable.
enum TranslationLanguage: String, CaseIterable {
    case chinese = "zh"
    case english = "en"
    case vietnamese = "vi"
    case hindi = "hi"
    case spanish = "es"
    case french = "fr"
    case arabic = "ar"
    case bengali = "bn"
    case portuguese = "pt"
    case russian = "ru"
    case urdu = "ur"
    case indonesian = "id"
    case german = "de"
    case japanese = "ja"
    case korean = "ko"
    case turkish = "tr"

    static var appDefault: TranslationLanguage {
        switch Defaults.language {
        case .zh: return .chinese
        case .zhTW: return .chinese
        case .en: return .english
        }
    }

    var displayName: String {
        switch self {
        case .chinese:    return "中文"
        case .english:    return "English"
        case .vietnamese: return "Tiếng Việt"
        case .hindi:      return "हिन्दी"
        case .spanish:    return "Español"
        case .french:     return "Français"
        case .arabic:     return "العربية"
        case .bengali:    return "বাংলা"
        case .portuguese: return "Português"
        case .russian:    return "Русский"
        case .urdu:       return "اردو"
        case .indonesian: return "Indonesia"
        case .german:     return "Deutsch"
        case .japanese:   return "日本語"
        case .korean:     return "한국어"
        case .turkish:    return "Türkçe"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .chinese:    return "zh-Hans"
        case .english:    return "en"
        case .vietnamese: return "vi"
        case .hindi:      return "hi"
        case .spanish:    return "es"
        case .french:     return "fr"
        case .arabic:     return "ar"
        case .bengali:    return "bn"
        case .portuguese: return "pt"
        case .russian:    return "ru"
        case .urdu:       return "ur"
        case .indonesian: return "id"
        case .german:     return "de"
        case .japanese:   return "ja"
        case .korean:     return "ko"
        case .turkish:    return "tr"
        }
    }

    var localizedDisplayName: String {
        let locale = Locale(identifier: Defaults.language.lprojName)
        return locale.localizedString(forIdentifier: localeIdentifier) ?? displayName
    }

    /// English name fed into the translation prompt.
    var promptName: String {
        switch self {
        case .chinese:    return "Simplified Chinese"
        case .english:    return "English"
        case .vietnamese: return "Vietnamese"
        case .hindi:      return "Hindi"
        case .spanish:    return "Spanish"
        case .french:     return "French"
        case .arabic:     return "Arabic"
        case .bengali:    return "Bengali"
        case .portuguese: return "Portuguese"
        case .russian:    return "Russian"
        case .urdu:       return "Urdu"
        case .indonesian: return "Indonesian"
        case .german:     return "German"
        case .japanese:   return "Japanese"
        case .korean:     return "Korean"
        case .turkish:    return "Turkish"
        }
    }
}

// MARK: - Provider kinds

/// Translation providers: Apple Translation (on-device) and OpenAI-compatible
/// chat-completions endpoints (DeepSeek, custom).
enum TranslationProviderKind: String, CaseIterable {
    case apple
    case deepseek
    case custom

    var displayName: String {
        switch self {
        case .apple:    return "Apple Translation"
        case .deepseek: return "DeepSeek"
        case .custom:   return L10n.translationProviderCustom
        }
    }

    /// Apple's on-device Translation framework is available starting in macOS 15.
    var isAvailableOnCurrentSystem: Bool {
        switch self {
        case .apple:
            if #available(macOS 15.0, *) { return true }
            return false
        case .deepseek, .custom:
            return true
        }
    }

    var isAppleTranslation: Bool { self == .apple }
    var isDirectTranslationAPI: Bool { isAppleTranslation }

    var defaultEndpoint: String {
        switch self {
        case .apple:    return ""
        case .deepseek: return "https://api.deepseek.com/v1/chat/completions"
        case .custom:   return ""
        }
    }

    var defaultModel: String {
        switch self {
        case .apple:    return ""
        // DeepSeek retired `deepseek-chat`; the API now only accepts
        // `deepseek-flash` and `deepseek-v4-pro`.
        case .deepseek: return "deepseek-flash"
        case .custom:   return ""
        }
    }

    /// Model names offered as a closed list. Only providers whose catalog is
    /// known and small enough to pick from populate this; an empty array means
    /// the model is free text.
    var selectableModels: [String] {
        switch self {
        case .deepseek: return ["deepseek-flash", "deepseek-v4-pro"]
        case .apple, .custom: return []
        }
    }

    /// Completion candidates for the free-text model field. These are only
    /// suggestions — any name the user types is still accepted.
    static let suggestedModels: [String] = [
        // DeepSeek
        "deepseek-flash",
        "deepseek-v4-pro",
        // Moonshot / Kimi
        "kimi-k2-0905-preview",
        "kimi-k2-turbo-preview",
        "kimi-latest",
        "moonshot-v1-8k",
        "moonshot-v1-32k",
        "moonshot-v1-128k",
        // Alibaba Qwen
        "qwen-max",
        "qwen-plus",
        "qwen-turbo",
        "qwen-long",
        "qwen3-max",
        // Zhipu GLM
        "glm-4.6",
        "glm-4-plus",
        "glm-4-flash",
        // OpenAI
        "gpt-4o",
        "gpt-4o-mini",
        "gpt-4.1",
        "gpt-4.1-mini",
        // Anthropic
        "claude-sonnet-4-5",
        "claude-opus-4-1",
        "claude-haiku-4-5",
        // Google
        "gemini-2.5-pro",
        "gemini-2.5-flash",
    ]

    var endpointRequired: Bool {
        switch self {
        case .apple:    return false
        case .deepseek: return false
        case .custom:   return true
        }
    }

    var isAPIKeyRequired: Bool {
        switch self {
        case .apple:    return false
        case .deepseek, .custom: return true
        }
    }
}

// MARK: - Config model

struct TranslationConfig {
    var apiKey: String = ""
    var model: String = ""
    var endpoint: String = ""

    func resolvedModel(for kind: TranslationProviderKind) -> String {
        let trimmed = model.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? kind.defaultModel : trimmed
    }

    func resolvedEndpoint(for kind: TranslationProviderKind) -> String {
        let trimmed = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? kind.defaultEndpoint : trimmed
    }
}

// MARK: - Persistence

/// Stores one JSON-encoded config plus an enabled flag per provider in
/// UserDefaults — mirrors the upload `ProviderConfigStore` pattern.
enum TranslationConfigStore {
    private static let providerOrderKey = "translation.providerOrder"

    private static func configKey(for kind: TranslationProviderKind) -> String {
        "translation.\(kind.rawValue).config"
    }

    private static func enabledKey(for kind: TranslationProviderKind) -> String {
        "translation.\(kind.rawValue).enabled"
    }

    /// Model names DeepSeek has retired. A stored value overrides the provider
    /// default, so these are cleared on read to fall back to the live default
    /// instead of failing every request with an invalid-model error.
    private static let retiredModels: [TranslationProviderKind: Set<String>] = [
        .deepseek: ["deepseek-chat", "deepseek-reasoner"]
    ]

    static func load(_ kind: TranslationProviderKind) -> TranslationConfig {
        guard let data = UserDefaults.standard.data(forKey: configKey(for: kind)),
              let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
            return TranslationConfig()
        }
        var model = dict["model"] ?? ""
        if retiredModels[kind]?.contains(model.trimmingCharacters(in: .whitespacesAndNewlines)) == true {
            model = ""
        }
        return TranslationConfig(
            apiKey: dict["apiKey"] ?? "",
            model: model,
            endpoint: dict["endpoint"] ?? ""
        )
    }

    static func save(_ config: TranslationConfig, for kind: TranslationProviderKind) {
        let dict = [
            "apiKey": config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
            "model": config.model.trimmingCharacters(in: .whitespacesAndNewlines),
            "endpoint": config.endpoint.trimmingCharacters(in: .whitespacesAndNewlines),
        ]
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: configKey(for: kind))
        }
        NotificationCenter.default.post(name: .translationConfigDidChange, object: nil)
    }

    static func clear(_ kind: TranslationProviderKind) {
        UserDefaults.standard.removeObject(forKey: configKey(for: kind))
        NotificationCenter.default.post(name: .translationConfigDidChange, object: nil)
    }

    static func isEnabled(_ kind: TranslationProviderKind) -> Bool {
        let key = enabledKey(for: kind)
        if UserDefaults.standard.object(forKey: key) == nil {
            // Apple Translation runs on-device and needs no credentials, so it
            // is the one provider that can be useful before any setup.
            return kind.isAppleTranslation
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    static func setEnabled(_ enabled: Bool, for kind: TranslationProviderKind) {
        UserDefaults.standard.set(enabled, forKey: enabledKey(for: kind))
        NotificationCenter.default.post(name: .translationConfigDidChange, object: nil)
    }

    /// True when the saved config has the fields a request needs.
    static func isConfigured(_ kind: TranslationProviderKind) -> Bool {
        if kind.isAppleTranslation { return kind.isAvailableOnCurrentSystem }
        let cfg = load(kind)
        if kind.isAPIKeyRequired {
            guard !cfg.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        }
        if kind.endpointRequired {
            guard !cfg.endpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        }
        // A provider without a built-in default model needs one spelled out.
        if kind.defaultModel.isEmpty, !kind.isAppleTranslation {
            return !cfg.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    /// Enabled AND configured — the providers shown in the OCR panel.
    static func isUsable(_ kind: TranslationProviderKind) -> Bool {
        kind.isAvailableOnCurrentSystem && isEnabled(kind) && isConfigured(kind)
    }

    static func orderedKinds() -> [TranslationProviderKind] {
        let saved = UserDefaults.standard.stringArray(forKey: providerOrderKey) ?? []
        var seen = Set<TranslationProviderKind>()
        var result: [TranslationProviderKind] = []

        for raw in saved {
            guard let kind = TranslationProviderKind(rawValue: raw),
                  kind.isAvailableOnCurrentSystem,
                  !seen.contains(kind) else { continue }
            result.append(kind)
            seen.insert(kind)
        }

        for kind in TranslationProviderKind.allCases
            where kind.isAvailableOnCurrentSystem && !seen.contains(kind) {
            result.append(kind)
            seen.insert(kind)
        }

        return result
    }

    static func setProviderOrder(_ kinds: [TranslationProviderKind]) {
        var seen = Set<TranslationProviderKind>()
        var normalized: [TranslationProviderKind] = []

        for kind in kinds where !seen.contains(kind) {
            normalized.append(kind)
            seen.insert(kind)
        }

        for kind in TranslationProviderKind.allCases where !seen.contains(kind) {
            normalized.append(kind)
            seen.insert(kind)
        }

        UserDefaults.standard.set(normalized.map(\.rawValue), forKey: providerOrderKey)
        NotificationCenter.default.post(name: .translationConfigDidChange, object: nil)
    }

    static func usableKinds() -> [TranslationProviderKind] {
        orderedKinds().filter { isUsable($0) }
    }
}

// MARK: - Target language preference

extension Defaults {
    static var translationTargetLanguage: TranslationLanguage {
        get {
            let raw = UserDefaults.standard.string(forKey: "translation.targetLanguage") ?? ""
            return TranslationLanguage(rawValue: raw) ?? .chinese
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "translation.targetLanguage")
        }
    }

}
