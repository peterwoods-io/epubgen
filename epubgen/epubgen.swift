import Foundation

public protocol epubgen {
    func generateEpub(withConfig configFileURL: URL, completion: @escaping () -> Void)
}






























