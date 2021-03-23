import Foundation
import CoreGraphics
import Files

public struct Jaws {
    
    let file: File
    let width: Int
    let height: Int
    
    public init(file: File, width: Int, height: Int) {
        self.file = file
        self.width = width
        self.height = height
    }
    
    public func resize() throws {
        
        let url = file.url

        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            print("💥  Cannot find image at '\(url.path)'")
            exit(1)
        }

        guard let context = CGContext.make(width: width, height: height) else {
            print("💥  Invalid target size")
            exit(1)
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

        guard let resizedImage = context.makeImage() else {
            print("💥  Failed to resize image")
            exit(1)
        }

        let imageData = CFDataCreateMutable(nil, 0)!
        let imageDestination = CGImageDestinationCreateWithData(imageData, kUTTypePNG, 1, nil)!
        CGImageDestinationAddImage(imageDestination, resizedImage, nil)
        CGImageDestinationFinalize(imageDestination)

        try file.write(imageData as Data)
    }
}

private extension CGContext {
    
    static func make(width: Int, height: Int) -> CGContext? {
        guard width > 0, height > 0
        else { return nil }
        return CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
    }
}
