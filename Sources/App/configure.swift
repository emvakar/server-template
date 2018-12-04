import FluentPostgreSQL
import Vapor
import Authentication
import SwiftyBeaver
import SwiftyBeaverVapor
import FCM
import MailCore

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(abbreviation: "GMT+3:00")
    let dateString = formatter.string(from: Date())
    let fileName = dateString + "_log_vapor_app"

    if env.isRelease {
        let serverConfiure = NIOServerConfig.default(hostname: "127.0.0.1", port: 8080)
        services.register(serverConfiure)

        let loggingConsole = ConsoleDestination()
        let loggingFile = FileDestination() // log to file
        loggingFile.logFileURL = URL(string: "file:///tmp/\(fileName).log")! // set log file
        try services.register(SwiftyBeaverProvider(destinations: [loggingFile, loggingConsole]))
    } else {
        let serverConfiure = NIOServerConfig.default(hostname: "127.0.0.1", port: 8080)
        services.register(serverConfiure)

        let loggingConsole = ConsoleDestination()
        let loggingFile = FileDestination() // log to file
        loggingFile.logFileURL = URL(string: "file:///tmp/\(fileName).log")! // set log file
        try services.register(SwiftyBeaverProvider(destinations: [loggingFile, loggingConsole]))
    }

    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    config.prefer(SwiftyBeaverVapor.self, for: Logger.self)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config

    middlewares.use(RouteLoggingMiddleware.self)
    services.register(RouteLoggingMiddleware.self)

    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    if env.isRelease {
        let config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "username", database: "database", password: nil, transport: .cleartext)
        let postgres = PostgreSQLDatabase(config: config)

        /// Register the configured PostgreSQL database to the database config.
        var databases = DatabasesConfig()
        databases.add(database: postgres, as: .psql)
        services.register(databases)

        // FCM Setup
//        let fcm = FCM(pathToServiceAccountKey: "../serviceAccountKey.json")
//        services.register(fcm, as: FCM.self)

    } else {

        let config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "username", database: "database", password: nil, transport: .cleartext)
        let postgres = PostgreSQLDatabase(config: config)

        /// Register the configured PostgreSQL database to the database config.
        var databases = DatabasesConfig()
        databases.add(database: postgres, as: .psql)
        services.register(databases)

        // FCM Setup
//        let fcm = FCM(pathToServiceAccountKey: "../serviceAccountKey.json")
//        services.register(fcm, as: FCM.self)

    }

//    //Mail registration
//    let smtp = SMTP(hostname: "smtp.yandex.ru", email: "some@eskaria.com", password: "password")
//    let config = Mailer.Config.smtp(smtp)
//    try Mailer(config: config, registerOn: &services)


    /// Configure migrations
    var migrations = MigrationConfig()

    /// configuremodels
    migrations.add(model: User.self, database: .psql)

    services.register(migrations)

}
