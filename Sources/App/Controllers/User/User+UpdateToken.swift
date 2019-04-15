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
    
//    func sendTestPush(_ req: Request) throws -> String {
//        let user = try req.requireAuthenticated(User.self)
//
//        let fcm = try req.make(FCM.self)
//
//        _ = User.query(on: req).all().map { (users) in
//            let tokensToSend: [String] = users.map { $0.fcmToken }
//            for token in tokensToSend {
//                let notification = FCMNotification(title: "App user: \(user.name)", body: "testing notifications!")
//                let message = FCMMessage(token: token, notification: notification)
//                _ = try fcm.sendMessage(req.client(), message: message)
//            }
//        }
//        return user.fcmToken
//    }
//
//    func sendTestEmail(_ req: Request) throws -> Future<HTTPResponse> {
//        let user = try req.requireAuthenticated(User.self)
//        let mail = Mailer.Message(from: "some@eskaria.com", to: user.email, subject: "SUBJECT", text: "Hello dear, \(user.name)", html: "<p>Hello dear, \(user.name)! It's test email! Good Luck!</p>")
//        return try req.mail.send(mail).map({ (mailResult) -> HTTPResponse in
//            return HTTPResponse.init()
//        })
//    }
    
    func updateFCMToken(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        let fcmToken = try req.query.get(String.self, at: "fcmToken")
        user.fcmToken = fcmToken
        return user.update(on: req).map({ storedUser in
            return try User.Public(user: storedUser)
        })
    }
}
