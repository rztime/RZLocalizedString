//
//  RZLocalizedString.swift
//  RZLocalizedString
//
//  Created by rztime on 2022/5/17.
//

import UIKit

private let rz_local_followsystem = "rz_localized_followsystem"
private let rz_customLanguage = "rz_localized_custom"

/// 管理本地化多语言的
public struct RZLocalizedString {
    private var path: String = ""
    private var localizedString: [String: [String: String]] = [:]
    ///  单例
    public static var shared = RZLocalizedString.init()
    /// 是否跟随系统
    public var followSystem = true {
        didSet {
            UserDefaults.standard.set(followSystem, forKey: rz_local_followsystem)
            self.updateLanguages()
        }
    }
    /// 自定义语言（不包含地区码）
    public var customLanguages : [String] = [] {
        didSet {
            UserDefaults.standard.set(customLanguages, forKey: rz_customLanguage)
            self.updateLanguages()
        }
    }
    /// app支持的语言（不包含地区码）
    public var appLanguages: [String] = []
    /// 系统支持的首选语言列表（不包含地区码）
    public var appleLanguages: [String] = []
    /// 默认支持的语言 ”简体中文“（不包含地区码）
    public var defalutLanguage = "zh-Hans"
    /// 备选的语言列表，根据自定义设置或者跟随系统来配置， 由【自定义】【系统首选语言】【默认】数组组成
    /// 备选优先级  自定义 > 跟随系统 > 默认
    private var useLanguages: [String] = []
    
    public init() {
        guard let path = Bundle.main.path(forResource: "LocalizedString", ofType: "txt") else { return }
        self.path = path
        self.setupLocalizedString()
        let defaults = UserDefaults.standard
        self.followSystem = defaults.bool(forKey: rz_local_followsystem)
        self.customLanguages = (defaults.array(forKey: rz_customLanguage) as? [String]) ?? []
        let county = Locale.current.identifier.components(separatedBy: "_").last
        let county_ = "-\(county ?? "")"
        self.appleLanguages = Locale.preferredLanguages.compactMap { text in
            if text.hasSuffix(county_) {
                let t = text.prefix(text.count - county_.count)
                return "\(t)"
            }
            return text
        }
        self.updateLanguages()
    }
    /// path :  Bundle.main.path(forResource: "LocalizedString", ofType: "txt")
    public static func resource(for path: String?) {
        RZLocalizedString.shared.path = path ?? ""
        RZLocalizedString.shared.setupLocalizedString()
    }
    /// 通过id获取本地化语言字符串
    /// language: 指定语言，如果未设置，会按照备选的语言列表来获取文本
    public static func string(for id: String, language: String? = nil) -> String? {
        let local = RZLocalizedString.shared
        guard let dict = local.localizedString[id] else { return nil}
        if let language = language, let text = dict[language], text.count > 0 {
            return text
        }
        /// 从备选的语言中找对应的字符串
        let tempLanguages: [String] = local.useLanguages
        if let first = tempLanguages.first, let text = dict[first], text.count > 0 {
            return text
        }
        if let first = tempLanguages.first(where: { lg in
            if let text = dict[lg] {
                return !text.isEmpty
            }
            return false
        }) {
            return dict[first]
        }
        return nil
    }
}


private let t_ = "[-|-t-|-]"
private let r_ = "[-|-r-|-]"
private let n_ = "[-|-n-|-]"
extension RZLocalizedString {
    private mutating func updateLanguages() {
        var tempLanguages: [String] = []
        /// 备选优先级  自定义 > 跟随系统 > 默认
        if !self.followSystem {
            tempLanguages.append(contentsOf: self.customLanguages)
        }
        tempLanguages.append(contentsOf: self.appleLanguages)
        tempLanguages.append(self.defalutLanguage)
        self.useLanguages = tempLanguages
    }
    
    private mutating func setupLocalizedString() {
        var text = (try? String.init(contentsOfFile: path)) ?? ""
        if text.isEmpty {
            return
        }
        /// 去掉顶部无效文本
        text = text.components(separatedBy: "[------------------------------star------------------------------]").last ?? ""
        /// Excel文本以“\r” "\n"做分格，所以先转义
        text = text.replacingOccurrences(of: "\\t", with: t_)
        text = text.replacingOccurrences(of: "\\n", with: n_)
        text = text.replacingOccurrences(of: "\\r", with: r_)
        /// 分割每一行内容，以及每一列内容，以[[String]]格式
        var list = text.components(separatedBy: "\r\n").compactMap { text -> [String]? in
            var t_ = text.replacingOccurrences(of: "\t", with: "")
            t_ = t_.replacingOccurrences(of: "\n", with: "")
            t_ = t_.replacingOccurrences(of: "\r", with: "")
            if t_.count == 0 {  // 抛弃无效数据
                return nil
            }
            // 将"\r" "\n" 还原
            var rows = text.components(separatedBy: "\t")
            rows = rows.compactMap{ text in
                var t = text.replacingOccurrences(of: r_, with: "\r")
                t = t.replacingOccurrences(of: n_, with: "\n")
                t = t.replacingOccurrences(of: t_, with: "\t")
                return t
            }
            return rows
        }
        /// 第一条是中文备注语种，所以移除
        list.removeFirst()
        /// 移除key并将key数据做非空处理
        let keys = list.removeFirst()
        list.forEach { text in
            var dict: [String: String] = [:]
            let _ = text.enumerated().forEach { t in
                let key = keys[t.offset]
                if key.count != 0, t.element.count != 0 {
                    dict[key] = t.element
                }
            }
            let id = dict["id"] ?? ""
            self.localizedString[id] = dict
        }
        self.appLanguages = keys.filter({$0 != "id" && $0.count > 0})
    }
}
