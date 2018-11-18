# Uncomment the next line to define a global platform for your project
use_frameworks!
platform :ios, '12.0'

pod 'KeychainAccess'
pod 'IQKeyboardManagerSwift', '6.0.4'
pod 'SkyFloatingLabelTextField', '~> 3.0'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end

target 'Parking Space Booking System' do
end
