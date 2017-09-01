# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'Pigeon' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Pigeon
  pod 'Firebase'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'OneSignal', '>= 2.5.2', '< 3.0'
  pod 'CocoaLumberjack/Swift', :git => 'https://github.com/CocoaLumberjack/CocoaLumberjack', :branch => 'master'

  target 'PigeonTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PigeonUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'OneSignalNotificationServiceExtension' do
  use_frameworks!

  pod 'OneSignal', '>= 2.5.2', '< 3.0'
end
