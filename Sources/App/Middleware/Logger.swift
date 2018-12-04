//
//  Logger.swift
//  App
//
//  Created by Emil Karimov on 04/10/2018.
//

import FluentPostgreSQL
import Vapor
import HTTP
import SwiftyBeaver
import SwiftyBeaverVapor

final class RouteLoggingMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let logger = try request.sharedContainer.make(Logger.self)
        let method = request.http.method
        let path = request.http.url.path

        if let query = request.http.url.query {
            logger.log("[\(method)] @ \(path), url paramters: \(query) - status: \(request.response().http.status)", at: .debug, file: #file, function: #function, line: #line, column: #column)
            return try next.respond(to: request)
        }
        logger.log("[\(method)] @ \(path) - status: \(request.response().http.status)", at: .debug, file: #file, function: #function, line: #line, column: #column)
        return try next.respond(to: request)
    }
}

extension RouteLoggingMiddleware: ServiceType {
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
}
