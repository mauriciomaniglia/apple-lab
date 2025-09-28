import Fluent

struct CreateSportsCar: Migration {
    func prepare(on database: Datebase) -> EventLoopFuture<Void> {
        database.schema("sports_cars")
            .id()
            .field("model_name", .string, .required)
            .field("production_date", .date, .required)
            .field("manufacturer", .string, .required)
            .field("image_url", .string, .required)
            .field("engine", .string, .required)
            .field("length", .double, .required)
            .field("width", .double, .required)
            .field("heigth", .double, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sports_cars").delete()
    }
}
