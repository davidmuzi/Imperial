import Vapor
import URI

/// Defines a type that implements the routing to get an access token from an OAuth provider.
/// See implementations in the `Services/(Google|GitHub)/$0Router.swift` files
public protocol FederatedServiceRouter {
    
    /// A class that gets the client ID and secret from environment variables.
    var tokens: FederatedServiceTokens { get }
    
    /// The callback that is fired after the access token is fetched from the OAuth provider.
    /// The response that is returned from this callback is also returned from the callback route.
    var callbackCompletion: (String) -> (ResponseRepresentable) { get }
    
    /// The scopes to get permission for when getting the access token.
    /// Usage of this property varies by provider.
    var scope: [String] { get set }
    
    /// The URL (or URI) for that route that the provider will fire when the user authenticates with the OAuth provider.
    var callbackURL: String { get }
    
    /// The URL on the app that will redirect to the `authURL` to get the access token from the OAuth provider.
    var accessTokenURL: String { get }
    
    /// The URL of the page that the user will be redirected to to get the access token.
    var authURL: String { get }
    
    /// Configures the `authenticate` and `callback` routes with the droplet.
    ///
    /// - Parameter authURL: The URL for the route that will redirect the user to the OAuth provider.
    /// - Throws: N/A
    func configureRoutes(withAuthURL authURL: String)throws
    
    
    /// The route to call when the user is going to authenticate with the OAuth provider.
    /// By default, this route redirects the user to `authURL`.
    ///
    /// - Parameter request: The request from the browser.
    /// - Returns: A response that, by default, redirects the user to `authURL`.
    /// - Throws: N/A
    func authenticate(_ request: Request)throws -> ResponseRepresentable
    
    /// The route that the OAuth provider calls when the user has been authenticated.
    ///
    /// - Parameter request: The request from the OAuth provider.
    /// - Returns: A response that should redirect the user back to the app.
    /// - Throws: An errors that occur in the implementation code.
    func callback(_ request: Request)throws -> ResponseRepresentable
}

extension FederatedServiceRouter {
    public func authenticate(_ request: Request)throws -> ResponseRepresentable {
        return Response(redirect: authURL)
    }
    
    public func configureRoutes(withAuthURL authURL: String) throws {
        var callbackPath = URIParser().parse(bytes: callbackURL.bytes).path
        callbackPath = callbackPath != "/" ? callbackPath : callbackURL
        
        drop.get(callbackPath, handler: callback)
        drop.get(authURL, handler: authenticate)
    }
}
