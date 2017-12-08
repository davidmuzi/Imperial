import Vapor
import Sessions

public class ShopifyRouter: FederatedServiceRouter {
    
    public let tokens: FederatedServiceTokens
    public let callbackCompletion: (String) -> (ResponseRepresentable)
    public var scope: [String] = []
    public let callbackURL: String
    public var domain: String
    
    public var accessTokenURL: String {
        return "https://\(domain)/admin/oauth/access_token"
    }
    
    public var authURL: String {
        return "https://\(domain)/admin/oauth/authorize?" +
            "scope=\(scope.joined(separator: ","))&" +
            "client_id=\(self.tokens.clientID)&" +
            "redirect_uri=\(callbackURL)"
    }
    
    public init(domain: String, callback: String, completion: @escaping (String) -> (ResponseRepresentable)) throws {
        self.tokens = try ShopifyAuth()
        self.callbackURL = callback
        self.callbackCompletion = completion
        self.domain = domain
    }
    
    public func callback(_ request: Request) throws -> ResponseRepresentable {
        let code: String
        if let queryCode: String = try request.query?.get("code") {
            code = queryCode
        } else if let error: String = try request.query?.get("error") {
            throw Abort(.badRequest, reason: error)
        } else {
            throw Abort(.badRequest, reason: "Missing 'code' key in URL query")
        }
        
        let req = Request(method: .post, uri: accessTokenURL)
        req.formURLEncoded = [
            "client_id": .string(self.tokens.clientID),
            "client_secret": .string(self.tokens.clientSecret),
            "code": .string(code)
        ]
        
        let response = try droplet.client.respond(to: req)
        
        guard let json = response.json else {
            throw Abort(.internalServerError, reason: "Unable to get body from access token response")
        }
        
        guard let accessToken: String = json["access_token"]?.string else {
            throw Abort(.internalServerError, reason: "Unable to get access token from response body")
        }
        
        let session = try request.assertSession()
        try session.data.set("access_token", accessToken)
        try session.data.set("access_token_service", Service.shopify)
        return callbackCompletion(accessToken)
    }

    public func configureRoutes(withAuthURL authURL: String) throws {
        var callbackPath = URIParser().parse(bytes: callbackURL.bytes).path
        callbackPath = callbackPath != "/" ? callbackPath : callbackURL
        
        droplet.get(callbackPath, handler: callback)
        droplet.get(authURL, handler: authenticate)
    }
}


