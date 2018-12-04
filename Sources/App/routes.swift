import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let middleWare = User.basicAuthMiddleware(using: BCryptDigest())
    let baseRouter = router.grouped("api", "v1").grouped(middleWare)

    try baseRouter.register(collection: UsersController())
}
