platform :ios, '8.0'
use_frameworks!

def ui
	pod 'TZImagePickerController', '~> 1.5', :inhibit_warnings => true
end

def wrapper
	pod 'RxSwift', '~> 3.4', :inhibit_warnings => true
	pod 'RxCocoa', '~> 3.4', :inhibit_warnings => true
   	 pod 'RxDataSources', :inhibit_warnings => true
end

target  "GalleryViewDemo"  do
	ui
	wrapper
end

post_install do |installer|
    puts 'Removing static analyzer support'
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['OTHER_CFLAGS'] = "$(inherited) -Qunused-arguments -Xanalyzer -analyzer-disable-all-checks"
        end
    end
end
