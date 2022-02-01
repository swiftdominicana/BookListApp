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
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func getBooks(completion: @escaping (_ success: Bool) -> Void) {
    guard let url = URL(string: apiURL) else {
      completion(false)
      return
    }

    let session = URLSession.shared
    let task = session.dataTask(with: url) { (data, _, error) in
      guard let unWrappedData = data, error == nil else {
        completion(false)
        return
      }
      
      let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      childContext.parent = self.context

      guard let json = try? JSONSerialization.jsonObject(with: unWrappedData) as? [[String: Any]] else {
        completion(false)
        return
      }

      let sanitizedJson = json.map { item -> [String: Any] in
        var copyItem = item
        copyItem["coverImageUrl"] = NSURL(string: item["coverImageUrl"] as! String)
        return copyItem as [String: Any]
      }

      childContext.perform {
        let insertRequest = NSBatchInsertRequest(entity: Book.entity(), objects: sanitizedJson)
        _ = try? childContext.execute(insertRequest)
        try? childContext.save()
        completion(true)
      }
    }
    
    task.resume()
  }
}
