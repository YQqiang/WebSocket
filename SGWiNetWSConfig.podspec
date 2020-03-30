#
# Be sure to run `pod lib lint SGWiNetWSConfig.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SGWiNetWSConfig'
  s.version          = '0.0.2'
  s.summary          = 'SGWiNetWSConfig'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SG WiNet Web Socket Config
                       DESC

  s.homepage         = 'https://github.com/YQqiang/WebSocket'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1054572107@qq.com' => '1054572107@qq.com' }
  s.source           = { :git => 'https://github.com/YQqiang/WebSocket.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SGWiNetWSConfig/Classes/**/*'

  # s.resource_bundles = {
  #   'SGWiNetWSConfig' => ['SGWiNetWSConfig/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
#  s.dependency 'CocoaAsyncSocket'
  s.dependency 'SocketRocket'
end
