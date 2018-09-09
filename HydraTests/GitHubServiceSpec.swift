import XCTest

import Nimble
import Quick

import JacKit
fileprivate let jack = Jack()

@testable import Hydra

class GitHubServiceSpec: QuickSpec { override func spec() {

  // MARK: Search

  let timeout: TimeInterval = 5

  beforeEach {
    Jack.formattingOptions = [.noLocation]
  }

  describe("Service") {

    it("search") {
      // Arrange
      let jack = Jack("GitHub.Service.search")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHub.Service.shared.searchRepository("neovim").subscribe(
          onSuccess: { response in
            var text: String = ""
            dump(response.pagination, to: &text, indent: 2)
            dump(response.rateLimit, to: &text, indent: 2)

            jack.info("""
            Found \(response.payload.items.count) results
            \(text)
            """)

            done()
          },
          onError: { error in
            var text = ""
            dump(error, to: &text, indent: 2)
            jack.error(text)
            fatalError()
          }
        )
      }
    }

    it("currentUser") {
      // Arrange
      let jack = Jack("GitHub.Service.currentUser")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHub.Service.shared.currentUser().subscribe(
          onSuccess: { response in
            var text: String = ""
            dump(response.rateLimit, to: &text, indent: 2)

            jack.info("""
            Username: \(response.payload.name)
            \(text)
            """)

            done()
          },
          onError: { error in
            var text = ""
            dump(error, to: &text, indent: 2)
            jack.error(text)
            fatalError()
          }
        )
      }
    }

    it("user") {
      // Arrange
      let jack = Jack("GitHub.Service.user")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHub.Service.shared.user(name: "mudox").subscribe(
          onSuccess: { response in
            var text: String = ""
            dump(response.rateLimit, to: &text, indent: 2)

            jack.info("""
            Username: \(response.payload.name)
            \(text)
            """)

            done()
          },
          onError: { error in
            var text = ""
            dump(error, to: &text, indent: 2)
            jack.error(text)
            fatalError()
          }
        )
      }
    }

    it("zen") {
      // Arrange
      let jack = Jack("GitHub.Service.user")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHub.Service.shared.zen().subscribe(
          onSuccess: { zen in
            jack.info("GitHub Zen: \(zen)")
            done()
          },
          onError: { error in
            var text = ""
            dump(error, to: &text, indent: 2)
            jack.error(text)
            fatalError()
          }
        )
      }
    }

    it("rateLimit") {
      // Arrange
      let jack = Jack("GitHub.Service.rateLimit")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHub.Service.shared.rateLimit().subscribe(
          onSuccess: { rateLimit in
            jack.info(Jack.dump(of: rateLimit))
            done()
          },
          onError: { error in
            var text = ""
            dump(error, to: &text, indent: 2)
            jack.error(text)
            fatalError()
          }
        )
      }
    }

    fit("authorize") {
      // Arrange
      let jack = Jack("GitHub.Service.authorize")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHub.Service.shared.authorize().subscribe(
          onSuccess: { response in
            jack.info("""
            \(response.statusDescription)
            \(Jack.dump(of: response.payload))
            """)
            done()
          },
          onError: { error in
            jack.error("""
            \(Jack.dump(of: error))
            """)
            fatalError()
          }
        )
      }
    }
  }

} }
