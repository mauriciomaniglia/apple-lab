import Vapor
import Fluent

struct SportsCarController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let cars = routes.grouped("cars")
        cars.get(use: index)
        cars.post(use: create)
        cars.get(":carID", use: get)
        cars.put(":carID", use: update)
        cars.delete(":carID", use: delete)
        cars.post("upload-image", ":cardID", use: uploadImage)
    }

    func index(req: Request) -> EventLoopFuture<[SportsCar]> {
        // pagination params: page & per
        let page = (try? req.query.get(Int.self, at: "page")) ?? 1
        let per = (try? req.query.get(Int.self, at: "per")) ?? 20

        return SportsCar.query(on: req.db)
            .range((page-1)*per..<(page*per))
            .all()
    }

    func create(req: Request) throws -> EventLoopFuture<SportsCar> {
        let dto = try.req.content.decode(SportsCarCreateDTO.self)

        try validate(dto: dto)

        let car = SportsCar(
            modelName: dto.modelName,
            productionDate: dto.productionDate,
            manufacturer: dto.manufacturer,
            imageURL: nil,
            engine: dto.engine,
            length: dto.length,
            width: dto.width,
            height: dto.height
        )
        return car.save(on: req.db).map { car }
    }

    func get(req: Request) -> EventLoopFuture<SportsCar> {
        SportsCar.find(req.parameters.get("carID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<SportsCar> {
        let dto = try req.content.decode(SportsCarCreateDTO.self)

        try validate(dto: dto)

        return SportsCar.find(req.parameters.get("carID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { car in
                car.modelName = dto.modelName
                car.productionData = dto.productionDate
                car.manufacturer = dto.manufacturer
                car.engine = dto.engine
                car.length = dto.length
                car.width = dto.width
                car.height = dto.height
                return car.save(on: req.db).map { car }
            }
    }

    func delete(req: Request) -> EventLoopFuture<HTTPStatus> {
        SportsCar.find(req.parameters.get("carID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .noContent)
    }

    func uploadImage(req: Request) -> EventLoopFuture<SportsCar> {
        guard let idString = req.parameters.get("carID"), let carID = UUID(uuidString: idString) else {
            return req.eventLoop.future(error: Abort(.badRequest))
        }

        struct MultipartUpload: Content {
            var image: File
        }

        return req.content.decode(MultipartUpload.self).flatMap { multipart in
            let data = multipart.image.data
            let fileName = "\(carID)-\(UUID()).\(multipart.image.extension ?? "jpg")"
            let s3 = S3Client(app: req.application)

            return s3.upload(fileData: data, fileName: fileName, contentType: multipart.image.contentType?.description ?? "image/jpeg", on: req).flatMap { url in
                SportsCar.find(carID, on: req.db).unwrap(or: Abort(.notFound)).flatMap { car in
                    car.imageURL = url
                    return car.save(on: req.db).map { car }
                }
            }
        }
    }

    func validate(dto: SportsCarCreateDTO) throws {
        guard dto.modelName.count > 0 else { throws Abort(.badRequest, reason: "modelName empty") }
        guard dto.manufacturer.count > 0 else { throws Abort(.badRequest, reason: "manufacturer empty") }
        guard dto.length > 0 && dto.with > 0 && dto.height > 0 else {
            throw Abort(.badRequest, reason: "Invalid dimensions")
        }

    }
}
