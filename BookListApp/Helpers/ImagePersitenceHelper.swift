import Foundation
import UIKit

class ImagePersistenceHelper {
  private let fileManager = FileManager.default
  
  func loadImage(imageURL url:URL) -> UIImage? {
    if let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
      let file = docs.appendingPathComponent(url.lastPathComponent)
      if let image = UIImage(contentsOfFile: file.path){
        return image
      }
    }
    return nil
  }
  
  func saveImage(_ image: UIImage, compression: CGFloat = 1.0) -> URL? {
    if let docs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
      let fileName = UUID().uuidString
      let filePath = docs.appendingPathComponent(fileName)
      if let photoData = image.jpegData(compressionQuality: compression) {
        try! photoData.write(to: filePath)
      }
      return filePath
    }
    
    return nil
  }
}
