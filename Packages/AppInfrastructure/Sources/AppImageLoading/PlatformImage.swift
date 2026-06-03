import Foundation

#if canImport(UIKit)
import UIKit

/// Platform image type used by image-loading infrastructure on iOS-family platforms.
public typealias AppPlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit

/// Platform image type used by image-loading infrastructure on macOS package tests.
public typealias AppPlatformImage = NSImage
#endif
