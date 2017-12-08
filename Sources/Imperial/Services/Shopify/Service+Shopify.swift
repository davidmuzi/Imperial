import Vapor

extension Service {
    public static let shopify = Service.init(
        name: "shopify",
        model: Shopify.self,
        endpoints: [:]
    )
}

extension Service: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set("name", name)
        return node
    }
}
