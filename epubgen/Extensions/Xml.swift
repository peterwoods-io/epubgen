#if os(Linux)
import FoundationXML

internal typealias XMLNode = FoundationXML.XMLNode
internal typealias XMLElement = FoundationXML.XMLElement
internal typealias XMLDocument = FoundationXML.XMLDocument
#else
import Foundation
#endif





extension XMLElement {
    
    internal convenience init(name: String, children: [XMLNode]?, attributes: [XMLNode]?) {
        self.init(name: name)
        
        self.setChildren(children)
        self.attributes = attributes
    }
    
    internal convenience init(name: String, stringValue: String, attributes: [XMLNode]?) {
        self.init(name: name)
        
        self.setStringValue(stringValue, resolvingEntities: false)
        self.setChildren(children)
        self.attributes = attributes
    }
    
    internal convenience init(name: String, attributes: [XMLNode]?) {
        self.init(name: name)
        
        self.attributes = attributes
    }
    
}


extension XMLNode {
    
    internal class func attribute(name: String, value: String) -> XMLNode {
        guard let attribute = XMLNode.attribute(withName: name, stringValue: value) as? XMLNode else {
            let attribute = XMLNode(kind: XMLNode.Kind.attribute)
            attribute.name = name
            attribute.stringValue = value
            return attribute
        }
        return attribute
    }
    
}



























