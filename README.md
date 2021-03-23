# Vice

![](https://img.shields.io/badge/platform-macOS%2BiOS%2Blinux-blue)
![](https://img.shields.io/badge/swift-5.3-blue)

A command line tool for resizing png images. The underlying API is also available, should you want to include it in your development projects.

## Usage
To resize to 100 width x 200 height.
```
$ vice ~/Desktop/Filename.png 100 200
```
### Man Page

```
USAGE: vice <file> <width> <height>

ARGUMENTS:
  <file>                  A local image file. 
  <width>                 The target width of the image. 
  <height>                The target height of the image. 

OPTIONS:
  -h, --help              Show help information.
```
### Jaws API
```swift
import Files // github.com:JohnSundell/Files

let output = Folder.home
let file = File(path: "~/myfile.png")
let jaws = Jaws(file: file, width: 100, height: 200)
try jaws.resize()
```
## Installation
Install [Swift](https://swift.org/getting-started/) (at least version 5.3) then run the following commands.
```
$ git clone https://github.com/nashysolutions/Vice.git
$ cd Vice
$ swift build -c release
$ cd .build/release
$ cp -f vice /usr/local/bin/vice
```
If you have any issues with unix directories [this article](https://superuser.com/questions/717663/permission-denied-when-trying-to-cd-usr-local-bin-from-terminal) might be helpful.

## Adding underlying `Jaws` API as a Dependency

```swift
let package = Package(
    platforms: [
        .iOS(.v13), 
        .macOS(.v10_13)
    ]
    dependencies: [
        .package(name: "Vice", url: "https://github.com/nashysolutions/Vice.git", .upToNextMinor(from: "1.0.0"))
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

