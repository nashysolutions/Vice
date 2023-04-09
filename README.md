# Vice

![iOS](https://img.shields.io/badge/iOS-14%2B-blue)
![macOS](https://img.shields.io/badge/macOS-11%2B-blue)

## Products

* A macOS command line tool for resizing png images. 
* An iOS library for resizing png images.

## Usage: Command Line Tool

To resize to 100 width x 200 height.
```
$ vice ~/Desktop/Filename.png 100 200
```
To maintain aspect ratio
```
$ vice -r ~/Desktop/Filename.png 100 9999
```

See man page for more details.

### Usage: iOS Library

The underlying core library is also available as a product (see installation below).

```swift
import Files // github.com:JohnSundell/Files
import Jaws

let file = try File(path: "~/myfile.png")
let targetSize = CGSize(width: width, height: height)
let jaws = Jaws(file: file, targetSize: targetSize, maintainRatio: false)
try jaws.resize()
```
## Installation

### Vice Command Line Tool
```
$ git clone https://github.com/nashysolutions/Vice.git
$ cd Vice
$ swift run task install
```

If you have any issues with unix directories [this article](https://superuser.com/questions/717663/permission-denied-when-trying-to-cd-usr-local-bin-from-terminal) might be helpful.

### iOS Library

```swift
let package = Package(
    name: "MyTool",
    products: [
        .executable(name: "tool", targets: ["MyTool"]),
    ],
    dependencies: [
        .package(name: "Vice", url: "https://github.com/nashysolutions/Vice.git", .upToNextMinor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "MyTool", 
            dependencies: [
                .product(name: "Jaws", package: "Vice")
            ])
    ]
)
```
[Swift 5.3](https://swift.org/blog/swift-5-3-released/) only knows how to skip dependencies not used by *any* product, which in this package is none. This is a limitation at the moment with the Swift package manager.

As a result, if you mark your target as depending on the `Jaws` product, Swift will download all the source for all the dependencies in this package. 

Further, the entire `Vice` package will be downloaded so that files such as the README and other such documentation is available.

That being said, only the source required for `Jaws` will be compiled.

See [thread](https://forums.swift.org/t/package-issue-unnecessary-dependencies-and-wrong-name/46952) on Swift forum.
