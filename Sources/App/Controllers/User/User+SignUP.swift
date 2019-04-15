//
//  UserController.swift
//  App
//
//  Created by Emil Karimov on 04/10/2018.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Crypto
import FCM
import MailCore

extension UsersController {
    
    func signUP(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "a user with this email already exists", identifier: nil)
                }
                let hasher = try req.make(BCryptDigest.self)
                let passwordHashed = try hasher.hash(user.password)
                let newUser = User(name: user.name, username: user.username, email: user.email, password: passwordHashed, deviceId: user.deviceId)
                return newUser.save(on: req).map { storedUser in
                    return try User.Public(user: storedUser)
                }
            }
        }
    }
}
