Pod::Spec.new do |s|
  s.name             = 'DatadogCrashes'
  s.version          = '0.1.0'
  s.summary          = 'A short description of DatadogCrashes.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Maciek Grzybowski/DatadogCrashes'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Maciek Grzybowski' => 'maciek.grzybowski@datadoghq.com' }
  s.source = { :git => 'https://github.com/DataDog/dd-sdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.source_files = 'DatadogCrashes/DatadogCrashes/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.static_framework = true
  s.dependency 'PLCrashReporter', '~> 1.4'
  s.dependency 'DatadogObjc'
end