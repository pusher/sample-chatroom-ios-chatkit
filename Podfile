source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

# Replace `<Your Target Name>` with your app's target name.
target 'words' do
  pod 'Alamofire'
  pod 'PusherChatkit'
  # pod 'MessageKit', '~> 0.12.0'
  pod 'MessageKit', :git => 'git@github.com:MessageKit/MessageKit.git', :branch => 'master'


  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'MessageKit'
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.0'
              end
          end
      end
  end
end

