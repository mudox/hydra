def my_pods
  # Travis-CI set `CI` on macOS environment
  if ENV['CI'] == 'true'
    pod 'JacKit',  :git  => 'https://github.com/mudox/jac-kit.git'
    pod 'JacKit',                     :git  => 'https://github.com/mudox/jac-kit.git'

    pod 'MudoxKit',                   :git  => 'https://github.com/mudox/mudox-kit.git'
    pod 'MudoxKit/MBProgressHUD',     :git  => 'https://github.com/mudox/mudox-kit.git'
    pod 'MudoxKit/ActivityCenter',    :git  => 'https://github.com/mudox/mudox-kit.git'

    pod 'SocialKit',                  :git  => 'https://github.com/mudox/social-kit.git'

    pod 'GitHubKit',                  :git  => 'https://github.com/mudox/github-kit.git'
  else
    basePath      = '/Users/mudox/Develop/Apple/Frameworks/'

    pod 'JacKit',                     path: basePath + 'JacKit'

    pod 'MudoxKit',                   path: basePath + 'MudoxKit'
    pod 'MudoxKit/MBProgressHUD',     path: basePath + 'MudoxKit'
    pod 'MudoxKit/ActivityCenter',    path: basePath + 'MudoxKit'

    pod 'SocialKit',                  path: basePath + 'SocialKit'

    pod 'GitHubKit',                  path: basePath + 'GitHubKit'
  end

end

def rx_pods
  # Base frameworks
  pod 'RxSwift'
  pod 'RxCocoa'

  # Common advanced extensions
  pod 'Action'
  pod 'RxSwiftExt'

  # Data binding
  pod 'RxDataSources'

  # Event handling
  # pod 'RxKeyboard'
  # pod 'RxGesture'

  # UI
  # pod 'RxAnimated'
  # pod 'RxTheme'

  # other
  # pod 'RxBluetoothKit'
end

def realm_pods
  pod 'RealmSwift'
  pod 'RxRealm'
  pod 'RxRealmDataSources'
end

def di_pods
  # pod 'Swinject'
  # pod 'SwinjectStoryboard'
  # pod 'SwinjectAutoregistration'
end

def testing_pods
  # BDD
  pod 'Quick'
  pod 'Nimble'

  # Testing RxSwift code
  pod 'RxTest'
  pod 'RxBlocking'
  pod 'RxNimble'

  # Requests stubbing
  pod 'OHHTTPStubs'
end

def networking_pods
  # pod 'Alamofire'
  # pod 'RxAlamofire'

  pod 'Moya/RxSwift'

  # pod 'Kingfisher'
end

def ui_pods
  # pod 'iCarousel'
  # pod 'Eureka'
  # pod 'IQKeyboardManagerSwift'
  # pod 'SwiftRichString'
end

def swift_pods
  pod 'Then'

  pod 'SwiftLint'
end

def data_pods
  pod 'SwiftyUserDefaults', '4.0.0-alpha.1'
end

#################################################
#  ----------------- Podfile -----------------  #
#################################################

platform :ios, '10.0'
use_frameworks!

inhibit_all_warnings!

target 'Hydra' do
  my_pods
  rx_pods
  data_pods
  ui_pods
  networking_pods
  swift_pods

  target 'Test' do
    inherit! :search_paths

    testing_pods
  end
end
