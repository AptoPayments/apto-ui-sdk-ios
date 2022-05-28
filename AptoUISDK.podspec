#
# Be sure to run `pod lib lint AptoUISDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AptoUISDK"
  s.version          = "3.20.0"
  s.summary          = "The Apto UI platform iOS SDK."
  s.description      = <<-DESC
                        Apto iOS UI SDK provides a UI flow that allows to easily integrate the platform in your app.
                       DESC
  s.homepage         = "https://github.com/AptoPayments/apto-ui-sdk-ios.git"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { "Apto Payments" => "mobile@aptopayments.com" }
  s.source           = { :git => "https://github.com/AptoPayments/apto-ui-sdk-ios.git", :tag => "3.20.0" }

  s.platform = :ios
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.requires_arc = true


  s.module_name = 'AptoUISDK'
  s.source_files = ['Pod/Classes/ui/**/*.swift']
  s.resources = ["Pod/Assets/*.png", "Pod/Assets/*.css", "Pod/Localization/*.lproj", "Pod/Assets/*.xcassets", "Pod/Fonts/*.ttf", "Pod/CHANGELOG_ui.md"]

  s.frameworks = 'UIKit', 'CoreLocation', 'Accelerate', 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'Foundation', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'Security', 'LocalAuthentication', 'CallKit'
  s.dependency 'AptoSDK', '3.20.0'
  s.dependency 'AptoPCI', '3.2.0'
  s.dependency 'SnapKit', '~> 5.0'
  s.dependency 'Bond', '~> 7.6'
  s.dependency 'GoogleKit', '~> 0.3'
  s.dependency 'PhoneNumberKit', '~> 3.3.3'
  s.dependency 'TTTAttributedLabel', '~> 2.0'
  s.dependency 'TrustKit', '~> 1.6.0'
  s.dependency 'Down', '~> 0.8.0'
  s.dependency 'PullToRefreshKit', '~> 0.8'
  s.dependency 'TwilioVoice', '~> 6.3.1'
end
