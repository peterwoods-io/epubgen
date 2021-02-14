//
//  ZIPFoundationEpubPacker.swift
//
//  Created by Peter Woods on 11/22/20.
//

import Foundation
import ZIPFoundation



/**
 A wrapper-class for a ZIPFoundation-based EPUB-packer
 */
class ZIPFoundationEpubPacker: EpubPacker {

    // MARK: - EpubPacker

    /**
     Packs the epub-package at the given packageUrl to the given destination-URL

     - Parameter packageUrl: The url to the directory containing the EPUB-package.
     - Parameter destination: The url of the EPUB-file to create.
     - Parameter completion: Will be executed after packing or in case of error.
     - Parameter error: Contains an error, if any error occurred while packing.
     */
    func packPackage(at packageUrl: URL, to destination: URL, completion: @escaping (_ error: Error?) -> Void) {
        dispatchQueue.async {
            do {
                guard let archive = Archive(url: destination, accessMode: .create) else {
                    fatalError()
                }
                
                try self.createArchiveEntryForMimetypeFileOfPackageZ(at: packageUrl, in: archive)
                
                self.createArchiveEntriesForFilesInPackageZ(at: packageUrl, in: archive) { (error) in
                    completion(error)
                }
            } catch {
                completion(error)
            }
        }
    }





    // MARK: - Private

    let dispatchQueue = DispatchQueueFactory.CreateDispatchQueue(component: "ZIPFoundationEpubPacker")

    fileprivate func createArchiveEntryForMimetypeFileOfPackageZ(at packageUrl: URL, in archive: Archive) throws {
        let mimetypeUrl = packageUrl.appendingPathComponent("mimetype")
        let mimetypeData = try Data(contentsOf: mimetypeUrl)
        try archive.addEntry(with: mimetypeUrl.lastPathComponent,
                             type: .file,
                             uncompressedSize: UInt32(mimetypeData.count),
                             compressionMethod: .none,
                             provider: { _,_ in mimetypeData })
    }
    
    fileprivate func createArchiveEntriesForFilesInPackageZ(at packageUrl: URL, in archive: Archive, completion: @escaping (Error?) -> Void) {
        let fileFinder = FileFinder()
        fileFinder.listFilesIncludingSubdirectories(at: packageUrl) { (fileUrls, error) in
            if let error = error {
                completion(error)
                return
            }
            
            do {
                try self.createArchiveEntriesZ(for: fileUrls, in: archive)
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    fileprivate func createArchiveEntriesZ(for fileUrls: [URL], in archive: Archive) throws {
        for fileUrl in fileUrls {
            if fileUrl.lastPathComponent == "mimetype" {
                continue
            }
            
            let fileData = try Data(contentsOf: fileUrl)
            
            try archive.addEntry(with: fileUrl.relativePath,
                                 type: .file,
                                 uncompressedSize: UInt32(fileData.count),
                                 compressionMethod: .none,
                                 provider: { (position, size) in
                                    return fileData.subdata(in: position..<position+size)
                                 })
        }
    }

}
