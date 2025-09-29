import Vapor

func routes(_ app: Application) throws {
    app.get("health") { req -> HTTPStatus in
        return .ok
    }
    let carController = SportsCarController()
    try app.register(collection: carController)
}
