#if DEBUG

  import RxSwift

  import GitHub
  import JacKit
  import MudoxKit

  private let jack = Jack().set(format: .short)

  class LanguagesServiceStub: LanguagesServiceType {

    var stubOption = Environs.stubLanguagesService!.lowercased()

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

    var all: Single<[GitHub.Language]> {
      let items = [
        GitHub.Language(name: "Select", colorString: "#333"),
        GitHub.Language(name: "Pinned", colorString: "#222")
      ]

      switch stubOption {
      case "loading":
        return Single.just(items)
          .delay(3, scheduler: MainScheduler.instance)
      case "value":
        return .just(items)
      case "error":
        return .error(Errors.error("Test fake error"))
      default:
        fatalError("Invalid stub option: \(stubOption)")
      }
    }

    // MARK: - Seaerch

    func search(text: String) -> Single<LanguagesService.SearchResult> {
      let results = LanguagesService.SearchResult(
        history: ["Select"],
        pinned: ["Pinned"],
        other: ["Ohther1", "Other2", "Other3"]
      )

      switch stubOption {
      case "loading":
        return Single.just(results)
          .delay(3, scheduler: MainScheduler.instance)
      case "value":
        return Single.just(results)
      case "error":
        return Single.error(Errors.error("Test fake error"))
          .delaySubscription(3, scheduler: MainScheduler.instance)
      default:
        fatalError("Invalid stub option: \(stubOption)")
      }
    }

  }

#endif
