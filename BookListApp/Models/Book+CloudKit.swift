//
//  Book+CloudKit.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 20/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit

extension Book {
  static func fetchAll(in context: NSManagedObjectContext, _ completion:(()->Void)?) {
    var lastDate = UserDefaults.standard.value(forKey: "LAST_DATE") as? Date
    
    var bgTask: UIBackgroundTaskIdentifier = .invalid;
    bgTask = UIApplication.shared.beginBackgroundTask(withName:"DownloadBooks") {
      UIApplication.shared.endBackgroundTask(bgTask)
      bgTask = .invalid
    }
    
    let db = CKContainer.default().publicCloudDatabase
    
    var predicate: NSPredicate = NSPredicate(value: true)
    if let lastDate = lastDate {
      predicate = NSPredicate(format: "creationDate > %@", lastDate as NSDate)
    }
    
    let tempContext = NSManagedObjectContext(concurrencyType:
      .privateQueueConcurrencyType)
    tempContext.parent = context
    
    let query = CKQuery(recordType: "BookCK", predicate: predicate)
    query.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true)]
    
    func perRecord(_ record: CKRecord) {
      lastDate = record.creationDate
      
      tempContext.perform {
        let recordName = record.recordID.recordName
        let req = NSFetchRequest(entityName: "Book") as NSFetchRequest<Book>
        req.predicate = NSPredicate(format: "recordName == %@", recordName)
        
        guard let results = try? tempContext.fetch(req),
          results.isEmpty  else {
            return
        }
        
        let newBook = Book(context: tempContext)
        
        if let name = record["name"] as? NSString {
          newBook.name = name as String
        }
        
        if let author = record["author"] as? NSString {
          newBook.author = author as String
        }
        
        newBook.createdAt = record.creationDate
        newBook.recordName = record.recordID.recordName
        
        if let asset = record["coverImage"] as? CKAsset {
          newBook.coverImageUrl = asset.fileURL
        }
      }
    }
    
    func completionBlock(cursor: CKQueryOperation.Cursor?, error: Error?) {
      tempContext.perform {
        if(tempContext.hasChanges) {
          try? tempContext.save()
          if let parent = tempContext.parent {
            parent.perform {
              try? parent.save()
            }
          }
        }
      }
      
      if cursor != nil {
        let newOp = CKQueryOperation(cursor: cursor!)
        newOp.recordFetchedBlock = perRecord
        newOp.queryCompletionBlock = completionBlock
        db.add(newOp)
      } else {
        if let lastDate = lastDate {
          UserDefaults.standard.set(lastDate, forKey: "LAST_DATE")
        }
        
        if let completion = completion {
          completion()
        }
        
        DispatchQueue.main.async {
          if bgTask != .invalid {
            UIApplication.shared.endBackgroundTask(bgTask)
          }
        }
      }
    }
    
    let queryOp = CKQueryOperation(query: query)
    queryOp.recordFetchedBlock = perRecord
    queryOp.queryCompletionBlock = completionBlock
    
    db.add(queryOp)
  }
  
  func deleteFromCloudKit() {
    let db = CKContainer.default().publicCloudDatabase
    let recordId = CKRecord.ID(recordName: self.recordName!)
    
    db.delete(withRecordID: recordId) { (_, error) in
      guard error == nil else {
        print(error!)
        return
      }
      print("Book removed from CloudKit")
    }
  }
  
  func updateOnCloudKit(completion: @escaping (CKRecord?, Error?) -> Void) {
    let db = CKContainer.default().publicCloudDatabase
    let recordId = CKRecord.ID(recordName: self.recordName!)
    db.fetch(withRecordID: recordId) {[weak self]  (record, error) in
      guard error == nil, let record = record else {
        print(error!)
        return
      }
      
      self?.saveOnCloudKit(record: record){ (result, error) in
        completion(result, error)
      }
    }
  }
  
  func createOnCloudKit(completion: @escaping (CKRecord?, Error?) -> Void) {
    let record = CKRecord(recordType: "BookCK")
    
    saveOnCloudKit(record: record){ (record, error) in
      completion(record, error)
    }
  }
  
  func saveOnCloudKit(record: CKRecord, completion: @escaping (CKRecord?, Error?) -> Void){
    record["name"] = self.name as NSString?
    record["author"] = self.author as NSString?
    
    if let coverImageUrl = coverImageUrl,
      let fullImage = ImagePersistenceHelper().loadImage(imageURL: coverImageUrl) {
      record["coverImage"] = CKAsset(image: fullImage, compression: 0.4)
    }
    
    let db = CKContainer.default().publicCloudDatabase
    db.save(record) { (record, error) in
      completion(record, error)
    }
  }
}

