import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    let hostname = Environment.get("DATABASE_HOST") ?? "postgres"
    let username = Environment.get("DATABASE_USERNAME") ?? "postgres"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let dbName = Environment.get("DATABASE_NAME") ?? "sportscar_db"
    let dbPort = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432

    app.database.use(.postgres(
        hostname: hostname,
        port: dbPort,
        username: username,
        password: password,
        database: dbName
    ), as: .psql)

    // Migrations
    app.migrations.add(CreateSportsCar())

    // Enable pretty logging in dev
    if app.environment == .development {
        app.logger.logLevel = .debug
    }

    // CORS
    let cors = CORSMiddleware(configuration: .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin]
    ))
    app.middleware.use(cors)

    // register routes
    try routes(app)
}
