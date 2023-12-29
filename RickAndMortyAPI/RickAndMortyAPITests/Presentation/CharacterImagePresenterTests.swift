import XCTest
import RickAndMortyAPI

class CharacterImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let character = uniqueCharacter()

        sut.didStartLoadingImageData(for: character)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, character.name)
        XCTAssertEqual(message?.species, character.species)
        XCTAssertEqual(message?.gender, character.gender)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }

    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let character = uniqueCharacter()

        sut.didFinishLoadingImageData(with: Data(), for: character)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, character.name)
        XCTAssertEqual(message?.species, character.species)
        XCTAssertEqual(message?.gender, character.gender)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
     }

    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let character = uniqueCharacter()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

        sut.didFinishLoadingImageData(with: Data(), for: character)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, character.name)
        XCTAssertEqual(message?.species, character.species)
        XCTAssertEqual(message?.gender, character.gender)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
     }

    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let character = uniqueCharacter()
        let (sut, view) = makeSUT()

        sut.didFinishLoadingImageData(with: anyNSError(), for: character)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, character.name)
        XCTAssertEqual(message?.species, character.species)
        XCTAssertEqual(message?.gender, character.gender)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }

    // MARK: Helpers

    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: CharacterImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = CharacterImagePresenter(view: view, imageTransformer: imageTransformer)

        trackForMemoryLeak(view)
        trackForMemoryLeak(sut)

        return (sut, view)
    }

    private var fail: (Data) -> AnyImage? {
         return { _ in nil }
    }

    private struct AnyImage: Equatable {}

    private class ViewSpy: CharacterImageView {
        private(set) var messages = [CharacterViewModel<AnyImage>]()

        func display(_ model: CharacterViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
