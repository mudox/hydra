import XCTest

import Nimble
import Quick

@testable import Hydra

class GitHubSpec: QuickSpec { override func spec() {

  // MARK: GitHub.Pagination

  describe("Pagination") {

    it("repsents first page") {
      // arrange
      let text = """
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=2>; rel="next", \
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=34>; rel="last"
      """

      // act
      let p = GitHub.Pagination(from: ["Link": text])

      // assert
      expect(p).toNot(beNil())
      expect(p!.pageIndex) == 0
      expect(p!.totalCount) == 34
    }

    it("repsents middle page") {
      // arrange
      let text = """
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=1>; rel="prev", \
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=3>; rel="next", \
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=34>; rel="last", \
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=1>; rel="first"
      """

      // act
      let p = GitHub.Pagination(from: ["Link": text])

      // assert
      expect(p).toNot(beNil())
      expect(p!.pageIndex) == 2
      expect(p!.totalCount) == 34
    }

    it("repsents last page") {
      // arrange
      let text = """
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=33>; rel="prev", \
      <https://api.github.com/search/repositories?q=neovim&sort=stars&order=desc&page=1>; rel="first"
      """

      // act
      let p = GitHub.Pagination(from: ["Link": text])

      // assert
      expect(p).toNot(beNil())
      expect(p!.pageIndex) == 34
      expect(p!.totalCount) == 34
    }

  }

  // MARK: GitHub.RateLimit

  describe("RateLimit") {

    it("init from response header fields") {
      // arrange
      let headers = [
        "X-RateLimit-Limit": "30",
        "X-RateLimit-Reset": "1536306663",
        "X-RateLimit-Remaining": "29",
      ]

      // act
      // assert
      let rateLimit = GitHub.RateLimit(from: headers)
      expect(rateLimit).toNot(beNil())
      dump(rateLimit!)
    }

  }

} }
