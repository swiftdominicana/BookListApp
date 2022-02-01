//
//  BookService.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 10/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct BookService {
  private let apiURL = "https://firebasestorage.googleapis.com/v0/b/fir-swift-4372e.appspot.com/o/books.json?alt=media&token=e4b68cd7-49e1-4a7a-acb3-5ec65dd043b7"
  private var context: NSManagedObjectContext
  private let DATA_DOWNLOADED_KEY = "DATA_DOWNLOADED_KEY"
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }

  func getBooks(completion: @escaping (_ success: Bool) -> Void) {
    //TODO
  }
}


private extension BookService {
  func saveData(_ data: Data, completion: @escaping (_ success: Bool) -> Void) {
    //TODO
  }

  func sanitizeJSON(_ json: [[String : Any]]) -> [[String : Any]] {
    return json.compactMap { item -> [String: Any]? in
      guard let urlString = item["coverImageUrl"] as? String,
            let url = NSURL(string: urlString) else {
              return nil
            }

      var copyItem = item
      copyItem["coverImageUrl"] = url
      return copyItem as [String: Any]
    }
  }
}
