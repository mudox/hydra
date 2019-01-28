#if DEBUG

  import RxSwift

  import GitHub
  import JacKit
  import MudoxKit

  private let jack = Jack().set(format: .short)

  class LanguagesServiceStub: LanguagesServiceType {

    struct StubError: Swift.Error, Equatable {
      static func == (_ lhs: StubError, _ rhs: StubError) -> Bool {
        return true
      }
    }

    static let error = StubError()

    let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

    // MARK: - History

    static let fixedHistory = ["History"]
    var history = fixedHistory

    func addSelected(_ language: String) {
      jack.func().warn("Empty stub method")
    }

    // MARK: - Pinned

    static let fixedPinned = ["Pinned"]
    var pinned = fixedPinned

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

    static let fixedOther = ["Other1", "Other2", "Other3"]

    static let allItems = fixedOther.map {
      GitHub.Language(name: $0, colorString: "#fff")
    }

    var all: Single<[GitHub.Language]> {
      let stubOption = Environs.stubLanguagesService!.lowercased()
      let delay = Environs.stubDelay ?? 3

      let items = type(of: self).allItems

      switch stubOption {
      case "value":
        return Single.just(items)
          .delay(delay, scheduler: MainScheduler.instance)
      case "error":
        return Single.error(Errors.error("Test fake error"))
          .delaySubscription(delay, scheduler: scheduler)

      default:
        fatalError("Invalid stub option: \(stubOption)")
      }
    }

    // MARK: - Seaerch

    static let searchResult = LanguagesService.SearchResult(
      history: fixedHistory,
      pinned: fixedPinned,
      other: fixedOther
    )

    func search(text: String) -> Single<LanguagesService.SearchResult> {
      let stubOption = Environs.stubLanguagesService!.lowercased()
      let delay = Environs.stubDelay ?? 3

      let result = type(of: self).searchResult

      switch stubOption {
      case "value":
        return Single.just(result)
          .delay(delay, scheduler: scheduler)
      case "error":
        return Single.error(LanguagesServiceStub.error)
          .delaySubscription(delay, scheduler: scheduler)
      default:
        fatalError("Invalid stub option: \(stubOption)")
      }
    }

  }

#endif
