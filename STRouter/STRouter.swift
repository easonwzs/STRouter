//
//  STRouter.swift
//  STRouter
//
//  Created by EasonWang on 2017/2/20.
//  Copyright © 2017年 EasonWang. All rights reserved.
//
//  version : 1.5

import Foundation
import UIKit

public let kRouterParameterURL = "RouterParameterURL"
public let kRouterParameterUserInfo = "RouterParameterUserInfo"

private let ST_ROUTER_WILDCARD_CHARACTER = "~"
private let ST_SpecialCharacters = "/?&."


/// routerParameters 里内置的几个参数会用到上面定义的 string
public typealias STRouterHandlerType = ([String:Any],STRouterOpenURLCompletionType?) -> Void
/// 需要返回一个值，配合 objectForURL: 使用
public typealias STRouterObjectHandlerType = ([String:Any]) -> Any?
/// open 方法中 completion 闭包
public typealias STRouterOpenURLCompletionType = (Any?)->Void


public final class STRouter : NSObject {
    
    // MARK: - public 属性
    
    @objc public static let routerParameterURL = kRouterParameterURL
    @objc public static let routerParameterUserInfo = kRouterParameterUserInfo
    
    
    // MARK: - public 方法
    
    /// 注册 URLPattern 对应的 Handler，在 handler 中可以初始化 VC，然后对 VC 做各种操作
    ///
    /// - Parameters:
    ///   - URLPattern: 带上 scheme，如 example://hexun.com/detail?:id
    ///   - toHandler: 该 block 会传一个字典，包含了注册的 URL 中对应的变量。
    ///                假如注册的 URL 为 example://hexun.com/detail?:id 那么，就会传一个 ["id":4] 这样的字典过来
    @objc public static func registerURLPattern(URLPattern:String?,toHandler handler:STRouterHandlerType?){
        if handler == nil || URLPattern == nil { return }
        sharedInstance.addURLPattern(URLPattern: URLPattern!,handler:handler)
    }
    
    /// 注册 URLPattern 对应的 ObjectHandler，需要返回一个值给调用方
    ///
    /// - Parameters:
    ///   - URLPattern: 带上 scheme，如 example://hexun.com/detail?:id
    ///   - toObjectHandler: 该 block 会传一个字典，包含了注册的 URL 中对应的变量。
    ///                      假如注册的 URL 为 example://hexun.com/detail?:id 那么，就会传一个 ["id":4] 这样的字典过来
    ///                      此block需要返回一个值给调用方
    @objc public static func registerURLPattern(URLPattern:String?,toObjectHandler handler:STRouterObjectHandlerType?) {
        if handler == nil || URLPattern == nil { return }
        sharedInstance.addURLPattern(URLPattern: URLPattern!,handler:handler)
    }
    
    /// 取消注册某个 URL Pattern
    ///
    /// - Parameter URLPattern: 需要取消的 URL
    @objc public static func deregisterURLPattern(URLPattern:String?) {
        if canOpenURL(URL: URLPattern) {
            sharedInstance.addURLPattern(URLPattern: URLPattern!,handler:nil)
        }
    }
    
    /// 打开此 URL
    /// 会在已注册的 URL -> Handler 中寻找，如果找到，则执行 Handler
    ///
    /// - Parameter URL: URL 带 Scheme，如 example://hexun.com/detail?id=4
    @objc public static func openURL(URL:String?){
        openURL(URL: URL, completion: nil)
    }
    
    /// 打开此 URL，同时当操作完成时，执行额外的代码
    ///
    /// - Parameters:
    ///   - URL: 带 Scheme 的 URL，如 example://hexun.com/detail?id=4
    ///   - completion: URL 处理完成后的 callback，完成的判定跟具体的业务相关
    @objc public static func openURL(URL:String?,completion:STRouterOpenURLCompletionType?){
        openURL(URL: URL, withUserInfo: nil, completion: completion)
    }
    
    /// 打开此 URL，带上附加信息，同时当操作完成时，执行额外的代码
    ///
    /// - Parameters:
    ///   - URL: 带 Scheme 的 URL，如 example://hexun.com/detail?id=4
    ///   - userInfo: 附加参数
    ///   - completion: URL 处理完成后的 callback，完成的判定跟具体的业务相关
    @objc public static func openURL(URL:String?,withUserInfo userInfo:[String:Any]?,completion:STRouterOpenURLCompletionType?){
        guard let openURL = URL else { return }
        
        guard var parameters:[String:Any] = sharedInstance.extractParametersFromURL(url: openURL) else { return }
        
        if userInfo != nil {
            parameters[kRouterParameterUserInfo] = userInfo
        }
        
        if let handler = parameters["block"] as? STRouterHandlerType {
            parameters["block"] = nil
            handler(parameters,completion)
        }
    }
    
