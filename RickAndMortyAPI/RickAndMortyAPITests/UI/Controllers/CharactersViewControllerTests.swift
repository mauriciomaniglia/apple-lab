import XCTest
@testable import RickAndMortyAPI

class CharactersViewControllerTests: XCTestCase {

    func test_viewIsAppearing_requestCharacters() {
        let sut = makeSUT()
        var didRequestCharacters = false
        sut.didRequestCharactersRefresh = {
            didRequestCharacters = true
        }

        sut.viewIsAppearing(false)

        XCTAssertTrue(didRequestCharacters)
    }

    func test_viewIsAppearingTwice_requestCharactersOnlyOnce() {
        let sut = makeSUT()
        var charactersRequestCalls: [Bool] = []
        sut.didRequestCharactersRefresh = {
            charactersRequestCalls.append(true)
        }

        sut.viewIsAppearing(false)
        sut.viewIsAppearing(false)

        XCTAssertEqual(charactersRequestCalls, [true])
    }

    func test_displayError_showsErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "some error"))
        XCTAssertEqual(sut.errorView.message, "some error")

        sut.display(.noError)
        XCTAssertEqual(sut.errorView.message, nil)
    }

    func test_displayLoading_showsCorrectLoading() {
        let sut = makeSUT()
        sut.refreshControl = FakeUIRefreshControl()

        sut.display(.init(isLoading: true))
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)

        sut.display(.init(isLoading: false))
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }

    func test_numberOfRows_deliversCorrectValue() {
        let sut = makeSUT()
        let (controller0, _) = makeCharacterCellController()
        let (controller1, _) = makeCharacterCellController()

        sut.display([controller0, controller1])
        let numberOfRows = sut.tableView(sut.tableView, numberOfRowsInSection: 0)

        XCTAssertEqual(numberOfRows, 2)
    }

    func test_cellForRow_rendersCorrectCellType() {
        let sut = makeSUT()
        let (controller0, _) = makeCharacterCellController()
        let (controller1, _) = makeCharacterCellController()

        sut.display([controller0, controller1])
        let cell0 = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? CharacterCell
        let cell1 = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? CharacterCell

        XCTAssertNotNil(cell0)
        XCTAssertNotNil(cell1)
    }

    func test_willDisplayCell_requestCorrectCellMessages() {
        let sut = makeSUT()
        let (controller0, cellDelegate0) = makeCharacterCellController()
        let (controller1, cellDelegate1) = makeCharacterCellController()

        sut.display([controller0, controller1])

        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cellDelegate0.messages, [.didRequestImage])
        XCTAssertEqual(cellDelegate1.messages, [])

        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(cellDelegate0.messages, [.didRequestImage])
        XCTAssertEqual(cellDelegate1.messages, [.didRequestImage])
    }

    func test_willDisplayCell_requestsLoadMoreCharactersOnLastCell() {
        let sut = makeSUT()
        let (controller0, _) = makeCharacterCellController()
        let (controller1, _) = makeCharacterCellController()
        let (controller2, _) = makeCharacterCellController()
        var loadMoreCharactersRequestCalls: [Bool] = []
        sut.didRequestLoadMoreCharacters = { _ in loadMoreCharactersRequestCalls.append(true) }

        sut.display([controller0, controller1, controller2])

        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(loadMoreCharactersRequestCalls, [])

        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(loadMoreCharactersRequestCalls, [])

        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(loadMoreCharactersRequestCalls, [true])
    }

    func test_didEndDisplaying_requestCorrectCellMessages() {
        let sut = makeSUT()
        let (controller0, cellDelegate0) = makeCharacterCellController()
        let (controller1, cellDelegate1) = makeCharacterCellController()

        sut.display([controller0, controller1])
        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 1, section: 0))

        sut.tableView(sut.tableView, didEndDisplaying: anyTableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        sut.tableView(sut.tableView, didEndDisplaying: anyTableViewCell(), forRowAt: IndexPath(row: 1, section: 0))

        XCTAssertEqual(cellDelegate0.messages, [.didRequestImage, .didCancelImageRequest])
        XCTAssertEqual(cellDelegate1.messages, [.didRequestImage, .didCancelImageRequest])
    }

    func test_prefetchRowsAt_requestImagesToCorrectCells() {
        let sut = makeSUT()
        let (controller0, cellDelegate0) = makeCharacterCellController()
        let (controller1, cellDelegate1) = makeCharacterCellController()
        let (controller2, cellDelegate2) = makeCharacterCellController()

        sut.display([controller0, controller1, controller2])
        sut.tableView(sut.tableView, prefetchRowsAt: [.init(item: 0, section: 0), .init(row: 1, section: 0)])

        XCTAssertEqual(cellDelegate0.messages, [.didRequestImage])
        XCTAssertEqual(cellDelegate1.messages, [.didRequestImage])
        XCTAssertEqual(cellDelegate2.messages, [])
    }

    func test_cancelPrefetchingForRowsAt_cancelImageRequestToCorrectCells() {
        let sut = makeSUT()
        let (controller0, cellDelegate0) = makeCharacterCellController()
        let (controller1, cellDelegate1) = makeCharacterCellController()
        let (controller2, cellDelegate2) = makeCharacterCellController()

        sut.display([controller0, controller1, controller2])
        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 1, section: 0))
        sut.tableView(sut.tableView, willDisplay: anyTableViewCell(), forRowAt: IndexPath(row: 2, section: 0))

        sut.tableView(sut.tableView, cancelPrefetchingForRowsAt: [.init(item: 0, section: 0), .init(row: 1, section: 0)])

        XCTAssertEqual(cellDelegate0.messages, [.didRequestImage, .didCancelImageRequest])
        XCTAssertEqual(cellDelegate1.messages, [.didRequestImage, .didCancelImageRequest])
        XCTAssertEqual(cellDelegate2.messages, [.didRequestImage])
    }

    //MARK: - Helpers

    private func makeSUT() -> CharactersViewController {
        let sut = CharactersViewController()
        sut.viewDidLoad()

        return sut
    }

    private func anyTableViewCell() -> UITableViewCell {
        return UITableViewCell()
    }

    private func makeCharacterCellController() -> (controller: CharacterCellController, delegate: CharacterCellControllerDelegateSpy) {
        let delegate = CharacterCellControllerDelegateSpy()
        let cellController = CharacterCellController(delegate: delegate)

        return (cellController, delegate)
    }

    private class FakeUIRefreshControl: UIRefreshControl {
        private var _isRefreshing = false

        override var isRefreshing: Bool { _isRefreshing }

        override func beginRefreshing() {
            _isRefreshing = true
        }

        override func endRefreshing() {
            _isRefreshing = false
        }
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
}
