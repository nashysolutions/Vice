import Foundation
import Files
import Jaws
import ArgumentParser

extension Folder: ExpressibleByArgument {
    
    public init?(argument: String) {
        try? self.init(path: argument)
    }
}

extension File: ExpressibleByArgument {
    
    public init?(argument: String) {
        try? self.init(path: argument)
    }
}

public struct Vice: ParsableCommand {
        
    public init() {}
    
    @Argument(help: "A local image file.")
    public var file: File
    
    @Argument(help: "The target width of the image.")
    public var width: Int
    
    @Argument(help: "The target height of the image.")
    public var height: Int
    
    @Flag(name: .shortAndLong, help: "Maintain aspect ratio")
    public var ratio: Bool = false

    mutating public func run() throws {
        let targetSize = CGSize(width: width, height: height)
        var jaws = Jaws(file: file, targetSize: targetSize, maintainRatio: ratio)
        try jaws.resize()
    }
}

Vice.main()
