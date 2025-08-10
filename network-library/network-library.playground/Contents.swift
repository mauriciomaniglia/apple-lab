import PlaygroundSupport
import Foundation

struct Episode {
    let id: String
    let title: String
}

extension Episode {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String else { return nil }

        self.id = id
        self.title = title
    }
}

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

let url = URL(string: "https://raw.githubusercontent.com/mauriciomaniglia/apple-lab/refs/heads/main/network-library/episodes.json")!

typealias JSONDictionary = [String: AnyObject]

let episodesResource = Resource<[Episode]>(url: url, parse: { data in
    let json = try? JSONSerialization.jsonObject(with: data, options: [])
    guard let dictionaries = json as? [JSONDictionary] else { return nil }
    return dictionaries.flatMap(Episode.init)
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

PlaygroundPage.current.needsIndefiniteExecution = true
