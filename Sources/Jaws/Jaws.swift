import AVFoundation
import Files

#if canImport(UIKit)
import UIKit
#endif

public struct Jaws {
    
    let file: File
    let targetSize: Size
    let maintainRatio: Bool
    
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
    
    public func resize() throws {
        
        guard let image = file.loadImage() else {
            print("💥  Cannot find image at '\(file.url.path)'")
            exit(1)
        }
        
        let targetSize = establishSize(for: image)

        guard let context = CGContext.make(size: targetSize) else {
            print("💥  Invalid target size")
            exit(1)
        }
        
        context.draw(image, in: targetSize.rect)

        guard let resizedImage = context.makeImage() else {
            print("💥  Failed to resize image")
            exit(1)
        }

        try file.save(resizedImage)
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