    /// 查找谁对某个 URL 感兴趣，如果有的话，返回一个值
    ///
    /// - Parameter URL: 需要打开的 URL
    /// - Returns: 此方法可以获取一个返回值
    @objc public static func objectForURL(URL:String?) -> Any? {
        return objectForURL(URL: URL, withUserInfo: nil)
    }
    
    /// 查找谁对某个 URL 感兴趣，如果有的话，返回一个值
    ///
    /// - Parameters:
    ///   - URL: 需要打开的 URL
    ///   - userInfo: 附加参数
    /// - Returns: 此方法可以获取一个返回值
    @objc public static func objectForURL(URL:String?,withUserInfo userInfo:[String:Any]?) -> Any? {
        guard let openURL = URL else { return nil }
        guard var parameters:[String:Any] = sharedInstance.extractParametersFromURL(url: openURL) else { return nil }
        
        guard let handler = parameters["block"] as? STRouterObjectHandlerType else { return nil }
        
        if userInfo != nil {
            parameters[kRouterParameterUserInfo] = userInfo
        }
        
        parameters["block"] = nil
        return handler(parameters)
        
    }
    
    /// 检查 URL 是否已在路由中进行注册
    ///
    /// - Parameter URL: 需要检查的 URL
    /// - Returns: 返回 true 表示已注册，false 未注册
    @objc public static func canOpenURL(URL:String?) -> Bool {
        guard let openURL = URL else { return false }
        guard let param:[String:Any] = sharedInstance.extractParametersFromURL(url: openURL) else { return false }
        if param["block"] != nil{
            return true
        }
        return false
    }
    
    
    
    
    // MARK: - private 私有属性与方法
    
    /// 私有的单例类对象
    private static let sharedInstance = STRouter()
    private override init(){}
    
    /// 保存所有已注册的 URL
    /// 结构类似 @{@"beauty": @{@":id": {@"_", [block copy]}}}
    private var routers = [String:Any]()
    
    /// 向路由中添加 URLPattern
    ///
    /// - Parameters:
    ///   - URLPattern: 需要添加的 URLPattern
    ///   - handler: handler
    private func addURLPattern(URLPattern:String,handler: Any?){
        
        let pathComponents = pathComponentsFromURL(URL: URLPattern)
        
        guard !pathComponents.isEmpty else { return }
        
        var subRouters = self.routers
        
        subRouters = iterationRouters(keys: pathComponents, routers: subRouters,handler: handler)
        
        self.routers[pathComponents[0]] = subRouters[pathComponents[0]]
    }
    
    
    /// 递归 routers
    private func iterationRouters(keys:[String],routers: [String:Any],handler: Any?)->[String:Any]{
        var param = routers
        guard !keys.isEmpty else {
            if handler==nil {
                return ["_":""]
            }
            return ["_":handler!]
        }
        /// 移除首元素，并获取值
        var others = keys
        let key = others.removeFirst()
        
        if param[key] == nil {
            if key.hasPrefix(":") {
                param = [String:Any]()
            }
            param[key] = iterationRouters(keys: others, routers: [String:Any](),handler: handler)
        }else if param[key] is [String : Any]{
            param[key] = iterationRouters(keys: others, routers: (routers[key] as! [String : Any]),handler: handler)
        }
        return param
    }
    
    
    /// 解析 URL 路径的组成
    ///
    /// - Parameter URL: url
    private func pathComponentsFromURL(URL:String) -> [String]{
        var pathComponents = [String]()
        // 如果传入的地址不包含 "://" ，则退出
        guard let upperBound = URL.range(of: "://")?.upperBound else{ return pathComponents }
        
        let pathSegments = URL.components(separatedBy: "://")
        
        // 如果 URL 包含协议，那么把协议作为第一个元素放进去
        pathComponents.append(pathSegments.first!)
        
        // 如果只有协议，那么放一个占位符
        if (pathSegments.count >= 2 && !pathSegments[1].isEmpty) || pathSegments.count < 2 {
            pathComponents.append(ST_ROUTER_WILDCARD_CHARACTER)
        }
        
        // 如果传入的地址不是标准地址，则退出
//        URL.sub
        guard let urlSet = String(URL[upperBound...]).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) , let urlComponent = NSURL.init(string: urlSet) else { return [] }
        // 如果不可获取地址的组成，则退出
        guard var components = urlComponent.pathComponents else { return [] }
        // 获取地址组成是无法获取'?'分割的元素，所以需要自己添加地址后链接的参数
        let questionMarkSegments = URL.components(separatedBy: "?")
        
        if questionMarkSegments.count >= 2 && !questionMarkSegments[1].isEmpty {
            if let index = URL.range(of: "?")?.upperBound {
                let p = String(URL[index...])
                components.append(p)
            }
        }
        
