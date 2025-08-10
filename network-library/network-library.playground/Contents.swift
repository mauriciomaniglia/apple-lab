import XCPlayground
import Foundation

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

let url = URL(string: "https://raw.githubusercontent.com/mauriciomaniglia/apple-lab/refs/heads/main/network-library/episodes.json")!

let episodesResource = Resource<Data>(url: url, parse: { data in
    return data
})

final class Webservice {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { data, _, _ in
            let result = data.flatMap(resource.parse)
            completion(result)
        }.resume()
    }
}

Webservice().load(resource: episodesResource) { data in
    print(data)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
