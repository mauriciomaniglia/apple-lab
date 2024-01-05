import XCTest
import RickAndMortyAPI

class CharacterItemsMapperTests: XCTestCase {
        func test_map_throwsErrorOnNon200HTTPResponse() throws {
            let json = makeItemsJson([])
            let samples =  [199, 201, 300, 400, 500]
    
           try samples.forEach { code in
                XCTAssertThrowsError(
                    try CharacterItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
                )
           }
        }
    
        func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
            let invalidJSON = Data("invalid json".utf8)

            XCTAssertThrowsError(
                try CharacterItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
            )
        }
    
        func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
            let emptyListJSON = makeItemsJson([])

            let result = try CharacterItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))

            XCTAssertEqual(result, [])
        }
    
        func test_map_deliverItemsOn200HTTPResponseWithJSONItems() throws {
            let item1 = makeItem(
                id: 1,
                name: "a name",
                imageURL: URL(string: "http://some-url.com")!,
                species: "a specie",
                gender: "a gender")
    
            let item2 = makeItem(
                id: 2,
                name: "another name",
                imageURL: URL(string: "http://another-url.com")!,
                species: "another specie",
                gender: "another gender")

            let json = makeItemsJson([item1.json, item2.json])

            let result = try CharacterItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))

            XCTAssertEqual(result, [item1.model, item2.model])
        }

    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let json = ["results": items]
    
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func makeItem(id: Int, name: String, imageURL: URL, species: String, gender: String) -> (model: Character, json: [String: Any]) {
        let item = Character(id: id, name: name, image: imageURL, species: species, gender: gender)

        let json = [
            "id": item.id,
            "name": item.name,
            "image": item.image.absoluteString,
            "species": item.species,
            "gender": item.gender,
            ].compactMapValues { $0 }

        return (item, json)
    }
}
