import Vapor

internal(set) var droplet: Droplet!

public class ShopifyProvider: Vapor.Provider {
    public static var repositoryName: String = "ShopifyImperial"
    
    public func boot(_ drop: Droplet) throws {
        droplet = drop
    }

    public func boot(_ config: Config) throws {
        
        guard let imperial = config["imperial"]?.object else {
            return
        }
        
        if let shopifyID = imperial["shopify_client_id"]?.string,
            let shopifySecret = imperial["shopify_client_secret"]?.string {
            ShopifyImperialConfig.clientID = shopifyID
            ShopifyImperialConfig.secret = shopifySecret
        }
    }
    
    public func beforeRun(_ droplet: Droplet) throws {}
    public required init(config: Config) throws {}    
}

internal struct ShopifyImperialConfig {
    internal fileprivate(set) static var clientID: String?
    internal fileprivate(set) static var secret: String?
}
