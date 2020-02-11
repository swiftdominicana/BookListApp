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
  private let apiURL = "https://firebasestorage.googleapis.com/v0/b/booksusj.appspot.com/o/books.json?alt=media&token=5135b755-78c3-479a-8491-bcd2367686e2"
  
  private var context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func getBooks(completion: @escaping (_ success: Bool) -> Void) {
    guard
      let url = URL(string: apiURL) else {
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
            
      if let json = try? JSONSerialization.jsonObject(with: unWrappedData) as? [[String: Any]] {
        childContext.perform {
          let insertRequest = NSBatchInsertRequest(entity: Book.entity(), objects: json)
          try! childContext.execute(insertRequest)
          try! childContext.save()
          completion(true)
        }
      }
      else {
        completion(false)
      }
    }
    
    task.resume()
  }
}
