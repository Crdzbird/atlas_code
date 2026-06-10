#
# CocoaPods fallback for apps that have Swift Package Manager disabled.
# The primary integration is the Swift Package in atlas_code_ios/.
#
Pod::Spec.new do |s|
  s.name             = 'atlas_code_ios'
  s.version          = '0.1.0'
  s.summary          = 'iOS implementation of the atlas_code plugin.'
  s.description      = <<-DESC
  iOS implementation of the atlas_code plugin: OS-localized country names
  for ISO 3166-1 regions.
                       DESC
  s.homepage         = 'https://pub.dev/packages/atlas_code'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Devotion' => 'luisalfonsocb83@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'atlas_code_ios/Sources/atlas_code_ios/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '6.1'
end
