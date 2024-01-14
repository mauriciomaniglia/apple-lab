import XCTest
import Combine
import RickAndMortyAPI

class CharactersUIIntegrationTests: XCTestCase {
    func test_charactersView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.title, "My Characters")
    }

    func test_loadCharactersActions_requestCharactersFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCharacterCallCount, 0, "Expected no loading requests before view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCharacterCallCount, 1, "Expected a loading request once view appears")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCharacterCallCount, 1, "Expected no request until previous completes")

        loader.completeCharactersLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCharacterCallCount, 2, "Expected another loading request once user initiates a reload")

        loader.completeCharactersLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCharacterCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadCharactersActions_runsAutomaticallyOnlyOnFirstAppearance() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCharacterCallCount, 0, "Expected no loading requests before view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCharacterCallCount, 1, "Expected a loading request once view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCharacterCallCount, 1, "Expected no loading request the second time view appears")
    }

    func test_loadingCharactersIndicator_isVisibleWhileLoadingCharacters() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view appears")

        loader.completeCharactersLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeCharacterLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadCharactersCompletion_rendersSuccessfullyLoadedCharacters() {
        let character0 = makeCharacter(name: "name 0", species: "species 0", gender: "gender 0")
        let character1 = makeCharacter(name: "name 1", species: "species 1", gender: "gender 1")
        let character2 = makeCharacter(name: "name 2", species: "species 2", gender: "gender 2")
        let character3 = makeCharacter(name: "name 3", species: "species 3", gender: "gender 3")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.numberOfRows(in: 0), 0)

        loader.completeCharactersLoading(with: [character0, character1, character2], at: 0)
        XCTAssertEqual(sut.numberOfRows(in: 0), 3)

        sut.didRequestLoadMoreCharacters?(sut)
        loader.completeLoadMoreCharacters(with: [character0, character1, character2, character3], at: 0)
        XCTAssertEqual(sut.numberOfRows(in: 0), 4)

        sut.simulateUserInitiatedReload()
        loader.completeCharactersLoading(with: [character0, character1], at: 1)        
        XCTAssertEqual(sut.numberOfRows(in: 0), 2)
    }

    func test_loadCharactersCompletion_rendersSuccessfullyLoadedEmptyCharacterAfterNonEmptyCharacter() {
        let character0 = makeCharacter(name: "name 0", species: "species 0", gender: "gender 0")
        let character1 = makeCharacter(name: "name 1", species: "species 1", gender: "gender 1")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeCharactersLoading(with: [character0], at: 0)
        XCTAssertEqual(sut.numberOfRows(in: 0), 1)

        sut.didRequestLoadMoreCharacters?(sut)
        loader.completeLoadMoreCharacters(with: [character0, character1], at: 0)
        XCTAssertEqual(sut.numberOfRows(in: 0), 2)

        sut.simulateUserInitiatedReload()
        loader.completeCharactersLoading(with: [], at: 1)
        XCTAssertEqual(sut.numberOfRows(in: 0), 0)
    }

    func test_loadCharactersCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let character0 = makeCharacter(name: "name 0", species: "species 0", gender: "gender 0")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeCharactersLoading(with: [character0], at: 0)
        XCTAssertEqual(sut.numberOfRows(in: 0), 1)

        sut.simulateUserInitiatedReload()
        loader.completeCharacterLoadingWithError(at: 1)
        XCTAssertEqual(sut.numberOfRows(in: 0), 1)

        sut.didRequestLoadMoreCharacters?(sut)
        loader.completeLoadMoreWithError(at: 0)
        XCTAssertEqual(sut.numberOfRows(in: 0), 1)
    }

    func test_loadCharactersCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCharactersLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadCharactersCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeCharacterLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, "Couldn't connect to server")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeCharacterLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, "Couldn't connect to server")

        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_loadMoreActions_requestMoreFromLoader() {
        let (sut, loader) = makeSUT()
        let character0 = makeCharacter(name: "name 0", species: "species 0", gender: "gender 0")
        let character1 = makeCharacter(name: "name 1", species: "species 1", gender: "gender 1")

        sut.simulateAppearance()
        loader.completeCharactersLoading(with: [character0])

        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no requests before until load more action")

        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")

        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while loading more")

        loader.completeLoadMoreCharacters(with: [character0, character1], at: 0)
        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more completed with more pages")

        loader.completeLoadMoreWithError(at: 1)
        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after load more failure")

        loader.completeLoadMoreCharacters(with: [character0, character1], at: 2)
        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after loading all pages")
    }

    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
        let (sut, loader) = makeSUT()
        let character0 = makeCharacter(name: "name 0", species: "species 0", gender: "gender 0")
        let character1 = makeCharacter(name: "name 1", species: "species 1", gender: "gender 1")

        sut.simulateAppearance()
        XCTAssertFalse(sut.isShowingLoadMoreCharactersIndicator, "Expected no loading indicator once view appears")

        loader.completeCharactersLoading(with: [character0], at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreCharactersIndicator, "Expected no loading indicator once loading completes successfully")

        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertTrue(sut.isShowingLoadMoreCharactersIndicator, "Expected loading indicator on load more action")

        loader.completeLoadMoreCharacters(with: [character0, character1], at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreCharactersIndicator, "Expected no loading indicator once user initiated loading completes successfully")

        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertTrue(sut.isShowingLoadMoreCharactersIndicator, "Expected loading indicator on second load more action")

        loader.completeLoadMoreWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadMoreCharactersIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadMoreCompletion_rendersErrorMessageOnError() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeCharactersLoading()

        sut.didRequestLoadMoreCharacters?(sut)
        XCTAssertEqual(sut.loadMoreCharactersErrorMessage, nil)

        loader.completeLoadMoreWithError()
        XCTAssertEqual(sut.loadMoreCharactersErrorMessage, "Couldn't connect to server")

        sut.didRequestLoadMoreCharacters?(sut)
        loader.completeLoadMoreCharacters(at: 1)
        XCTAssertEqual(sut.loadMoreCharactersErrorMessage, nil)
    }

