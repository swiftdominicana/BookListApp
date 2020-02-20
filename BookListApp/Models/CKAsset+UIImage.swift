//
//  CKAsset+UIImage.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 20/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

extension CKAsset {
  convenience init(image: UIImage, compression: CGFloat) {
    let fileURL = ImagePersistenceHelper().saveImage(image, compression: compression)
    self.init(fileURL: fileURL!)
  }
  
  var image: UIImage? {
    guard let fileURL = fileURL,
      let data = try? Data(contentsOf: fileURL),
      let image = UIImage(data: data) else {
        
        return nil
    }
    
    return image
  }
}
