def my_pods
  basePath      = '/Users/mudox/Develop/Apple/Frameworks/'
  mudoxKitPath  = basePath + 'MudoxKit/'
  socialKitPath = basePath + 'SocialKit/'
  jacKitPath    = basePath + 'JacKit/'
  githubKitPath = basePath + 'GitHubKit/'

  # JacKit    - Logging framwork
  pod 'JacKit',                     path: jacKitPath

  # MudoxKit  - Personal developing utility library
  pod 'MudoxKit',                   path: mudoxKitPath
  pod 'MudoxKit/MBProgressHUD',     path: mudoxKitPath
  pod 'MudoxKit/ActivityCenter',    path: mudoxKitPath

  # SocialKit - Social platform integration
  pod 'SocialKit',                  path: socialKitPath

  # GitHub API v3 Swift Interface
  pod 'GitHubKit',                  path: githubKitPath
end

def rx_pods
  # Base frameworks
  pod 'RxSwift'
  pod 'RxCocoa'

  # Common advanced extensions
  #pod 'Action'
  #pod 'RxSwiftExt', git: 'https://github.com/RxSwiftCommunity/RxSwiftExt.git', tag: '3.3.0'
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

target 'Hydra' do
  my_pods
  rx_pods
  data_pods
  ui_pods
  networking_pods
  swift_pods

  #target 'HydraTests' do
    #inherit! :search_paths

    #testing_pods

    #basePath      = '/Users/mudox/Develop/Apple/Frameworks/'
    #socialKitPath = basePath + 'SocialKit/'
    #pod 'SocialKit', path: socialKitPath
  #end
end
