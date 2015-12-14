source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!

platform :ios, '8.0'

target 'LocationPicker' do
    
#    pod 'Utils', :git => 'https://github.com/levantAJ/Utils.git', :commit => 'de47a1dc0424e67a82d80724e24797c0347901ee'
    pod 'Utils', :path => '../Utils'
    pod 'Observable', :git => 'https://github.com/levantAJ/Observable.git', :commit => '02b5b0f6cd52164e1f19709056d5d01f2ad7c5b9'
    
    #Open source
    
    pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :commit=> '39e5ecb98c8cab9b258d87fdbe33d7cfe7765326'
    pod 'ObjectMapper', :git => 'https://github.com/Hearst-DD/ObjectMapper.git', :commit => 'c9b53ad38a17847d2f68baf4e0ef76a0bfea476d'
    pod 'Realm'
    pod 'RealmSwift'
end

target 'LocationPickerTests' do
    
end


post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end