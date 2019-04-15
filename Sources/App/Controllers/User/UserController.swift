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
        route.post("signUP", use: self.signUP)

        let middleWare = User.basicAuthMiddleware(using: BCryptDigest())
        let authedGroup = route.grouped(middleWare)

        authedGroup.post("signIN", use: self.signIN)
        authedGroup.get("profile", use: self.profile)
        authedGroup.post("fcm", use: self.updateFCMToken)

    }

}
