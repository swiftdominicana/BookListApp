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
    //loadData()
  }
  
  private func loadData() {
    //data = fetchBooks()
    self.tableView.reloadData()
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //return data.count
    let sectionInfo = fetchedResultsController?.sections![section]
    return sectionInfo?.numberOfObjects ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
    
    //let book = data[indexPath.row]
    let book = fetchedResultsController!.object(at: indexPath)
    
    configureCell(cell, with: book)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "Eliminar"
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      deleteBook(fetchedResultsController!.object(at:indexPath))
    }
  }
  
  private func configureCell(_ cell: UITableViewCell, with book: Book) {
    cell.textLabel?.text = book.name
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
  
  lazy var fetchedResultsController: NSFetchedResultsController<Book>? = {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return nil
    }
    
    let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context,
                                                sectionNameKeyPath: nil, cacheName: nil)
    
    
    controller.delegate = self
    do {
      try controller.performFetch()
    }
    catch {
      print("Unexpected error \(error)")
    }
    
    return controller
  }()
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

extension BooksTableViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    default:
      return
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .fade)
    case .update:
      configureCell(tableView.cellForRow(at: indexPath!)!,
                    with: anObject as! Book)
    case .move:
      configureCell(tableView.cellForRow(at: indexPath!)!,
                    with: anObject as! Book)
      tableView.moveRow(at: indexPath!, to: newIndexPath!)
    @unknown default:
      fatalError()
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}
