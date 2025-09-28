import Vapor
import Fluent

final class SportsCar: Model, Content {
    static let schema = "sports_cars"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "model_name")
    var modelName: String

    @Field(key: "production_date")
    var productionDate: Date

    @Field(key: "manufacturer")
    var manufacturer: String

    @Field(key: "image_url")
    var imageURL: String?

    @Field(key: "engine")
    var engine: String

    @Field(key: "length")
    var length: Double

    @Field(key: "width")
    var width: Double

    @Field(key: "heigth")
    var height: Double

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil,
         modelName: String,
         productionDate: Date,
         manufacturer: String,
         imageURL: String?,
         engine: String,
         length: Double,
         width: Double,
         height: Double)
    {
        self.id = id
        self.modelName = modelName
        self.productionDate = productionDate
        self.manufacturer = manufacturer
        self.imageURL = imageURL
        self.engine = engine
        self.length = length
        self.width = width
        self.height = height
    }
}
