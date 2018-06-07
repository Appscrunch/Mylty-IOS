//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

private typealias LocalizeDelegate = LocalLanguage

enum Language {
    case RUS, ENG, UKR
}

class LocalLanguage: NSObject {
    static let shared = LocalLanguage()
    
    func getTOSLink() -> URL {
        switch currentLanguage {
        case Language.ENG:
            return URL(string: "https://raw.githubusercontent.com/wiki/Appscrunch/Multy/Legal:-Terms-of-service.md")!
        case Language.RUS:
            return URL(string: "https://raw.githubusercontent.com/wiki/Appscrunch/Multy/Legal:-Terms-of-service-(RU).md")!
        case Language.UKR:
            return URL(string: "https://raw.githubusercontent.com/wiki/Appscrunch/Multy/Legal:-Terms-of-service-(UK).md")!
        }
    }
    
    func getPPLink() -> URL {
        switch currentLanguage {
        case Language.ENG:
            return URL(string: "https://raw.githubusercontent.com/wiki/Appscrunch/Multy/Legal:-Privacy-Policy.md")!
        case Language.RUS:
            return URL(string: "https://raw.githubusercontent.com/wiki/Appscrunch/Multy/Legal:-Privacy-Policy-(RU).md")!
        case Language.UKR:
            return URL(string: "https://raw.githubusercontent.com/wiki/Appscrunch/Multy/Legal:-Privacy-Policy-(RU).md")!
        }
    }
    
    var currentLanguage: Language {
        get {
            switch localize(string: Constants.errorString) {
            case "ERROR":
                return Language.ENG
            case "Ошибка":
                return Language.RUS
            case "Помилка":
                return Language.UKR
            default:
                return Language.ENG
            }
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
    }
}
