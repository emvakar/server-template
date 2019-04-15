//
//  UserController.swift
//  App
//
//  Created by Emil Karimov on 04/10/2018.
//

import Vapor
import Fluent

extension UsersController {
    
    func signIN(_ req: Request) throws -> Future<User.Public> {
        return req.future(try User.Public(user: try req.requireAuthenticated(User.self)))
    }
}
