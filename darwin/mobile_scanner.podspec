#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint awesome_mobile_scanner.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'awesome_mobile_scanner'
  s.version          = '0.0.1'
  s.summary          = 'An universal scanner for Flutter based on the Vision API.'
  s.description      = <<-DESC
An universal scanner for Flutter based on the Vision API.
                       DESC
  s.homepage         = 'https://github.com/akmaljonabdirakhimov/mobile_scanner'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Akmaljon Abdirakhimov' => 'akmaljonabdirakhimov@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'mobile_scanner/Sources/mobile_scanner/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.resource_bundles = {'awesome_mobile_scanner_privacy' => ['mobile_scanner/Sources/mobile_scanner/Resources/PrivacyInfo.xcprivacy']}
end
