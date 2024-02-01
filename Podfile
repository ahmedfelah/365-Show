# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end


source 'https://cdn.cocoapods.org/'

target '365Show' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for SuperCell
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Auth'
  
  pod 'Alamofire', '~> 5.5'

  pod 'KeychainAccess'
  
  pod 'Parchment'
  pod 'Shimmer'
  pod 'RealmSwift'
  pod 'IQKeyboardManagerSwift'
  
  pod "Koloda"
  
  pod 'Kingfisher', '~> 7.0'
  pod 'Tabman'
  pod 'FSPagerView'
  pod 'SnapKit'
  pod 'SwiftyJSON'
  pod 'NVActivityIndicatorView'
  pod 'NFDownloadButton'
  pod 'DownloadButton'
  pod 'TBKNetworking'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'GoogleSignIn'
  pod 'google-cast-sdk'

#  pre_install do |installer|
#  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
#  end

#  pod 'ChiefsPlayer', git:'https://github.com/HusamAamer/ChiefsPlayer.git'#, :branch => 'master' ,:commit => '953d405'
end
