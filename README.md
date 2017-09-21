<!--![](http://o8smrh7ys.bkt.clouddn.com/STRouter_Logo2.png)-->

<div align=center>
<img src="http://o8smrh7ys.bkt.clouddn.com/HXRouter_white.png" width="100%" >
</div>


## 为什么要再造一个轮子？
已经有几款不错的 Router 了，如 [MGJRouter](https://github.com/meili/MGJRouter)，[JLRoutes](https://github.com/joeldev/JLRoutes)，[HHRouter](https://github.com/Huohua/HHRouter), 但细看了下之后发现，还是不太满足需求。于是在参考了 MGJRouter 的实现思路后使用 swift 重新架构了 STRouter 。

##### MGJRouter 存在的问题：

1. 在路由注册与调用时的 `URLPattern` 格式与标准 `HTTP URL` 有差异。
2. `MGJRouter` 不支持多参数注册与调用。

##### STRouter 在完善了以上方法的同时重新更定了协议 `Fallback` 的实现并增加了 `URL` 重定向。

## 安装
目前暂不支持 cocoapods 安装，可将 STRouter.swift 导入项目中使用。


## 使用姿势

### 最基本的使用

```
STRouter.registerURLPattern(URLPattern: "example://hexun.com/detail?:name:sex"){ (param,closer) in
    // 下面可以在拿到参数后，为其他组件提供对应的服务
    let name = param["name"]
    let sex = param["sex"]
}

STRouter.openURL(URL: "example://hexun.com/detail?name=easonwzs&sex=male")
```
### 带有返回值的使用
```
STRouter.registerURLPattern(URLPattern: "example://hexun.com/detail?:name:sex") { (param) -> Any? in
    // 下面可以在拿到参数后，为其他组件提供对应的服务
    let name = param["name"]
    let sex = param["sex"]
    // 此 handler 需要返回一个值提供给调用者
    return "result"
}

var result = STRouter.objectForURL(URL: "example://hexun.com/detail?name=easonwzs&sex=male")
```

当匹配到 URL 后，`param` 会自带几个 key

```
let kRouterParameterURL = "RouterParameterURL"
let kRouterParameterUserInfo = "RouterParameterUserInfo"
```
### 取消注册某个 URL Pattern
```
STRouter.deregisterURLPattern(URLPattern: "example://hexun.com/detail?:name:sex")
```

### 定义一个全局的 URL Pattern 作为协议 Fallback
定义 Fallback 需要指定协议（协议后加 `...`，如 `http://...`）

```
STRouter.registerURLPattern(URLPattern: "http://..."){ (param,closer) in
    // 当没有地方处理以 http 协议开头的地址时，就会 fallback 到这里
}
STRouter.openURL(URL: "http://www.hexun.com")
```
还可对指定域名地址添加 Fallback ：

```
STRouter.registerURLPattern(URLPattern: "http://www.hexun.com?...") { (param, _) in
	// 此处匹配所有域名为 www.hexun.com 的 URL
}
        
STRouter.openURL(URL: "http://www.hexun.com/1234/default.html")
```

### 相同地址的 URL 如果参数不同，新注册的参数将替换旧的参数
```
STRouter.registerURLPattern(URLPattern: "example://hexun.com/detail?:name") { (param,closer) in
    // 此处的 block 不再会被调用到
}

STRouter.registerURLPattern(URLPattern: "example://hexun.com/detail?:name:age") { (param,closer) in
    // 此处会被调用，因为新注册的 URLPattern 已替换掉上面注册的 URLPattern
}

STRouter.openURL(URL: "example://hexun.com/detail?name=eason")
```

