import HTTP

/**
Represents a connection to an OAuth provider to get an access token for authenticating a user.
 
Usage:

```swift
import HTTP

public class Service: FederatedService {
    public var tokens: FederatedServiceTokens
    public var router: FederatedServiceRouter

    @discardableResult
    public required init(authenticate: String, callback: String, scope: [String] = [], completion: @escaping (String) -> (ResponseRepresentable)) throws {
        self.router = try ServiceRouter(callback: callback, completion: completion)
        self.tokens = self.router.tokens

        self.router.scope = scope
        try self.router.configureRoutes(withAuthURL: authenticate)

        Service.register(.service)
    }
}
```
 */
public protocol FederatedService {
    
    /// The service's token model for getting the client ID and secret.
    var tokens: FederatedServiceTokens { get }
    
    /// The service's router for handling the request for the access token.
    var router: FederatedServiceRouter { get }
}
