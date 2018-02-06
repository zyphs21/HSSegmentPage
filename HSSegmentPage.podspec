Pod::Spec.new do |s|
  s.name             = 'HSSegmentPage'
  s.version          = '0.1.1'
  s.swift_version    = '4.0'
  s.summary          = 'HSSegmentPage, provide customizable segment menu and segment pageview'
  s.homepage         = 'https://github.com/zyphs21/HSSegmentPage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zyphs21' => 'hansenhs21@live.com' }
  s.source           = { :git => 'https://github.com/zyphs21/HSSegmentPage.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'HSSegmentPage/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HSSegmentPage' => ['HSSegmentPage/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
