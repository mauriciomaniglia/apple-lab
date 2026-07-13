import Foundation

struct User: Identifiable, Codable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var fullname: String?
    var bio: String?
    let email: String
}

extension User {
    static var MOCK_USER: [User] = [
        .init(id: UUID().uuidString,
              username: "gordon-freeman",
              profileImageUrl: "gordon-freeman",
              fullname: "Gordon Freeman",
              bio: "Black Mesa Research Scientist",
              email: "gordon-freeman@blackmesa.com"
        ),
        .init(id: UUID().uuidString,
              username: "alyx-vance",
              profileImageUrl: "alyx",
              fullname: "Alyx Vance",
              bio: "Resistance prominent figure & tech genius",
              email: "alyx.vance@resistance.org"
             ),
        .init(id: UUID().uuidString,
              username: "barney-calhoun",
              profileImageUrl: "barney-calhoun",
              fullname: "Barney Calhoun",
              bio: "Civil Protection undercover agent. I still owe ya a beer!",
              email: "b.calhoun@resistance.org"
             ),
        .init(id: UUID().uuidString,
              username: "eli-vance",
              profileImageUrl: "eli-vance",
              fullname: "Eli Vance",
              bio: "Leader of the Resistance & Black Mesa survivor",
              email: "eli.vance@blackmesa-east.org"
             ),
        .init(id: UUID().uuidString,
              username: "isaac-kleiner",
              profileImageUrl: "isaac-kleiner",
              fullname: "Dr. Isaac Kleiner",
              bio: "Theoretical Physicist. Watch out for Lamarr!",
              email: "i.kleiner@kleinerlab.org"
             ),
        .init(id: UUID().uuidString,
              username: "father-grigori",
              profileImageUrl: "father-grigori",
              fullname: "Father Grigori",
              bio: "Tending to my flock in Ravenholm",
              email: "grigori@ravenholm.org"
             ),
        .init(id: UUID().uuidString,
              username: "wallace-breen",
              profileImageUrl: "wallace-breen",
              fullname: "Wallace Breen",
              bio: "Earth's Interim Administrator. Welcome to City 17.",
              email: "administrator@combine-overwatch.gov"
             ),
        .init(id: UUID().uuidString,
              username: "g-man",
              profileImageUrl: "g-man",
              fullname: "The G-Man",
              bio: "Unforeseen consequences...",
              email: "unknown@employers.com"
             )
    ]
}
