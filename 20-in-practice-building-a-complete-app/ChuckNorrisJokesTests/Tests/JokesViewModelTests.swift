/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
import Combine
import SwiftUI
@testable import ChuckNorrisJokesModel

final class JokesViewModelTests: XCTestCase {
    private lazy var testJoke = self.testJoke(forResource: "TestJoke")
    private lazy var testTranslatedJokeValue = self.testJoke(forResource: "TestTranslatedJoke").value.value
    private lazy var error = URLError(.badServerResponse)
    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions = []
    }

    private func testJoke(forResource resource: String) -> (data: Data, value: Joke) {
        let bundle = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: resource, withExtension: "json"),
              let  data = try? Data(contentsOf: url),
              let joke = try? JSONDecoder().decode(Joke.self, from: data)
        else { fatalError("Failed to load \(resource)") }

        return (data, joke)
    }
    
    private func viewModel(withJokeError jokeError: Bool = false) -> JokesViewModel {
        let error = jokeError ? error : nil
        let service = MockJokesService(data: testJoke.data, error: error)
        return JokesViewModel(jokesService: service)
    }

    private func sampleJokeData() -> Data {
        guard
            let url = Bundle.main.url(forResource: "SampleJoke", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("SampleJoke file missing or data is corrupted")
        }
        return data
    }

    func test_createJokesWithSampleJokeData() {
        // Given
        let data = sampleJokeData()
        let sampleJoke: Joke

        // When
        do {
            sampleJoke = try JSONDecoder().decode(Joke.self, from: data)
        } catch {
            return XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssert(sampleJoke.categories.count == 1, "Sample joke categories.count was expected to be 1 but was \(sampleJoke.categories.count)")
        XCTAssert(sampleJoke.value == "Chuck Norris writes code that optimizes itself.", "First sample joke was expected to be \"Chuck Norris writes code that optimizes itself.\" but was \"\(sampleJoke.value)\"")
    }

    func test_backgroundColorFor50TranslationPercentIsGreen() {
        // Given
        let viewModel = viewModel()
        let expected = Color("Green")
        var actual: Color?
        let translation = 0.5

        viewModel.$backgroundColor
            .sink(receiveValue: {
                actual = $0
            })
            .store(in: &subscriptions)

        // When
        viewModel.updateBackgroundColorForTranslation(translation)

        // Then
        XCTAssertEqual(actual, expected)
    }

    func test_decisionStateFor60TranslationPercentIsLiked() {
        // Given
        let viewModel = viewModel()
        let expected = JokesViewModel.DecisionState.liked
        var actual: JokesViewModel.DecisionState?
        let translationPercent = 0.6
        let bounds = CGRect(x: 0, y: 0, width: 414, height: 896)
        let x = bounds.width

        viewModel.$decisionState
            .sink(receiveValue: {
                actual = $0
            })
            .store(in: &subscriptions)

        // When
        viewModel.updateDecisionStateForTranslation(
            translationPercent,
            andPredictedEndLocationX: x,
            inBounds: bounds
        )

        // Then
        XCTAssertEqual(actual, expected)
    }

    func test_decisionStateFor59TranslationPercentIsUndecided() {
        // Given
        let viewModel = viewModel()
        let expected = JokesViewModel.DecisionState.undecided
        var actual: JokesViewModel.DecisionState?
        let translationPercent = 0.59
        let bounds = CGRect(x: 0, y: 0, width: 414, height: 896)
        let x = bounds.width

        viewModel.$decisionState
            .sink(receiveValue: {
                actual = $0
            })
            .store(in: &subscriptions)

        // When
        viewModel.updateDecisionStateForTranslation(
            translationPercent,
            andPredictedEndLocationX: x,
            inBounds: bounds
        )

        // Then
        XCTAssertEqual(actual, expected)
    }

    func test_fetchJokeSucceeds() {
        // Given
        let expectation = self.expectation(description: #function)
        let viewModel = viewModel()
        let expected = testJoke.value
        var actual: Joke?

        viewModel.$joke
            .dropFirst()
            .sink(receiveValue: {
                actual = $0
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        // When
        viewModel.fetchJoke()

        // Then
        waitForExpectations(timeout: 2.0, handler: nil)
        XCTAssertEqual(actual, expected)
    }

    func test_fetchJokeReceivesErrorJoke() {
        // Given
        let expectation = self.expectation(description: #function)
        let viewModel = viewModel(withJokeError: true)
        let expected = Joke.error
        var actual: Joke?

        viewModel.$joke
            .dropFirst()
            .sink(receiveValue: {
                actual = $0
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        // When
        viewModel.fetchJoke()

        // Then
        waitForExpectations(timeout: 2.0, handler: nil)
        XCTAssertEqual(actual, expected)
    }
}
