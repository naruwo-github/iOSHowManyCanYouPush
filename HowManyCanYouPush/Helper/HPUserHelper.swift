//
//  HPUserHelper.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/11.
//

import Foundation

// MARK: - <ユーザの情報をUserDefaultsを使って保存するためのクラス>
class HPUserHelper {
    
    enum CounterKey: String {
        case bestScore = "score"
        case backToInitialFromResultCount = "backToInitialScreenFromResultScreen"
    }
    
    class func sync() {
        let userDefault = UserDefaults.standard
        userDefault.synchronize()
    }
    
    // データ保存のクラス関数
    class func save(_ key: String, value: Any?) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(value, forKey: key)
    }
    
//    // 指定データの削除のクラス関数
//    class func remove(_ key: String) {
//        let userDefault = UserDefaults.standard
//        userDefault.removeObject(forKey: key)
//    }
    
    // 指定データの読み込みのクラス関数
    class func load<T>(_ key: String, returnClass: T.Type) -> T? {
        let userDefault = UserDefaults.standard
        return userDefault.value(forKey: key) as? T
    }
    
//    // 指定データの真偽値を返すクラス関数
//    class func bool(_ key: String) -> Bool {
//        let userDefault = UserDefaults.standard
//        return userDefault.bool(forKey: key)
//    }
//
//    // ユーザデータを全削除するクラス関数
//    class func clearAll() {
//        let userDefault = UserDefaults.standard
//        userDefault.dictionaryRepresentation().forEach({ userDefault.removeObject(forKey: $0.0) })
//    }
    
    static var bestScore: Int {
        get {
            return HPUserHelper.load(HPUserHelper.CounterKey.bestScore.rawValue, returnClass: Int.self) ?? 0
        }
        set {
            HPUserHelper.save(HPUserHelper.CounterKey.bestScore.rawValue, value: newValue)
        }
    }
    
    // 結果画面から初期画面に戻ってきた回数
    static var backToInitialFromResultCount: Int {
        get {
            return HPUserHelper.load(HPUserHelper.CounterKey.backToInitialFromResultCount.rawValue, returnClass: Int.self) ?? 0
        }
        set {
            HPUserHelper.save(HPUserHelper.CounterKey.backToInitialFromResultCount.rawValue, value: newValue)
        }
    }
    
}
