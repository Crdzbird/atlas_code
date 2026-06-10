#
# CocoaPods fallback for apps that have Swift Package Manager disabled.
# The primary integration is the Swift Package in atlas_code_macos/.
#
Pod::Spec.new do |s|
  s.name             = 'atlas_code_macos'
  s.version          = '0.1.0'
  s.summary          = 'macOS implementation of the atlas_code plugin.'
  s.description      = <<-DESC
  macOS implementation of the atlas_code plugin: OS-localized country names
  for ISO 3166-1 regions.
                       DESC
  s.homepage         = 'https://pub.dev/packages/atlas_code'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Devotion' => 'luisalfonsocb83@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'atlas_code_macos/Sources/atlas_code_macos/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.platform = :osx
  s.osx.deployment_target = '10.15'
  s.swift_version = '6.1'
end
