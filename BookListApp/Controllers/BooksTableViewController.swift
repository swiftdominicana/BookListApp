//
//  BooksTableViewController.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 03/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import UIKit
import CoreData

class BooksTableViewController: UITableViewController {
  private var data = [Book]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRefreshControl()
    loadData()
  }
  
  private func loadData() {
    data = fetchBooks()
    self.tableView.reloadData()
    self.tableView.refreshControl?.endRefreshing()
  }
  
  private func setupRefreshControl() {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    self.tableView.refreshControl = refreshControl
  }
  @objc
  private func refreshData(_ sender: UIRefreshControl){
    sender.beginRefreshing()
    loadData()
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
    
    let book = data[indexPath.row]
    cell.textLabel?.text = book.name
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "Eliminar"
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      deleteBook(data[indexPath.row])
      data.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  @IBAction func addBookButtonTapped(_ sender: Any) {
    let alert = UIAlertController(title: "Agregar Nuevo Libro", message: "Ingrese el nombre del libro", preferredStyle: .alert)
    
    alert.addTextField { (textField) in
      textField.placeholder = "Nombre del libro"
    }
    
    let alertOkAction = UIAlertAction(title: "Agregar", style: .default) { [weak self] _ in
      if let bookName = alert.textFields?.first?.text {
        self?.insertBook(name: bookName)
      }
    }
    
    let alertCancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
    
    alert.addAction(alertOkAction)
    alert.addAction(alertCancelAction)
    
    present(alert, animated: true)
  }
}

// MARK: - Core Data Logic
extension BooksTableViewController {
  func insertBook(name: String) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }
    
    if let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book",
                                                         into: context) as? Book {
      newBook.name = name
      
      do {
        try context.save()
      }
      catch {
        print("Unexpected error: \(error).")
      }
    }
  }
  
  func fetchBooks() -> [Book] {
    var books = [Book]()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return books
    }
    
    let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
    
    do {
      books = try context.fetch(fetchRequest)
    }
    catch {
      print("Unexpected error")
    }
    
    return books
  }
  
  func deleteBook(_ book: Book) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }
    
    context.delete(book)
    do {
      try context.save()
    }
    catch {
      print("Unexpected error")
    }
  }
  
  
}
