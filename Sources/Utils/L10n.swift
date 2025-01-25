//
// Created by yechentide on 2025/01/25
//

enum SupportedLanguage: String {
    case en
    case zh
    case ja
}

extension String {
    func localized() -> String {
        guard let dict = L10n.catalog[self],
              let localizedValue = dict[L10n.language]
        else {
            return self
        }
        return localizedValue
    }
}

func setLanguage(_ language: String?) {
    if let specifiedLang = language, let lang = SupportedLanguage(rawValue: specifiedLang) {
        L10n.language = lang
    } else {
        L10n.language = .en
    }
}

enum L10n {
    nonisolated(unsafe) static var language: SupportedLanguage = .en

    static let catalog: [String:[SupportedLanguage:String]] = [
        "$ES_test" : [
            .en: "test",
            .zh: "测试",
            .ja: "テスト",
        ]
    ]
}
