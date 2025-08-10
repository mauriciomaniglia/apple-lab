import Foundation

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

let url = URL(string: "http://localhost:8000/episodes.json")!

let episodesResource = Resource<Data>(url: url, parse: { data in
    return data
})
