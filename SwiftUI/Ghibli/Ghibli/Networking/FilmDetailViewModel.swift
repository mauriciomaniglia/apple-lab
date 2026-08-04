import Foundation
import Observation


class FilmDetailViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded([Person])
        case error(String)
    }

    var state: State = .idle

    let service: GhibliService

    init(service: GhibliService = DefaultGhibliService()) {
        self.service = service
    }

    func fetch(for film: Film) async {
        guard state != .loading else { return }

        state = .loading

        var loadedPeople: [Person] = []

        do {
            try await withThrowingTaskGroup(of: Person.self) { group in
                for personInfoURL in film.people {
                    group.addTask {
                        try await self.service.fetchPerson(from: personInfoURL)
                    }
                }

                for try await person in group {
                    loadedPeople.append(person)
                }

                state = .loaded(loadedPeople)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

import Playgrounds

#Playground {
    let service = MockGhibliService()
    let viewModel = FilmDetailViewModel(service: service)
    let film = try await service.fetchFilms().first!

    await viewModel.fetch(for: film)

    _ = viewModel.state
}
