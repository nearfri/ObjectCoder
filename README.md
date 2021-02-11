# ObjectCoder
[![SwiftPM](https://github.com/nearfri/ObjectCoder/workflows/Swift/badge.svg)](https://github.com/nearfri/ObjectCoder/actions?query=workflow%3ASwift)


Swift Object Encoder/Decoder compatible with UserDefaults

## Usage
```swift
import ObjectCoder

// Encode
let frame: CGRect = CGRect(x: 10.0, y: 20.0, width: 30.0, height: 40.0)
let encoded: Any = try ObjectEncoder().encode(frame)
let rawValue: [[Double]] = try XCTUnwrap(encoded as? [[Double]])
XCTAssertEqual(rawValue, [[10.0, 20.0], [30.0, 40.0]])

// Set to and get from UserDefaults
let defaults = UserDefaults.standard
defaults.set(encoded, forKey: "frame")
let object: Any = try XCTUnwrap(defaults.object(forKey: "frame"))

// Decode
let decodedFromEncoded: CGRect = try ObjectDecoder().decode(CGRect.self, from: encoded)
let decodedFromDefaults: CGRect = try ObjectDecoder().decode(CGRect.self, from: object)
XCTAssertEqual(decodedFromEncoded, frame)
XCTAssertEqual(decodedFromDefaults, frame)
```

## Install

#### Swift Package Manager
```
.package(url: "https://github.com/nearfri/ObjectCoder", from: "1.0.0")
```

## License
Preferences is released under the MIT license. See [LICENSE](https://github.com/nearfri/ObjectCoder/blob/master/LICENSE) for more information.
