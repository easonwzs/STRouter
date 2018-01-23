Pod::Spec.new do |s|
  s.name         = "STRouter"
  s.version      = "1.2"
  s.summary      = "STRouter"

  s.description  = <<-DESC
模块儿化开发核心中转站 Router 。
                   DESC

  s.homepage     = "https://github.com/easonwzs"
  s.license      = { :type => "MIT", :file => "LICENSE"}
  s.author             = { "EasonWang" => "easonwzs@126.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/easonwzs/STRouter.git", :tag => s.version }
  s.source_files = 'STRouter/**/*'
  s.requires_arc = true
end
