import Foundation

#if canImport(UIKit)
import UIKit

/// Platform image type used by image-loading infrastructure on iOS-family platforms.
typealias AppPlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit

/// Platform image type used by image-loading infrastructure on macOS package tests.
typealias AppPlatformImage = NSImage
#endif
