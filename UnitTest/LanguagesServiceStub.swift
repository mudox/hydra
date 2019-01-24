import RxSwift

import GitHub

@testable import Hydra

import JacKit

private let jack = Jack().set(format: .short)

class LanguagesServiceStub: LanguagesServiceType {

  func addPinned(_ language: String) {
    jack.func().warn("Empty stub method")
  }

  func movePinned(from src: Int, to dest: Int) {
    jack.func().warn("Empty stub method")
  }

  func removePinned(_ language: String) {
    jack.func().warn("Empty stub method")
  }

  let history = ["FAKE HISTORY ITEM"]

  func addSelected(_ language: String) {
    jack.func().warn("Empty stub method")
  }

  func search(text: String) -> Single<[LanguagesModel.Section]> {
    return .just([
      .init(title: "History", items: ["FAKE HISTORY ITEM"]),
      .init(title: "Pinned", items: ["FAKE PINNED ITEM"]),
      .init(title: "Languages", items: ["FAKE LANGUAGES ITEM"]),
    ])
  }

  let pinned = ["Pinned"]

  let all = Single<[GitHub.Language]>
    .just([
      GitHub.Language(name: "Select", colorString: "#333"),
      GitHub.Language(name: "Pinned", colorString: "#222"),
    ])
}
