//
//  QuotesTableViewController.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 04/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import UIKit

class QuotesTableViewController: UITableViewController {
  let quotes: NSSet
  
  init?(coder: NSCoder, quotes: NSSet) {
    self.quotes = quotes
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return quotes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
    
    let quote = quotes.allObjects[indexPath.row] as! Quote
    cell.textLabel?.text = "\"\(quote.content!)\""
    
    return cell
  }
}
