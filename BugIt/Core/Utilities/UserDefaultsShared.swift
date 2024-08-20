//
//  UserDefaultsShared.swift
//  BugIt
//
//  Created by Mostafa Sultan on 15/08/2024.
//

import Foundation

// used enum since it can't be instantiated
enum UserDefaultsShared {
    static var sheetTabs: [String : Int] {
        get {
            return getValue(forKey: "sheetTabs") as? [String : Int] ?? [:]
        }
        set {
            setValue(newValue, forKey: "sheetTabs")
        }
    }
}

private extension UserDefaultsShared {
    static func setValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func getValue(forKey key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
}
