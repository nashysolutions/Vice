import XCTest
import Files
import AppKit
@testable import Jaws

private extension File {
    
    func load() throws -> NSImage? {
        let data = try read()
        return NSImage(data: data)
    }
}

final class JawsTests: XCTestCase {
    
    var testFolder: Folder!
    
    override func setUp() {
        super.setUp()
        testFolder = try! Folder.home.createSubfolder(named: ".sliceTests")
        try! testFolder.empty()
    }
    
    override func tearDown() {
        try? testFolder.delete()
        super.tearDown()
    }
    
    func testIgnoreAspect() async throws {
        let width = 500
        let height = 900
        let targetSize = CGSize(width: width, height: height)
        let path = Bundle.module.path(forResource: "landscape", ofType: "png")
        XCTAssertNotNil(path, "Local resource expected and not found.")
        let file = try File(path: path!).copy(to: testFolder)
        let original = try file.load()
        XCTAssertNotNil(original)
        XCTAssertNotEqual(original?.size, targetSize)
        var jaws = Jaws(file: file, targetSize: .init(width: width, height: height), maintainRatio: false)
        try await jaws.resize()
        let scaled = try file.load()
        XCTAssertNotNil(scaled)
        XCTAssertEqual(scaled?.size, targetSize)
    }
    
    func testIgnoreAspectForThumbnail() async throws {
        let width = 200
        let height = 300
        let targetSize = CGSize(width: width, height: height)
        let path = Bundle.module.path(forResource: "landscape", ofType: "png")
        XCTAssertNotNil(path, "Local resource expected and not found.")
        let file = try File(path: path!).copy(to: testFolder)
        let original = try file.load()
        XCTAssertNotNil(original)
        XCTAssertNotEqual(original?.size, targetSize)
        var jaws = Jaws(file: file, targetSize: .init(width: width, height: height), maintainRatio: false)
        try await jaws.resize()
        let scaled = try file.load()
        XCTAssertNotNil(scaled)
        XCTAssertEqual(scaled?.size, targetSize)
    }
    
    func testLandscape() async throws {
        let width = 500
        let height = 900
        let targetSize = CGSize(width: width, height: height)
        let path = Bundle.module.path(forResource: "landscape", ofType: "png")
        XCTAssertNotNil(path, "Local resource expected and not found.")
        let file = try File(path: path!).copy(to: testFolder)
        let original = try file.load()
        XCTAssertNotNil(original)
        XCTAssertNotEqual(original?.size, targetSize)
        var jaws = Jaws(file: file, targetSize: .init(width: width, height: height), maintainRatio: true)
        try await jaws.resize()
        let scaled = try file.load()
        XCTAssertNotNil(scaled)
        XCTAssertEqual(scaled?.size, CGSize(width: 500, height: 394))
    }
    
    func testLandscapeThumbnail() async throws {
        let width = 200
        let height = 300
        let targetSize = CGSize(width: width, height: height)
        let path = Bundle.module.path(forResource: "landscape", ofType: "png")
        XCTAssertNotNil(path, "Local resource expected and not found.")
        let file = try File(path: path!).copy(to: testFolder)
        let original = try file.load()
        XCTAssertNotNil(original)
        XCTAssertNotEqual(original?.size, targetSize)
        var jaws = Jaws(file: file, targetSize: .init(width: width, height: height), maintainRatio: true)
        try await jaws.resize()
        let scaled = try file.load()
        XCTAssertNotNil(scaled)
        XCTAssertEqual(scaled?.size, CGSize(width: 200, height: 158))
    }
    
    func testPortrait() async throws {
        let width = 500
        let height = 900
        let targetSize = CGSize(width: width, height: height)
        let path = Bundle.module.path(forResource: "portrait", ofType: "png")
        XCTAssertNotNil(path, "Local resource expected and not found.")
        let file = try File(path: path!).copy(to: testFolder)
        let original = try file.load()
        XCTAssertNotNil(original)
        XCTAssertNotEqual(original?.size, targetSize)
        var jaws = Jaws(file: file, targetSize: .init(width: width, height: height), maintainRatio: true)
        try await jaws.resize()
        let scaled = try file.load()
        XCTAssertNotNil(scaled)
        XCTAssertEqual(scaled?.size, CGSize(width: 500, height: 678))
    }
    
    func testPortraitThumbnail() async throws {
        let width = 200
        let height = 300
        let targetSize = CGSize(width: width, height: height)
        let path = Bundle.module.path(forResource: "portrait", ofType: "png")
        XCTAssertNotNil(path, "Local resource expected and not found.")
        let file = try File(path: path!).copy(to: testFolder)
        let original = try file.load()
        XCTAssertNotNil(original)
        XCTAssertNotEqual(original?.size, targetSize)
        var jaws = Jaws(file: file, targetSize: .init(width: width, height: height), maintainRatio: true)
        try await jaws.resize()
        let scaled = try file.load()
        XCTAssertNotNil(scaled)
        XCTAssertEqual(scaled?.size, CGSize(width: 200, height: 271))
    }
    
//    func testPerformancePortrait() throws {
//
//        self.measure {
//            try? await testPortrait()
//        }
//    }
//
//    func testPerformancePortraitThumbnail() throws {
//
//        self.measure {
//            try? await testPortraitThumbnail()
//        }
//    }

    static var allTests = [
        (
            "testIgnoreAspect", testIgnoreAspect,
            "testIgnoreAspectForThumbnail", testIgnoreAspectForThumbnail,
            "testLandscape", testLandscape,
            "testLandscapeThumbnail", testLandscapeThumbnail,
            "testPortrait", testPortrait,
            "testPortraitThumbnail", testPortraitThumbnail
//            "testPerformancePortrait", testPerformancePortrait,
//            "testPerformancePortraitThumbnail", testPerformancePortraitThumbnail
        ),
    ]
}
