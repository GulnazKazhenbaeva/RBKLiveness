
Pod::Spec.new do |s|

s.name         = "RBKLiveness"
s.version      = "1.0.0"
s.summary      = "RBKLiveness is a camera that can test a person's reality."
s.description  = "The RBKLiveness is a completely customizable widget that can be used in any iOS app."
s.homepage     = "https://www.bankrbk.kz/"
s.license      = "MIT"
s.platform     = :ios, "12.0"
s.source       = { :git => 'https://gulnazKazhenbaeva@bitbucket.org/rbk_dev_team/rbkliveness.git', , :tag => "#{s.version}"}
s.source_files = 'RBKLiveness/**/*.{swift}'
s.resources = "RBKLiveness/**/*.{png,jpeg,jpg,xcassets}"
s.static_framework = true
s.dependency 'GoogleMLKit/FaceDetection'

s.vendored_frameworks = 'nanopb.framework', 'MLKit', 'RBKLiveness.framework'
s.frameworks = 'UIKit', 'AVFoundation', 'CoreVideo'

s.swift_version = "4.2" 
s.author = { "Gulnaz Kazhenbayeva" => "gulnaz.kazh@gmail.com" }

end
