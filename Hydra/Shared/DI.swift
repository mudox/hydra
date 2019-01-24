import Swinject
import SwinjectAutoregistration

import GitHub
import MudoxKit

import Then

import JacKit

private let jack = Jack().set(format: .short)

extension Container: Then {}

// swiftlint:disable:next identifier_name
let di = Container().then {
  registerGitHubService(to: $0)
  registerLoginServiceType(to: $0)
  registerCredentialServiceType(to: $0)
  registerTrendServiceType(to: $0)
  registerLanguagesServiceType(to: $0)
  registerLanguagesModelType(to: $0)
}

private func registerCredentialServiceType(to container: Container) {
  if Environs.stubCredentialService {
    jack.verbose("🐡 CredentialServiceType", format: .bare)
    container.autoregister(
      CredentialServiceType.self,
      initializer: CredentialServiceStub.init
    )
  } else {
    container.autoregister(
      CredentialServiceType.self,
      initializer: CredentialService.init
    )
  }
}

private func registerGitHubService(to container: Container) {
  container.autoregister(
    GitHub.Service.self,
    initializer: GitHub.Service.init
  )
}

private func registerLoginServiceType(to container: Container) {
  container.autoregister(
    LoginServiceType.self,
    initializer: LoginService.init
  )
}

private func registerTrendServiceType(to container: Container) {
  if Environs.stubTrendService {
    jack.verbose("🐡 TrendServiceType", format: .bare)
    container.autoregister(
      TrendServiceType.self,
      initializer: TrendServiceStub.init
    )
  } else {
    container.autoregister(
      TrendServiceType.self,
      initializer: TrendService.init
    )
  }
}

private func registerLanguagesServiceType(to container: Container) {
  container.autoregister(
    LanguagesServiceType.self,
    initializer: LanguagesService.init
  )
}

private func registerLanguagesModelType(to container: Container) {
  container.autoregister(
    LanguagesModelType.self,
    initializer: LanguagesModel.init
  )
}
