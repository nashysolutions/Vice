import AVFoundation
import Files
import ImageIO
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#endif

public struct Jaws {
    public enum Error: Swift.Error {
        case missing(URL), targetSize, resizing, decoding
    }
    
    private let file: File
    private let targetSize: CGSize
    private let maintainRatio: Bool
    
    public init(url: URL, targetSize: CGSize, maintainRatio: Bool) throws {
        let file = try File(path: url.path)
        self.init(file: file, targetSize: targetSize, maintainRatio: maintainRatio)
    }
    
    public init(file: File, targetSize: CGSize, maintainRatio: Bool) {
        self.file = file
        self.targetSize = targetSize
        self.maintainRatio = maintainRatio
    }
    
    private func establishSize(for image: CGImage) -> CGSize {
        if !maintainRatio {
            return targetSize
        }
        let rect = CGRect(origin: .zero, size: targetSize)
        let aspectRect = AVMakeRect(aspectRatio: image.size, insideRect: rect)
        return aspectRect.size
    }
    
    /**
     Loads the image from disk and then redraws the image to targetSize.
     - Parameter save: Should save by overwriting original location on disk.
     - Throws: `Jaws.Error`, `Files.WriteError`
     - Returns: A new string saying hello to `recipient`.
     */
    @discardableResult
    public mutating func resize(save: Bool = true) async throws -> CGImage {
        guard let image = await file.loadImage() else {
            throw Error.missing(file.url)
        }
        
        let targetSize = establishSize(for: image)
        let resizedImage: CGImage
        if image.isPortrait, targetSize.isThumbnail {
            resizedImage = try resizeWithImageIO(targetSize)
        } else {
            resizedImage = try await resizeWithCoreGraphics(image, targetSize)
        }
        
        if save {
            try file.save(resizedImage)
        }
        
        return resizedImage
    }
    
    private func resizeWithCoreGraphics(_ image: CGImage, _ targetSize: CGSize) async throws -> CGImage {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    guard let context = CGContext.make(size: targetSize) else {
                        throw Error.targetSize
                    }
                    
                    let rect = CGRect(origin: .zero, size: targetSize)
                    context.draw(image, in: rect)
                    
                    guard let resizedImage = context.makeImage() else {
                        throw Error.resizing
                    }
                    
                    continuation.resume(returning: resizedImage)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func resizeWithImageIO(_ targetSize: CGSize) throws -> CGImage {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width, targetSize.height),
        ]
        
        guard
            let imageSource = CGImageSourceCreateWithURL(file.url as NSURL, nil),
            let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            throw Error.resizing
        }
        
        return image
    }
}

private extension File {
    
    func save(_ image: CGImage) throws {
        guard let data = image.pngData else {
            throw Jaws.Error.decoding
        }
        let lock = NSLock()
        try lock.withCriticalSection {
            try write(data)
        }
    }
    
    func loadImage() async -> CGImage? {
        var nsError: NSError?
        return await withUnsafeContinuation { continuation in
            NSFileCoordinator().coordinate(
                readingItemAt: url, options: .withoutChanges, error: &nsError,
                byAccessor: { (newURL: URL) -> Void in
                    if let imageSource = CGImageSourceCreateWithURL(newURL as CFURL, nil) {
                        let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            )
        }
    }
}

private extension CGImage {
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    var isPortrait: Bool {
        size.width < size.height
    }
    
    var pngData: Data? {
#if canImport(UIKit)
        return UIImage(cgImage: self).pngData()
#else
        let data: CFMutableData = CFDataCreateMutable(nil, 0)
        guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, self, nil)
        CGImageDestinationFinalize(destination)
        return data as Data
#endif
    }
}

private extension CGSize {
    var isThumbnail: Bool {
        width < 401 || height < 401
    }
    
    var roundedWidth: Int {
        Int(width.rounded())
    }
    
    var roundedHeight: Int {
        Int(height.rounded())
    }
}

private extension CGContext {
    static func make(size: CGSize) -> CGContext? {
        guard size.width > 0, size.height > 0 else {
            return nil
        }
        return CGContext(
            data: nil,
            width: size.roundedWidth,
            height: size.roundedHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
    }
}

extension Jaws.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .missing(url):
            return "💥  Cannot find image at '\(url.path)'"
        case .targetSize:
            return "💥  Invalid target size"
        case .resizing:
            return "💥  Failed to resize image"
        case .decoding:
            return "There was a problem generating the data. Maybe the underlying CGImageRef contains data in an unsupported bitmap format."
        }
    }
}

extension NSLocking {
    
    func withCriticalSection<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
