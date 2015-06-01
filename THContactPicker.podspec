
Pod::Spec.new do |s|
  s.name         = "THContactPicker"
  s.version      = "1.1.4"
  s.summary      = "THContactPicker is an iOS view used for selecting contacts."
  s.homepage     = "https://github.com/xtturing/THContactPicker/"
  s.license      = "MIT"
  s.author       = { "xtturing" => "xtturing@gmail.com" }
  
  s.platform     = :ios

  s.source       = { :git => "https://github.com/xtturing/THContactPicker.git" ,:tag => s.version}

  s.source_files  = "ContactPicker", "ContactPicker/*.{h,m}"
 
  s.frameworks = "QuartzCore", "UIKit", "Foundation", "CoreGraphics"
  s.requires_arc = true

end
