import UIKit

/// Preloads and caches all Caelus character images in NSCache.
/// Called once on app launch. System can evict under memory pressure.
final class CaelusImageCache {
    static let shared = CaelusImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 30
    }

    /// Preload all mood images into cache. Call from CelestiaApp.init().
    func preloadAll() {
        for mood in CaelusMood.allCases {
            loadImage(named: mood.imageName)
            for variant in 2...mood.variantCount {
                loadImage(named: "\(mood.imageName)_\(variant)")
            }
        }
    }

    /// Retrieve cached image for a mood
    func image(for imageName: String) -> UIImage? {
        if let cached = cache.object(forKey: imageName as NSString) {
            return cached
        }
        return loadImage(named: imageName)
    }

    @discardableResult
    private func loadImage(named name: String) -> UIImage? {
        guard let img = UIImage(named: name) else { return nil }
        cache.setObject(img, forKey: name as NSString)
        return img
    }
}
