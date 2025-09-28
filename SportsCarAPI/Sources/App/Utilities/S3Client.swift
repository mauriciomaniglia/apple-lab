import Vapor

struct S3Client {
    let app: Application
    let endpoint: URI
    let bucket: String
    let accessKey: String
    let secretKey: String

    init(app: Application) {
        self.app = app
        let env = app.environment
        self.endpoint = URI(string: env.get("S3_ENDPOINT") ?? "http://minio:9000")
        self.bucket = env.get("S3_BUCKET") ?? "sportscar-images"
        self.accessKey = env.get("S3_ACCESS_KEY") ?? "minioadmin"
        self.secretKey = env.get("S3_SECRET_KEY") ?? "minioadmin"
    }

    func upload(fileData: ByteBuffer, fileName: String, contentType: String, on req: Request) -> EventLoopFuture<String> {
        let url = "\(endpoint.string)/\(bucket)/\(fileName)"
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: contentType)

        return req.client.put(URI(string: url), headers: headers) { putReq in
            putReq.body = .init(buffer: fileData)
        }.map { response in
            return url
        }
    }
}
