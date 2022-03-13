import AVFoundation
import Files

#if canImport(UIKit)
import UIKit
#endif

public struct Jaws {
    
    public enum Error: Swift.Error {
        case missing(URL), targetSize, resizing
    }
    
    let file: File
    let targetSize: CGSize
    let maintainRatio: Bool
    
    public init(url: URL, targetSize: CGSize, maintainRatio: Bool) throws {
        let file = try File(path: url.path)
        self.init(file: file, targetSize: targetSize, maintainRatio: maintainRatio)
    }
    
    public init(file: File, targetSize: CGSize, maintainRatio: Bool) {
        self.file = file
        self.targetSize = targetSize
        self.maintainRatio = maintainRatio
    }
    
    func establishSize(for image: CGImage) -> CGSize {
        if !maintainRatio {
            return targetSize
        }
        let rect = CGRect(origin: .zero, size: targetSize)
        let aspectRect = AVMakeRect(aspectRatio: image.size, insideRect: rect)
        return aspectRect.size
    }
    
    /**
     Redraws the image.
     - Parameter save: Should save by overwriting original location on disk.
     - Throws: `Jaws.Error`, `Files.WriteError`
     - Returns: A new string saying hello to `recipient`.
     */
    @discardableResult
    public func resize(save: Bool = true) throws -> CGImage {
        
        guard let image = file.loadImage() else {
            throw Error.missing(file.url)
        }
        
        let targetSize = establishSize(for: image)

        guard let context = CGContext.make(size: targetSize) else {
            throw Error.targetSize
        }
        
        let rect = CGRect(origin: .zero, size: targetSize)
        context.draw(image, in: rect)

        guard let resizedImage = context.makeImage() else {
            throw Error.resizing
        }

        if save {
            try file.save(resizedImage)
        }
        
        return resizedImage
    }
}

private extension File {
    
    func save(_ image: CGImage) throws {
        #if canImport(AppKit)
        let imageData = CFDataCreateMutable(nil, 0)!
        let imageDestination = CGImageDestinationCreateWithData(imageData, kUTTypePNG, 1, nil)!
        CGImageDestinationAddImage(imageDestination, image, nil)
        CGImageDestinationFinalize(imageDestination)
        try write(imageData as Data)
        #elseif canImport(UIKit)
        let data = UIImage(cgImage: image).pngData()!
        try write(data)
        #endif
    }
    
    func loadImage() -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }
}

private extension CGImage {
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    var isLandscape: Bool {
        size.width > size.height
    }
}

private extension CGSize {
    
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
        case .missing(let url):
            return "💥  Cannot find image at '\(url.path)'"
        case .targetSize:
            return "💥  Invalid target size"
        case .resizing:
            return "💥  Failed to resize image"
        }
    }
}
