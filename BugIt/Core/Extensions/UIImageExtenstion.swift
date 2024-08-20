import UIKit

extension UIImage {
    func compressTo(maxSizeInKB: Int) -> Data? {
        let maxSizeInBytes = maxSizeInKB * 1024
        var compression: CGFloat = 1.0
        guard var imageData = self.jpegData(compressionQuality: compression) else { return nil }

        // Reduce the quality of the image until the size is below the maximum
        while imageData.count > maxSizeInBytes && compression > 0 {
            compression -= 0.1
            if let compressedData = self.jpegData(compressionQuality: compression) {
                imageData = compressedData
            } else {
                return nil
            }
        }

        return imageData
    }
}