        for pathComponent in components {
            if pathComponent == "/" || pathComponent == "?" { continue }
            pathComponents.append(pathComponent)
        }
        return pathComponents
    }
    
    
    /// 根据指定的地址，提取参数
    ///
    /// - Parameter url:传入url
    /// - Returns: 返回解析后的字典
    private func extractParametersFromURL(url:String) -> [String:Any]? {
        
        /// 取出注册的 URL 中包含的 key 值
        ///
        /// - Parameter keyString: 注册的 URL 中包含的 key 值。例如： :name:age
        /// - Returns: 返回包含 key 值的数组。 例如： ["name","age"]
        func getKeysFromKeystring(keyString:String) -> [String]? {
            let keyComponents = keyString.components(separatedBy: ":")
            var keys:[String]?
            for var value in keyComponents {
                value = value.replacingOccurrences(of: " ", with: "")
                if !value.isEmpty {
                    if keys == nil {
                        keys = []
                    }
                    keys!.append(value)
                }
            }
            return keys
        }
        
        /// 根据传入的参数，生成字典
        ///
        /// - Parameter param: 传入的参数，例如：  name=Eason&age=27
        /// - Returns: 返回字典格式，例如：  ["name": "eason", "age": "27"]
        func getResultDictFromParam(param:String?) -> [String:String] {
            // 转换成字典字符串格式
            var resultDict:[String:String] = [:]
            if param == nil {
                return resultDict
            }
            
            var questionMarkComponents = param!.components(separatedBy: "?")
            let paramStr = questionMarkComponents.removeFirst()
            
            let dictComponets = paramStr.components(separatedBy: "&")
            for (index,value) in dictComponets.enumerated() {
                let keyValueComponents = value.components(separatedBy: "=")
                if keyValueComponents.count == 2 {
                    let key = keyValueComponents.first!
                    var value = keyValueComponents.last!
                    if index == dictComponets.count-1 && !questionMarkComponents.isEmpty {
                        value = value + "?" + questionMarkComponents.joined(separator: "?")
                    }
                    resultDict[key] = value
                }
            }
            return resultDict
        }
        
        /// 配置 parameters
        var parameters:[String:Any] = [kRouterParameterURL:url]
        
        var subRouters = self.routers
        guard !subRouters.keys.isEmpty else { return nil }
        
        let pathComponents = pathComponentsFromURL(URL: url)
        
        var found = false
        // 协议通配block
        var wildcardBlock:[String:Any]?
        // isFinal判断是否遍历到最后
        var isFinal = false
        var count = 0
        // 带标签的循环语句
        ipBreak: for pathComponent in pathComponents {
            count+=1
            let subRoutersKeys = subRouters.keys.sorted(by: >)
            /// 判断协议是否设置 Fallback
            if subRoutersKeys.contains("...") {
                wildcardBlock = subRouters["..."] as? [String : Any]
            }
            for key in subRoutersKeys {
                if key == pathComponent || key == ST_ROUTER_WILDCARD_CHARACTER {
                    found = true
                    subRouters = subRouters[key] as! [String : Any]
                    if count == pathComponents.count {
                        isFinal = true
                    }
                    break
                } else if key.hasPrefix(":") {
                    found = true
                    subRouters = subRouters[key] as! [String : Any]
                    let paramDict = getResultDictFromParam(param: pathComponent)
                    guard let paramKeys = getKeysFromKeystring(keyString: key) else {
                        break
                    }
                    for pKey in paramKeys {
                        if let value = paramDict[pKey] {
                            parameters[pKey] = value
                        }else{
                            parameters[pKey] = ""
                        }
                    }
                    if count == pathComponents.count {
                        isFinal = true
                    }
                    break
                } else if key == "..." {
                    found = true
                    subRouters = subRouters[key] as! [String : Any]
                    // 通过标签终止最外层循环
                    break ipBreak
                }
            }
            
            if !found && subRouters["_"] == nil {
                return nil
            }
        }
        // 如果没有遍历到最后并且协议 Fallback 存在则调用 Fallback block
        if !isFinal && wildcardBlock != nil {
            let wildDict = getResultDictFromParam(param: pathComponents.last)
            if !wildDict.isEmpty {
                for (key,value) in wildDict {
                    parameters[key] = value
                }
            }
            parameters["block"] = wildcardBlock!["_"]
        }
        else if subRouters["_"] != nil {
            parameters["block"] = subRouters["_"]!
        }
        return parameters
    }
    
    private func rangeOfSpecialCharacter(checkedString:String) -> Range<String.Index>? {
        let characterSet = CharacterSet.init(charactersIn: ST_SpecialCharacters)
        return checkedString.rangeOfCharacter(from: characterSet)
    }
}
