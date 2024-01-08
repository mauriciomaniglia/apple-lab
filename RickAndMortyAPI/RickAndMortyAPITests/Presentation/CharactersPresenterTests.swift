import XCTest
import RickAndMortyAPI

class CharactersPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(CharactersPresenter.title, "My Characters")
    }

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingCharacters_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingCharacters()

        XCTAssertEqual(view.messages, [
             .display(errorMessage: .none),
             .display(isLoading: true)
        ])
     }

    func test_didFinishLoadingCharacters_displaysCharactersAndStopsLoading() {
        let (sut, view) = makeSUT()
        let characters = uniqueCharacters().models

        sut.didFinishLoadingCharacters(with: characters)

        XCTAssertEqual(view.messages, [
            .display(characters: characters),
            .display(isLoading: false)
        ])
     }

    func test_didFinishLoadingCharactersWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingCharacters(with: anyNSError())

        XCTAssertEqual(view.messages, [
            .display(errorMessage: "Couldn't connect to server"),
            .display(isLoading: false)
        ])
     }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CharactersPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = CharactersPresenter(charactersView: view, loadingView: view, errorView: view)
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy: CharactersView, CharactersLoadingView, CharactersErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(characters: [Character])
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: CharactersErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }

        func display(_ viewModel: CharactersLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(_ characters: [Character]) {
            messages.append(.display(characters: characters))
        }
    }

}
