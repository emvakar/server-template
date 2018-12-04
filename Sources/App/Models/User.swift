//
//  User.swift
//  App
//
//  Created by Emil Karimov on 04/10/2018.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var deviceId: String = ""
    var fcmToken: String = ""
    
    var email: String
    var password: String
    
    init(name: String, username: String, email: String, password: String, deviceId: String) {
        self.name = name
        self.username = username
        self.email = email
        self.password = password
        self.deviceId = deviceId
    }
    
    struct Public: Content {
        let id: UUID
        let email: String
        
        init(user: User) throws {
            self.id = try user.requireID()
            self.email = user.email
        }
        
    }
    
    struct PublicUser: Content {
        
        let username: String
        let name: String
        let email: String
        
        init(user: User) {
            self.username = user.username
            self.name = user.name
            self.email = user.email
        }
    }
}

extension User: PostgreSQLUUIDModel { }
extension User: Content { }
extension User: Migration { }
extension User: Parameter { }

extension User { }

extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.email
    }
    static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
}
