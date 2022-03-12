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
    let targetSize: Size
    let maintainRatio: Bool
    
    public init(url: URL, targetSize: Size, maintainRatio: Bool) throws {
        let file = try File(path: url.path)
        self.init(file: file, targetSize: targetSize, maintainRatio: maintainRatio)
    }
    
    public init(file: File, targetSize: Size, maintainRatio: Bool) {
        self.file = file
        self.targetSize = targetSize
        self.maintainRatio = maintainRatio
    }
    
    func establishSize(for image: CGImage) -> Size {
        if !maintainRatio {
            return targetSize
        }
        let aspectRect = AVMakeRect(aspectRatio: image.size, insideRect: targetSize.rect)
        return aspectRect.size.trimmed
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
        
        context.draw(image, in: targetSize.rect)

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

private extension Size {
    
    var rect: CGRect {
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))
        return CGRect(origin: .zero, size: size)
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
    
    var trimmed: Size {
        Size(width: Int(width.rounded()), height: Int(height.rounded()))
    }
}

private extension CGContext {
    
    static func make(size: Size) -> CGContext? {
        guard size.width > 0, size.height > 0 else {
            return nil
        }
        return CGContext(
            data: nil,
            width: size.width,
            height: size.height,
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
