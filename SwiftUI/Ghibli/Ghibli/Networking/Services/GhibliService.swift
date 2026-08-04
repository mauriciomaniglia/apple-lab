import Foundation

protocol GhibliService: Sendable {
    func fetchFilms() async throws -> [Film]
    func fetchPerson(from URLString: String) async throws -> Person
}
