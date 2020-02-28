//
//  Strings.swift
//
//
//  Created by LEI on 1/23/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

import Foundation

/// Internal current language key
let LCLCurrentLanguageKey = "LCLCurrentLanguageKey"

/// Default language. English. If English is unavailable defaults to base localization.
let LCLDefaultLanguage = "en"

/// Name for language change notification
public let LCLLanguageChangeNotification = "LCLLanguageChangeNotification"

public extension String {
    /**
     Swift 2 friendly localization syntax, replaces NSLocalizedString
     - Returns: The localized string.
     */
    func localized() -> String {
        if let path = Bundle.main.path(forResource: Localize.currentLanguage(), ofType: "lproj"), let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }else if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"), let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }
        return self
    }
    
    /**
     Swift 2 friendly localization syntax with format arguments, replaces String(format:NSLocalizedString)
     - Returns: The formatted localized string with arguments.
     */
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized(), arguments: arguments)
    }
    
    /**
     Swift 2 friendly plural localization syntax with a format argument
     
     - parameter argument: Argument to determine pluralisation
     
     - returns: Pluralized localized string.
     */
    func localizedPlural(_ argument: CVarArg) -> String {
        return NSString.localizedStringWithFormat(localized() as NSString, argument) as String
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(_ token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}

fileprivate var _bundle = "_bundle"

open class BundleEx: Bundle {
    open override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle = objc_getAssociatedObject(self, &_bundle) as? BundleEx
        if bundle != nil {
            return bundle!.localizedString(forKey: key, value: value, table: tableName)
        }else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
    
    open class func onLanguage(_ language: String? = nil) {        
        var resource = ""
        let current = Localize.currentLanguage()
        if language == nil  {   // 启动App
            let defalut = Localize.defaultLanguage()
            guard current != defalut else {
                return
            }
            resource = current
        }else { //再App中设置语言
            guard current != (language!) else {
                return
            }
            resource = language!
        }
        DispatchQueue.once("Bundle") {
            object_setClass(Bundle.main, BundleEx.self);
        }
        var path = Bundle.main.path(forResource: resource, ofType: "lproj")
        if path == nil {
            path = Bundle.main.path(forResource: "Base", ofType: "lproj")
        }
        objc_setAssociatedObject(Bundle.main, &_bundle, BundleEx(path: path!), .OBJC_ASSOCIATION_RETAIN);
    }

}


// MARK: Language Setting Functions

open class Localize: NSObject {
    
    /**
     List available languages
     - Returns: Array of available languages.
     */
    open class func availableLanguages() -> [String] {
        return Bundle.main.localizations
    }
    
    /**
     Current language
     - Returns: The current language. String.
     */
    open class func currentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: LCLCurrentLanguageKey) as? String {
            return currentLanguage
        }
        return defaultLanguage()
    }
    
    /**
     Change the current language
     - Parameter language: Desired language.
     */
    open class func setCurrentLanguage(_ language: String) {
        let selectedLanguage = availableLanguages().contains(language) ? language : defaultLanguage()
        if (selectedLanguage != currentLanguage()){
            BundleEx.onLanguage(language)
            UserDefaults.standard.set(selectedLanguage, forKey: LCLCurrentLanguageKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        }
    }
    
    /**
     Default language
     - Returns: The app's default language. String.
     */
    open class func defaultLanguage() -> String {
        var defaultLanguage: String = String()
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return LCLDefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if (availableLanguages.contains(preferredLanguage)) {
            defaultLanguage = preferredLanguage
        }
        else {
            defaultLanguage = LCLDefaultLanguage
        }
        return defaultLanguage
    }
    
    /**
     Resets the current language to the default
     */
    open class func resetCurrentLanguageToDefault() {
        setCurrentLanguage(self.defaultLanguage())
    }
    
    /**
     Get the current language's display name for a language.
     - Parameter language: Desired language.
     - Returns: The localized string.
     */
    open class func displayNameForLanguage(_ language: String) -> String {
        let locale : Locale = Locale(identifier: currentLanguage())
        if let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.languageCode, value: language) {
            return displayName
        }
        return String()
    }
}
