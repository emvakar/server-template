//
//  UserController.swift
//  App
//
//  Created by Emil Karimov on 04/10/2018.
//

import Vapor
import Fluent

extension UsersController {

    func profile(_ req: Request) throws -> Future<User.Public> {
        if let userId = try? req.query.get(Int.self, at: "userId") {
            return User.find(userId, on: req).unwrap(or: Abort(HTTPResponseStatus.notFound)).map { storedUser in
                return try User.Public(user: storedUser)
            }
        }
        return req.future(try User.Public(user: try req.requireAuthenticated(User.self)))
    }
}
