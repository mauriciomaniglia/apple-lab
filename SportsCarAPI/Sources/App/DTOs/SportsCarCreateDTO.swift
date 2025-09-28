import Vapor

struct SportsCarCreateDTO: Content {
    var modelName: String
    var productionDate: Date
    var manufacturer: String
    var engine: String
    var length: Double
    var width: Double
    var height: Double
}
