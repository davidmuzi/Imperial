import Vapor

public class ShopifyAuth: FederatedServiceTokens {
    public var idEnvKey: String = "SHOPIFY_CLIENT_ID"
    public var secretEnvKey: String = "SHOPIFY_CLIENT_SECRET"
    public var clientID: String
    public var clientSecret: String
    
    public required init() throws {
        let idError = ImperialError.missingEnvVar(idEnvKey)
        let secretError = ImperialError.missingEnvVar(secretEnvKey)
        
        do {
            guard let id = ShopifyImperialConfig.clientID else {
                throw idError
            }
            self.clientID = id
        } catch {
            self.clientID = try Env.get(idEnvKey).value(or: idError)
        }
        
        do {
            guard let secret = ShopifyImperialConfig.secret else {
                throw secretError
            }
            self.clientSecret = secret
        } catch {
            self.clientSecret = try Env.get(secretEnvKey).value(or: secretError)
        }
    }
}

