//
//  ViewController.swift
//  HXRouterDemo
//
//  Created by EasonWang on 2017/3/8.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import UIKit

var titleWithHandlers = [String:Any]()
var titles = [String]()


class RouterListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    /// 注册title与handler的映射关系
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - handler: 闭包
    static func register(title:String,handler:@escaping ()->UIViewController) {
        titles.append(title)
        titleWithHandlers[title] = handler
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "")
        }
        cell?.textLabel?.text = titles[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = (titleWithHandlers[titles[indexPath.row]] as? ()->UIViewController)?()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