//    func test_tapOnLoadMoreErrorView_loadsMore() {
//        let (sut, loader) = makeSUT()
//        sut.simulateAppearance()
//        loader.completeCharactersLoading()
//
//        sut.didRequestLoadMoreCharacters?(sut)
//        XCTAssertEqual(loader.loadMoreCallCount, 1)
//
//        sut.simulateTapOnLoadMoreFeedError()
//        XCTAssertEqual(loader.loadMoreCallCount, 1)
//
//        loader.completeLoadMoreWithError()
//        sut.simulateTapOnLoadMoreFeedError()
//        XCTAssertEqual(loader.loadMoreCallCount, 2)
//    }

    func test_characterView_loadsImageURLWhenVisible() {
        let character0 = makeCharacter(name: "name 0", image: URL(string: "http://url-0.com")!, species: "species 0", gender: "gender 0")
        let character1 = makeCharacter(name: "name 1", image: URL(string: "http://url-1.com")!, species: "species 1", gender: "gender 1")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeCharactersLoading(with: [character0, character1])

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateCharacterViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [character0.image], "Expected first image URL request once first view becomes visible")

        sut.simulateCharacterViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [character0.image, character1.image], "Expected second image URL request once second view also becomes visible")
    }

    func test_characterView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let character0 = makeCharacter(name: "name 0", image: URL(string: "http://url-0.com")!, species: "species 0", gender: "gender 0")
        let character1 = makeCharacter(name: "name 1", image: URL(string: "http://url-1.com")!, species: "species 1", gender: "gender 1")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeCharactersLoading(with: [character0, character1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")

        sut.simulateCharacterViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [character0.image], "Expected one cancelled image URL request once first image is not visible anymore")

        sut.simulateCharacterViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [character0.image, character1.image], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: CharactersViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CharactersUIComposer.charactersComposedWith(
            characterLoader: loader.loadPublisher,
            characterLoadMore: loader.loadMorePublisher,
            imageLoader: loader.loadImageDataPublisher)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeCharacter(name: String, image: URL = URL(string: "http://any-url.com")!, species: String, gender: String) -> Character {
        return Character(id: Int.random(in: 0...100), name: name, image: image, species: species, gender: gender)
    }
}
