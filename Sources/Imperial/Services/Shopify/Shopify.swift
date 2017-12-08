import HTTP

public class Shopify: FederatedService {
    public var tokens: FederatedServiceTokens
    public var router: FederatedServiceRouter
    
    @discardableResult
    public init(domain: String, authenticate: String, callback: String, scope: [String] = [], completion: @escaping (String) -> (ResponseRepresentable)) throws {
        self.router = try ShopifyRouter(domain: domain, callback: callback, completion: completion)
        self.tokens = self.router.tokens
        
        self.router.scope = scope
        try self.router.configureRoutes(withAuthURL: authenticate)
        
        Service.register(.shopify)
    }
}

