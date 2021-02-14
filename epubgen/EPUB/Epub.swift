import Foundation




/**
 The model of an EPUB consisting of in-memory-data.
 
 Additional files can be added to the metadata, but are not managed by an Epub-instance.
 */
public class Epub {
    
    // MARK: - Metadata
    
    let containerXml = ContainerXml(packageFilePath: "OEBPS/content.opf")
    public let contentOpf = ContentOpf()
    let tocXhtml = TocXhtml()
    
    public init() {}
    
    
    
    // MARK: - Content
    
    /**
     The list of XHTML-documents, that belong to the EPUB
     */
    fileprivate(set) var xhtmlDocuments = [XhtmlDocument]()
    
    /**
     Adds the given XHTML-document to the EPUB
     
     All XHTML-documents are added to the spine.
     
     - Parameter xhtmlDocument: The XHTML-document to add to the EPUB.
     - Parameter tocTitle: If not nil, the entry is added to the toc.xhtml.
     */
    public func add(xhtmlDocument: XhtmlDocument, tocTitle: String?) {
        let itemId = ContentOpf.createItemUUID()
        contentOpf.manifest.addItem(id: itemId, href: xhtmlDocument.filename, mediaType: MimeTypes.xhtml)
        contentOpf.spine.addItemref(idref: itemId)
        if let tocTitle = tocTitle {
            tocXhtml.addTocEntry(name: tocTitle, fileName: xhtmlDocument.filename)
        }
        xhtmlDocuments.append(xhtmlDocument)
    }
    
}






























