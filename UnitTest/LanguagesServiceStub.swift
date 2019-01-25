import RxSwift

import GitHub

@testable import Hydra

import JacKit

private let jack = Jack().set(format: .short)

class LanguagesServiceStub: LanguagesServiceType {

  // MARK: - History

  let history = ["Select"]

  func addSelected(_ language: String) {
    jack.func().warn("Empty stub method")
  }

  // MARK: - Pinned

  let pinned = ["Pinned"]

  func addPinned(_ language: String) {
    jack.func().warn("Empty stub method")
  }

  func movePinned(from src: Int, to dest: Int) {
    jack.func().warn("Empty stub method")
  }

  func removePinned(_ language: String) {
    jack.func().warn("Empty stub method")
  }

  // MARK: - All

  let all = Single<[GitHub.Language]>.just([
    GitHub.Language(name: "Select", colorString: "#333"),
    GitHub.Language(name: "Pinned", colorString: "#222"),
  ])

  // MARK: - Seaerch

  func search(text: String) -> Single<[LanguagesModel.Section]> {
    return .just([
      .init(title: "History", items: [
        "Select"
      ]),
      .init(title: "Pinned", items: [
        "Pinned"
      ]),
      .init(title: "Languages", items: [
        "Select", "Pinned"
      ]),
    ])
  }

}
