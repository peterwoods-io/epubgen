import Foundation





class epubgen {
    
    // MARK: - Public
    
    func generateEpub(withConfig configFileURL: URL, completion: @escaping (Void) -> Void) {
        self.completion = completion
        self.sourceDirectory = configFileURL.deletingLastPathComponent()
        self.configFilename = configFileURL.lastPathComponent
        textFileReader.readTextFile(at: configFileURL) { (configString: String?, error: Error?) in
            guard let configString = configString else {
                Output.printStdErr(message: "Failed reading config: \(error as Optional)")
                Output.printStdErr(message: "Aborting.")
                return
            }
            
            Output.printStdOut(message: "Config read")
            self.parseConfig(configString: configString)
        }
    }
    
    
    
    
    
    // MARK: - Private
    
    let dispatchQueue = DispatchQueueFactory.CreateDispatchQueue(component: "generator")
    let textFileReader = TextFileReader()
    let configFileParser = ConfigFileParser()
    let fileFinder = FileFinder()
    
    var sourceDirectory = URL(fileURLWithPath: Constants.bundleId, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
    var configFilename = "epubgen.cfg"
    var config = Config()
    var filesToProcess = [URL]()
    var filesToInclude = [EpubFileInclude]()
    var completion: ((Void) -> Void)?
    
    fileprivate func parseConfig(configString: String) {
        configFileParser.parse(configFile: configString) { (config: Config) in
            Output.printStdOut(message: "Config parsed")
            self.config = config
            self.findFiles(at: self.sourceDirectory)
        }
    }
    
    fileprivate func findFiles(at fileURL: URL) {
        fileFinder.listFilesIncludingSubdirectories(at: fileURL, completion: { (fileURLs, error) in
            if error != nil {
                self.finish()
                return
            }
            
            Output.printStdOut(message: "Found \(fileURLs.count) files")
            self.filesToProcess = fileURLs
            self.generateEpub()
        })
    }
    
    fileprivate func generateEpub() {
        Output.printStdOut(message: "Generating package")
        dispatchQueue.async {
            let epub = Epub()
            
            self.processMetadata(config: self.config, epub: epub)
            self.processFiles(files: self.filesToProcess, tocEntries: self.config.tocEntries, epub: epub)
            
            let tocXhtmlId = ContentOpf.createItemUUID()
            epub.contentOpf.manifest.addNavItem(id: tocXhtmlId, href: "toc.xhtml", mediaType: MimeTypes.xhtml)
            
            do {
                let tempDir = try TemporaryDirectory.create()
                let writer = EpubWriter(epub: epub, destination: tempDir.url, filesToInclude: self.filesToInclude)
                writer.write(completion: { (error) in
                    Output.printStdOut(message: "Created package at \(tempDir.url.path)")
                    self.finish()
                })
            } catch {
                Output.printStdErr(message: "\(error)")
                self.finish()
            }
        }
    }
    
    fileprivate func processMetadata(config: Config, epub: Epub) {
        epub.contentOpf.metadata.dcCreator = config.author
        epub.contentOpf.metadata.dcDate = config.date
        epub.contentOpf.metadata.dcDescription = config.bookDescription
        epub.contentOpf.metadata.dcIdentifier = config.identifier
        epub.contentOpf.metadata.dcLanguage = config.language
        epub.contentOpf.metadata.dcRights = config.copyright
        epub.contentOpf.metadata.dcTitle = config.title
        epub.tocXhtml.title = config.title
    }
    
    /**
     Processes the files found by FileFinder and adds them to the package
     
     - ToDo: Support for files in subfolders of the package. Currently the file-name (lastPathComponent) is used as the
         item's href-value. If a file is located in a subfolder, the href will be broken.
     */
    fileprivate func processFiles(files: [URL], tocEntries: [String: String], epub: Epub) {
        let sortedFiles = files.sorted(by: { (url1, url2) -> Bool in
            return url1.lastPathComponent.localizedStandardCompare(url2.lastPathComponent) == ComparisonResult.orderedAscending
        })
        
        for fileURL in sortedFiles {
            guard fileURL.lastPathComponent != self.configFilename else {
                continue
            }
            
            var includeFile = true
            
            let fullFileName = fileURL.lastPathComponent
            let fileName = fileURL.deletingPathExtension().lastPathComponent
            let fileExtension = fileURL.pathExtension
            let itemId = ContentOpf.createItemUUID()
            
            if fileExtension == FileExtensions.xhtml {
                epub.contentOpf.spine.addItemref(idref: itemId)
                
                if let tocEntry = tocEntries[fullFileName] {
                    epub.tocXhtml.addTocEntry(name: tocEntry, fileName: fullFileName)
                }
            }
            
            if fileExtension == FileExtensions.md {
                includeFile = false
                
                var title = fileName
                if let tocEntry = tocEntries[fullFileName] {
                    title = tocEntry
                }
                
                do {
                    let markdown = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
                    let html = Markdown.converter.convertMarkdownToHtml(markdown: markdown)
                    let xhtmlDocument = XhtmlDocument(filename: "\(fileName).xhtml", title: title, styleHref: config.style, body: html)
                    Output.printStdOut(message: "Converted \(fullFileName)")
                    epub.add(xhtmlDocument: xhtmlDocument, tocTitle: title)
                } catch let error {
                    Output.printStdErr(message: "Failed to convert Markdown-file at\n    \(fileURL)\n\(error)")
                    continue
                }
            }
            
            if fullFileName == config.coverImageFilePath {
                epub.contentOpf.metadata.coverItemRef = itemId;
            }
            
            if includeFile {
                epub.contentOpf.manifest.addItem(id: itemId, href: fullFileName, mediaType: FileTypes.getMimeType(forPathExtension: fileExtension))
                filesToInclude.append(EpubFileInclude(fileAt: fileURL, pathInPackage: fullFileName))
            }
        }
    }
    
    fileprivate func finish() {
        completion?()
    }
    
}































