import Foundation

struct DefaultGhibliService: GhibliService {

    func fetchFilms() async throws -> [Film] {
        let url = "https://ghibliapi.vercel.app/films"
        return try await fetch(from: url, type: [Film].self)
    }

    func fetchPerson(from URLString: String) async throws -> Person {
        return try await fetch(from: URLString, type: Person.self)
    }

    private func fetch<T: Decodable>(from URLString: String, type: T.Type) async throws -> T {
        guard let url = URL(string: URLString) else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }

            return try JSONDecoder().decode(type, from: data)
        } catch let error as DecodingError {
            throw APIError.decoding(error)
        } catch let error as URLError {
            throw APIError.networkingError(error)
        }
    }
}
