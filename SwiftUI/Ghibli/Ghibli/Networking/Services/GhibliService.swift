import Foundation

protocol GhibliService {
    func fetchFilms() async throws -> [Film]
    func fetchPerson(from URLString: String) async throws -> Person
}
