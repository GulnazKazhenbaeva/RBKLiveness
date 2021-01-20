
Pod::Spec.new do |s|

s.name         = "RBKLiveness"
s.version      = "1.0.0"
s.summary      = "RBKLiveness is a camera that can test a person's reality."
s.description  = "The RBKLiveness is a completely customizable widget that can be used in any iOS app."
s.homepage     = "https://www.bankrbk.kz/"
s.license      = "MIT"
s.platform     = :ios, "10.0"
s.resource_bundles  = {
	'RBKLiveness' => ['Resources/*.png']
}
# s.source       = { :path => '{./RBKLiveness.zip}' }
s.source       = { :git => 'https://github.com/GulnazKazhenbaeva/RBKLiveness', :tag => "#{s.version}"}
s.source_files = 'RBKLiveness/**/*.{swift}'
s.resources = "RBKLiveness/**/*.{png,jpeg,jpg}"
# s.static_framework = true
s.dependency 'GoogleMLKit/FaceDetection'

s.ios.vendored_frameworks = 'RBKLiveness.framework'
s.frameworks = 'UIKit', 'AVFoundation', 'CoreVideo'

s.swift_version = "4.2" 
s.author = { "Gulnaz Kazhenbayeva" => "gulnaz.kazh@gmail.com" }
# s.exclude_files = [ 'RBKLiveness/Sources/**', 'RBKLiveness/Resources/**']
end
