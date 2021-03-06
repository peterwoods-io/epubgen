import Foundation





public class ContentOpfMetadata : XmlNodeConvertible {
    
    public var dcCreator = ""
    public var dcDescription = ""
    public var dcIdentifier = ""
    public var dcLanguage = ""
    public var dcRights = ""
    public var dcTitle = ""
    public var dcDate = ""
    public var coverItemRef = ""
    
    
    
    
    
    // MARK: - XmlNodeConvertible
    
    func convertToXmlNode() -> XMLNode {
        let metadataChildren: [XMLNode] = [
            XMLElement(name: "dc:creator", stringValue: dcCreator),
            XMLElement(name: "dc:description", stringValue: dcDescription),
            XMLElement(name: "dc:identifier",
                       stringValue: dcIdentifier,
                       attributes: [XMLNode.attribute(name: "id", value: ContentOpf.uniqueIdentifier)]),
            XMLElement(name: "dc:language", stringValue: dcLanguage),
            XMLElement(name: "dc:rights", stringValue: dcRights),
            XMLElement(name: "dc:title", stringValue: dcTitle),
            XMLElement(name: "dc:date", stringValue: dcDate),
            XMLElement(name: "meta",
                       attributes: [XMLNode.attribute(name: "name", value: "cover"),
                                    XMLNode.attribute(name: "content", value: coverItemRef)]),
            XMLElement(name: "meta",
                       stringValue: dcDate,
                       attributes: [XMLNode.attribute(name: "property", value: "dcterms:modified")]),
            XMLElement(name: "meta",
                       stringValue: "reflowable",
                       attributes: [XMLNode.attribute(name: "property", value: "rendition:layout")]),
            XMLElement(name: "meta",
                       stringValue: "auto",
                       attributes: [XMLNode.attribute(name: "property", value: "rendition:orientation")]),
            XMLElement(name: "meta",
                       stringValue: "auto",
                       attributes: [XMLNode.attribute(name: "property", value: "rendition:spread")])
        ]
        
        return XMLElement(name: "metadata",
                          children: metadataChildren,
                          attributes: [XMLNode.attribute(name: "xmlns:dc", value: "http://purl.org/dc/elements/1.1/")])
    }
    
}






























