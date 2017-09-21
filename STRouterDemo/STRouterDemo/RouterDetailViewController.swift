//
//  RouterDetailViewController.swift
//  HXRouterDemo
//
//  Created by EasonWang on 2017/4/12.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import UIKit

class RouterDetailViewController: UIViewController {
    
    static func manager() {
        RouterListViewController.register(title: "基本用法") { () -> UIViewController in
            let detail = RouterDetailViewController()
            detail.selectedSelector = #selector(routerBasicUsage)
            return detail
        }
        RouterListViewController.register(title: "自定义参数") { () -> UIViewController in
            let detail = RouterDetailViewController()
            detail.selectedSelector = #selector(routerParameters)
            return detail
        }
        RouterListViewController.register(title: "传入字典信息") { () -> UIViewController in
            let detail = RouterDetailViewController()
            detail.selectedSelector = #selector(routerUserInfo)
            return detail
        }
        RouterListViewController.register(title: "Fallback 到全局 URL Pattern 中") { () -> UIViewController in
            let detail = RouterDetailViewController()
            detail.selectedSelector = #selector(routerFallback)
            return detail
        }
        RouterListViewController.register(title: "Open 结束后执行 Completion Block") { () -> UIViewController in
            let detail = RouterDetailViewController()
            detail.selectedSelector = #selector(routerCompletion)
            return detail
        }
        RouterListViewController.register(title: "取消注册 URL Pattern") { () -> UIViewController in
            let detail = RouterDetailViewController()
            detail.selectedSelector = #selector(routerDeregisterURLPattern)
            return detail
        }
        RouterListViewController.register(title: "同步获取 URL 对应的 Object") { () -> UIViewController in
            let detail = RouterDetailViewController()
            detail.selectedSelector = #selector(routerObjectForURL)
            return detail
        }
    }
    
    // MARK: - 变量
    
    var selectedSelector : Selector?
    
    var textView = UITextView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.frame = CGRect.init(x: 10, y: 74, width: self.view.frame.size.width-20, height: self.view.frame.size.height-84)
        textView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.view.addSubview(textView)
        
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.perform(self.selectedSelector!)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - HXRouter 语法
    /// 基本用法
    
    @objc func routerBasicUsage() {
        STRouter.registerURLPattern(URLPattern: "st://router/detail") {[unowned self] (param,_) in
            self.textView.text = self.formatterSwiftDictionary(dict: param)
        }
        STRouter.openURL(URL: "st://router/detail")
    }
    
    /// 自定义参数
    @objc func routerParameters() {
        STRouter.registerURLPattern(URLPattern: "st://router/parameters?:name:sex") {[unowned self] (param,_) in
            self.textView.text = self.formatterSwiftDictionary(dict: param)
        }
        STRouter.openURL(URL: "st://router/parameters?name=EASON&sex=male")
    }
    
    /// 传入字典信息
    @objc func routerUserInfo() {
        STRouter.registerURLPattern(URLPattern: "st://router/userInfo") {[unowned self] (param,_) in
            self.textView.text = self.formatterSwiftDictionary(dict: param)
        }
        STRouter.openURL(URL: "st://router/userInfo", withUserInfo: ["name":"EASON","sex":"male"], completion: nil)
    }
    
    /// Fallback 到全局 URL Pattern 中
    @objc func routerFallback() {
        
        // 协议 Fallback
        STRouter.registerURLPattern(URLPattern: "st://...") { (_,_) in
            print("打开的 URL 不存在，根据 URL 协议寻找 Fallback 调用")
        }
        
        STRouter.registerURLPattern(URLPattern: "st://router/fallback") {[unowned self] (param) in
            self.textView.text = self.formatterSwiftDictionary(dict: param)
        }
        // 调用的 URL 不存在路由中，将按照协议调用 Fallback
        STRouter.openURL(URL: "st://fallback")
    }
    
    /// Open 结束后执行 Completion Block【注：此用法无法在 OC-Swift 混编时使用】
    @objc func routerCompletion() {
        
        STRouter.registerURLPattern(URLPattern: "st://router/completion") { (param,closer) in
            self.textView.text = self.formatterSwiftDictionary(dict: param)
            
            if closer != nil {
                closer!("Open 结束后执行 Completion Block")
            }
        }
        
        // 调用的 URL 不存在路由中，将按照协议调用 Fallback
        STRouter.openURL(URL: "st://router/completion") { (param) in
            if param != nil {
                print(param!)
            }
        }
    }
    
    /// 取消注册 URL Pattern
    @objc func routerDeregisterURLPattern() {
        // 注册 URL
        STRouter.registerURLPattern(URLPattern: "st://router/deregisterURLPattern") {[unowned self] (param) in
            self.textView.text = self.formatterSwiftDictionary(dict: param)
        }
        // 取消注册的 URL
        STRouter.deregisterURLPattern(URLPattern: "st://router/deregisterURLPattern")
        
        STRouter.openURL(URL: "st://router/deregisterURLPattern")
    }
    
    /// 同步获取 URL 对应的 Object
    @objc func routerObjectForURL() {
        STRouter.registerURLPattern(URLPattern: "st://router/objectForURL") { [unowned self] (param) -> Any? in
            self.textView.text = self.formatterSwiftDictionary(dict: param)
            return "*****111222333444555666*****"
        }
        let value = STRouter.objectForURL(URL: "st://router/objectForURL")
        print(value!)
    }
    
    
    
    /// 格式化 Swift 字典
    @objc func formatterSwiftDictionary(dict:[String:Any]) -> String {
        var str = "匹配到了 url，以下是相关信息: \n\n {\n"
        for (key,value) in dict {
            str += "  \"\(key)\" : \"\(value)\", \n"
        }
        str+="}"
        return str
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
