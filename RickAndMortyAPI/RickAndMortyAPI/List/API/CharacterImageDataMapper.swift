import Foundation

public final class CharacterImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.isOK, !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
}
