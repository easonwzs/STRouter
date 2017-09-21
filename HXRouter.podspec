Pod::Spec.new do |s|
  s.name         = "HXRouter"
  s.version      = "0.1"
  s.summary      = "HXRouter"

  s.description  = <<-DESC
和讯模块儿化开发核心中转站 Router 。
                   DESC

  s.homepage     = "http://git.oschina.net/onemorelayer"
  s.license      = { :type => "MIT", :file => "LICENSE"}
  s.author             = { "EasonWang" => "easonwzs@126.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://git.oschina.net/oneonelayer/HXRouter.git", :tag => s.version }
  s.source_files = 'HXRouter/**/*'
  s.requires_arc = true
end
