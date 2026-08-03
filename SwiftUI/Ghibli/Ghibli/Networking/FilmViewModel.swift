import Foundation
import Observation

@Observable
class FilmViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded([Film])
        case error(String)
    }

    var state: State = .idle
    var films: [Film] = []

    private let service: GhibliService

    init(service: GhibliService = DefaultGhibliService()) {
        self.service = service
    }

    func fetch() async {
        guard state == .idle else { return }

        state = .loading

        do {
            let films = try await service.fetchFilms()
            state = .loaded(films)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
