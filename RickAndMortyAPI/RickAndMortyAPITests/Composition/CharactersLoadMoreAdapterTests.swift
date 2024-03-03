import XCTest
@testable import RickAndMortyAPI

final class CharactersLoadMoreAdapterTests: XCTestCase {

    func test_showLoadMoreCell_requestLoadMoreCorrectly() {
        let loader = LoaderSpy()
        let viewController = CharactersViewController()
        let sut = CharactersLoadMoreAdapter(characterLoader: loader.loadMorePublisher(page:))

        sut.showLoadMoreCell(viewController)
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected a load more request")

        sut.showLoadMoreCell(viewController)
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request until previous completes")

        loader.completeLoadMoreCharacters(at: 0)
        sut.showLoadMoreCell(viewController)
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected another load more request once previous request finishes")
    }

    func test_showLoadMoreCell_requestCorrectPageNumber() {
        let loader = LoaderSpy()
        let viewController = CharactersViewController()
        let sut = CharactersLoadMoreAdapter(characterLoader: loader.loadMorePublisher(page:))

        viewController.display(make20Characters())
        sut.showLoadMoreCell(viewController)
        loader.completeLoadMoreCharacters()
        XCTAssertEqual(loader.currentPage, 2)

        viewController.display(make20Characters() + make20Characters())
        sut.showLoadMoreCell(viewController)
        XCTAssertEqual(loader.currentPage, 3)
    }

    func test_showLoadMoreCellWithError_deliverError() {
        let loader = LoaderSpy()
        let viewController = CharactersViewController()
        let sut = CharactersLoadMoreAdapter(characterLoader: loader.loadMorePublisher(page:))

        sut.showLoadMoreCell(viewController)
        loader.completeLoadMoreWithError()

        XCTAssertEqual((viewController.tableView.tableFooterView as? LoadMoreCell)?.message, "Couldn't connect to server")
    }

    func test_showLoadMoreCell_deliversResult() {
        let loader = LoaderSpy()
        let sut = CharactersLoadMoreAdapter(characterLoader: loader.loadMorePublisher(page:))
        let viewController = CharactersViewController()
        let view = ViewSpy()
        let presenter = CharactersPresenter(charactersView: view, loadingView: view, errorView: view)
        sut.presenter = presenter

        sut.showLoadMoreCell(viewController)
        loader.completeLoadMoreCharacters(with: [])

        XCTAssertEqual(view.messages, [.display(characters: []), .display(isLoading: false)])
    }


    // MARK: - Helpers

    private func make20Characters() -> [CharacterCellController] {
        var characters = [CharacterCellController]()

        for _ in 1...20 {
            characters.append(makeCharacterCellController())
        }

        return characters
    }

    private func makeCharacterCellController() -> CharacterCellController {
        CharacterCellController(delegate: CharacterCellControllerDelegateSpy())
    }

    private class CharacterCellControllerDelegateSpy: CharacterCellControllerDelegate {
        enum Message {
            case didRequestImage
            case didCancelImageRequest
        }

        var messages: [Message] = []

        func didRequestImage() {
            messages.append(.didRequestImage)
        }

        func didCancelImageRequest() {
            messages.append(.didCancelImageRequest)
        }
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
