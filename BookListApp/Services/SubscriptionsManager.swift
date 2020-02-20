//
//  SubscriptionsManager.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 20/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import CloudKit

struct SubscriptionsManager {
  
  static func checkForSubscriptions(){
    
    let db = CKContainer.default().publicCloudDatabase
    db.fetchAllSubscriptions { (subscriptions, error) in
      guard error == nil, subscriptions != nil else{
        return
      }
      
      if subscriptions!.isEmpty {
        let options:CKQuerySubscription.Options = [.firesOnRecordCreation]
        let subscription = CKQuerySubscription(recordType: "BookCK",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: "NEW_MESSAGE",
                                               options: options)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.soundName = "chan.aiff"
        
        //notificationInfo.titleLocalizationKey = "%1$@"
        //notificationInfo.titleLocalizationArgs = ["name"]
        notificationInfo.title = "Nuevo Libro Agregado"
        
        notificationInfo.alertLocalizationKey = "%1$@ has sido agregado"
        notificationInfo.alertLocalizationArgs = ["name"]
        
        subscription.notificationInfo = notificationInfo
        
        db.save(subscription, completionHandler: { (subscription, error) in
          if (error != nil) {
            debugPrint("ERROR SAVING SUBSCRIPTION: \(String(describing: error))")
          }
          else {
            print("SUBSCRIPTION CREATED")
          }
        })
      }
    }
  }
  
}

