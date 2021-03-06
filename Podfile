# vim: fdm=marker

# My Pods {{{1
def my_pods
  # Travis-CI set `CI` on macOS environment
  if ENV['CI'] == 'true'
    pod 'JacKit',                     :git  => 'https://github.com/mudox/jac-kit.git'
    pod 'JacKit',                     :git  => 'https://github.com/mudox/jac-kit.git'

    pod 'MudoxKit',                   :git  => 'https://github.com/mudox/mudox-kit.git'
    pod 'MudoxKit/MBProgressHUD',     :git  => 'https://github.com/mudox/mudox-kit.git'
    pod 'MudoxKit/ActivityCenter',    :git  => 'https://github.com/mudox/mudox-kit.git'

    #pod 'SocialKit',                  :git  => 'https://github.com/mudox/social-kit.git'

    pod 'GitHubKit',                  :git  => 'https://github.com/mudox/github-kit.git'
  else
    basePath      = '/Users/mudox/Develop/Apple/Frameworks/'

    pod 'JacKit',                     path: basePath + 'JacKit'

    pod 'MudoxKit',                   path: basePath + 'MudoxKit'
    pod 'MudoxKit/MBProgressHUD',     path: basePath + 'MudoxKit'
    pod 'MudoxKit/ActivityCenter',    path: basePath + 'MudoxKit'

    #pod 'SocialKit',                  path: basePath + 'SocialKit'

    pod 'GitHubKit',                  path: basePath + 'GitHubKit'
  end

end

# }}}

# RxSwift {{{

def rx_pods
  # Base frameworks
  pod 'RxSwift'
  pod 'RxCocoa'

  # Common advanced extensions
  pod 'Action'
  pod 'RxSwiftExt'
  pod 'RxOptional'

  # Data binding
  pod 'RxDataSources'

  # Event handling
  pod 'RxKeyboard'
  pod 'RxGesture'

  # UI
  # pod 'RxAnimated'
  # pod 'RxTheme'

  # other
  # pod 'RxBluetoothKit'
end

# }}}

# Data {{{1

def data_pods
  pod 'SwiftyUserDefaults', '4.0.0-alpha.1'
  pod 'Cache'
  pod 'Valet' # Keychain
end

def realm_pods
  pod 'RealmSwift'
  pod 'RxRealm'
  pod 'RxRealmDataSources'
end

# }}}

# Testing {{{1

def swinject_pods
  pod 'Swinject'
  pod 'SwinjectAutoregistration'
end

def quick_pods
  pod 'Quick'
  pod 'Nimble'
end

def rxtest_pods
  pod 'RxTest'
  pod 'RxBlocking'
  pod 'RxNimble'
end

def network_testing_pods
  pod 'OHHTTPStubs'
end

# }}}

# Other {{{1

def networking_pods
  # pod 'Alamofire'
  # pod 'RxAlamofire'

  #pod 'Moya/RxSwift'

  pod 'Kingfisher'
end

def ui_pods
  # pod 'IQKeyboardManagerSwift'
  # pod 'SwiftRichString'

  pod 'iCarousel'

  # pod 'Texture'
  pod 'SnapKit'

  pod 'NVActivityIndicatorView'
  pod 'SwiftHEXColors'

  pod "SkeletonView"

  pod 'Hero'
end

def swift_pods
  pod 'Then'
end

def utility_pods
  pod 'SwiftLint'
end

# }}}

# Install pods {{{1

platform :ios, '10.0'
use_frameworks!

inhibit_all_warnings!

target 'Hydra' do
  utility_pods

  my_pods

  swift_pods
  rx_pods

  swinject_pods

  ui_pods

  data_pods
  realm_pods

  networking_pods

  target 'UnitTest' do
    use_frameworks!
    inherit! :search_paths

    quick_pods
    rxtest_pods
  end

  target 'EarlGreyTest' do
    inherit! :search_paths

    pod 'EarlGrey'

    quick_pods
  end

  target 'UITest' do
    inherit! :search_paths
  end

end

# Suppress warning of Valet, SwiftyUserDefualts
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Needed until CocoaPods supports multiple Swift versions
      # https://github.com/CocoaPods/CocoaPods/issues/8191
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end
# }}}
