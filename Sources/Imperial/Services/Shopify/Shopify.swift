import HTTP
import Imperial

public class Shopify: FederatedService {
    public var auth: FederatedLoginService
    public var router: FederatedServiceRouter
    
    @discardableResult
    public required init(authenticate: String, callback: String, scope: [String: String] = [:], completion: @escaping (String) -> (ResponseRepresentable)) throws {
        self.router = try ShopifyRouter(callback: callback, completion: completion)
        self.auth = self.router.service
        
        self.router.scope = scope
        try self.router.configureRoutes(withAuthURL: authenticate)
    }
}
