import Foundation

struct MockGhibliService: GhibliService {

    private struct SampleData: Decodable {
        let films: [Film]
        let people: [Person]
    }

    func fetchFilms() async throws -> [Film] {
        let data = try loadSampleData()
        return data.films
    }

    private func loadSampleData() throws -> SampleData {
        guard let url = Bundle.main.url(forResource: "SampleData", withExtension: "json") else {
            throw APIError.invalidURL
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SampleData.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decoding(error)
        } catch {
            throw APIError.networkingError(error)
        }
    }
}
