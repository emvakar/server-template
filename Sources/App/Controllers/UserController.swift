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

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let route = router.grouped("api", "v1", "users")
        route.post("register", use: register)
        
        let middleWare = User.basicAuthMiddleware(using: BCryptDigest())
        let authedGroup = route.grouped(middleWare)
        authedGroup.get(use: getAllUsers)
        authedGroup.post("login", use: login)
        authedGroup.get("profile", use: profile)
        authedGroup.get(User.parameter, use: getUser)
        authedGroup.post("fcm", use: updateFCMToken)
        authedGroup.post("test", use: sendTestPush)
        authedGroup.post("email", use: sendTestEmail)
    }
    
    func sendTestPush(_ req: Request) throws -> String {
        let user = try req.requireAuthenticated(User.self)
        
        let fcm = try req.make(FCM.self)
        
        _ = User.query(on: req).all().map { (users) in
            let tokensToSend: [String] = users.map { $0.fcmToken }
            for token in tokensToSend {
                let notification = FCMNotification(title: "App user: \(user.name)", body: "testing notifications!")
                let message = FCMMessage(token: token, notification: notification)
                _ = try fcm.sendMessage(req.client(), message: message)
            }
        }
        return user.fcmToken
    }
    
    func sendTestEmail(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        let mail = Mailer.Message(from: "some@eskaria.com", to: user.email, subject: "SUBJECT", text: "Hello dear, \(user.name)", html: "<p>Hello dear, \(user.name)! It's test email! Good Luck!</p>")
        return try req.mail.send(mail).map({ (mailResult) -> HTTPResponse in
            return HTTPResponse.init()
        })
    }
    
    func getAllUsers(_ req: Request) throws -> Future<[User]> {
        let user = try req.requireAuthenticated(User.self)
        print(user.email)
        return User.query(on: req).all()
    }
    
    func getUser(_ req: Request) throws -> Future<User> {
        let user = try req.requireAuthenticated(User.self)
        return User.find(try user.requireID(), on: req).unwrap(or: Abort(HTTPResponseStatus.notFound))
    }
    
    func register(_ req: Request) throws -> Future<User.Public> {
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
    
    func login(_ req: Request) throws -> Future<User.Public> {
        return req.future(try User.Public(user: try req.requireAuthenticated(User.self)))
    }
    
    func profile(_ req: Request) throws -> Future<User.Public> {
        return req.future(try User.Public(user: try req.requireAuthenticated(User.self)))
    }
    
    func updateFCMToken(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        let fcmToken = try req.query.get(String.self, at: "fcmToken")
        user.fcmToken = fcmToken
        return user.update(on: req).map({ storedUser in
            return try User.Public(user: storedUser)
        })
    }
}
