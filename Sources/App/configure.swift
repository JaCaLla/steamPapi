import NIOSSL
import Fluent
import FluentPostgresDriver
import JWT
import Vapor

private enum AppError: Error {
    case missingDatabaseCredentials
    case missingJWTSigningSecret
}

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    try await configureDatabase(app)
    
    guard let signingSecret = Environment.get("JWT_SIGNING_SECRET")
    else {
        throw AppError.missingJWTSigningSecret
    }
    await app.jwt.keys.add(hmac: HMACKey(from: signingSecret), digestAlgorithm: .sha256)
    
    configuireJSONEncoder()
    configureLogs()
}

public func configureLogs() {
    var logger = Logger(label: "vapor-logger")
    logger.logLevel = .trace

    let logLevel = Environment.get("LOG_LEVEL")

    if let logLevel, let logLevel = Logger.Level(rawValue: logLevel) {
        logger.logLevel = logLevel
    }
}

public func configuireJSONEncoder() {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    
    ContentConfiguration.global.use(decoder: decoder, for: .json)
    ContentConfiguration.global.use(encoder: encoder, for: .json)
}

public func configureDatabase(_ app: Application) async throws {
    guard
        let dbUser = Environment.get("DATABASE_USERNAME"),
        let dbPass = Environment.get("DATABASE_PASSWORD"),
        let dbName = Environment.get("DATABASE_NAME")
    else {
        throw AppError.missingDatabaseCredentials
    }

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: dbUser,
        password: dbPass,
        database: dbName,
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateProductGroceryPriceAndUser())
    // register routes
    try routes(app)
}
