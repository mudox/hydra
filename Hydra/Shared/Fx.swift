import Swinject
import SwinjectAutoregistration

import Then

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

extension Container: Then {}

// MARK: - The Singleton Container

// swiftlint:disable:next identifier_name
let fx = Container().then {
  registerGitHubService(to: $0)
  registerLoginServiceType(to: $0)
  registerCredentialServiceType(to: $0)
  registerTrendServiceType(to: $0)
  registerLanguagesServiceType(to: $0)
  registerLanguagesModelType(to: $0)
}

// MARK: - Shared

private func registerCredentialServiceType(to container: Container) {
  if Environs.stubCredentialService {
    logStub("CredentialServiceType")
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

// MARK: - Login

private func registerLoginServiceType(to container: Container) {
  container.autoregister(
    LoginServiceType.self,
    initializer: LoginService.init
  )
}

// MARK: - Trend

private func registerTrendServiceType(to container: Container) {
  if Environs.stubTrendService {
    logStub("TrendService")
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

// MARK: - Languages

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

// MARK: - Helper

private func logStub(_ name: String) {
  jack.verbose("🐡 \(name)", format: .bare)
}
