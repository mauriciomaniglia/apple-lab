protocol GhibliService {
    func fetchFilms() async throws -> [Film]
}
