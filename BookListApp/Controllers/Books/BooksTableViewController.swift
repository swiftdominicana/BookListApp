//
//  BooksTableViewController.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 03/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import UIKit
import CoreData

enum Scope: String, CaseIterable {
  case bookName
  case authorAndBookName = "Name and Author"
}

class BooksTableViewController: UITableViewController {
  private var searchController = UISearchController()
  private var fetchedResultsController: NSFetchedResultsController<Book>!
  private let segueName = "showBookForm"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }

  private func loadData() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }

    let bookService = BookService(context: context)
    bookService.getBooks {[weak self] success in
      guard let self = self else { return }

      DispatchQueue.main.async {
        self.setupSearchController()
        self.setupRefreshControl()
        self.setupFetchedResultsController(with: "", scope: .bookName)
      }
    }
  }
  
  private func setupFetchedResultsController(with criteria: String, scope: Scope) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }
    
    let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    var predicate = NSPredicate(value: true)
    if(!criteria.isEmpty) {
      if(scope == .bookName) {
        predicate = NSPredicate(format: "name CONTAINS[cd] %@", criteria)
      }
      else {
        predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR author CONTAINS[cd] %@", criteria, criteria)
//        predicate = NSCompoundPredicate(
//         type: .or,
//         subpredicates: [
//         NSPredicate(format: "name CONTAINS[cd] %@", criteria),
//         NSPredicate(format: "author CONTAINS[cd] %@", criteria)
//         ])
      }
    }
    
    fetchRequest.predicate = predicate
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context,
                                                sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController.delegate = self
    do {
      try fetchedResultsController.performFetch()
      self.tableView.reloadData()
      self.tableView.refreshControl?.endRefreshing()
    }
    catch {
      print("Unexpected error \(error)")
    }
  }
  
  @IBAction func searchBarButtonTapped(_ sender: Any) {
    self.searchController.searchBar.becomeFirstResponder()
  }
  private func setupSearchController(){
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "search book name"
    searchController.obscuresBackgroundDuringPresentation = false
    
    navigationItem.searchController = searchController
    searchController.searchBar.scopeButtonTitles = Scope.allCases.map { $0.rawValue.capitalized }
    
    definesPresentationContext = true
    searchController.searchBar.delegate = self
    searchController.isActive = true
  }
  
  private func setupRefreshControl() {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    self.tableView.refreshControl = refreshControl
  }
  
  @objc
  private func refreshData(_ sender: UIRefreshControl){
    sender.beginRefreshing()
    setupFetchedResultsController(with: searchController.searchBar.text ?? "", scope: .bookName)
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: segueName, sender: self)
    
    /*let book = data[indexPath.row]
    
    let alert = UIAlertController(title: "Agregar Nuevo Libro", message: "Ingrese el nombre del libro", preferredStyle: .alert)
    
    alert.addTextField { (textField) in
      textField.text = book.name
    }
    
    let alertOkAction = UIAlertAction(title: "Actualizar", style: .default) { [weak self] _ in
      if let bookName = alert.textFields?.first?.text {
        self?.updateBook(book, with: bookName)
      }
    }
    
    let alertCancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
    
    alert.addAction(alertOkAction)
    alert.addAction(alertCancelAction)
    
    present(alert, animated: true)*/
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
    performSegue(withIdentifier: segueName, sender: self)
    /*let alert = UIAlertController(title: "Agregar Nuevo Libro", message: "Ingrese el nombre del libro", preferredStyle: .alert)
    
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
    
    present(alert, animated: true)*/
  }
  
  
  @IBSegueAction func showBookForm(_ coder: NSCoder) -> UIViewController? {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
      
      //let book = data[indexPath.row]
      let book = fetchedResultsController.object(at: indexPath)
      let bookViewController = BookViewController(coder: coder, book: book)
      bookViewController?.delegate = self
      return bookViewController
    }
    
    let bookViewController = BookViewController(coder: coder)
    bookViewController?.delegate = self
    return bookViewController
  }
  
  lazy var context: NSManagedObjectContext? = {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return nil
    }
    
    return context
  }()
}

//MARK: - Book View Controller Delegate
extension BooksTableViewController: BookViewControllerDelegate {
  func didSaveBook(_ bookViewController: BookViewController) {
    //self.loadData()
  }
}

// MARK: - Core Data Logic
extension BooksTableViewController {
  func filterBooks(_ criteria: String, scope: Scope) -> [Book] {
    var books = [Book]()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return books
    }
    
    var predicate = NSPredicate(value: true)
    if(scope == .bookName) {
       predicate = NSPredicate(format: "name CONTAINS[cd] %@", criteria)
    }
    else {
      //predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR author CONTAINS[cd] %@", criteria)
      
      let predicates = [
        NSPredicate(format: "name CONTAINS[cd] %@", criteria),
        NSPredicate(format: "author CONTAINS[cd] %@", criteria)
      ]
      
      predicate = NSCompoundPredicate(
        type: .or,
        subpredicates: predicates)
    }
    
    let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
    fetchRequest.predicate = predicate
    
    do {
      books = try context.fetch(fetchRequest)
    }
    catch {
      print("Unexpected error")
    }
    
    return books
  }
  
  func updateBook(_ book: Book, with name: String) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }
    
    book.name = name
    
    do {
      try context.save()
      self.tableView.reloadData()
    }
    catch {
      print("Unexpected error")
    }
  }
  
  func insertBook(name: String) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }
    
    if let newBook = NSEntityDescription.insertNewObject(
      forEntityName: "Book",
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
    context?.delete(book)
    do {
      try context?.save()
    }
    catch {
      print("Unexpected error")
    }
  }
}

//MARK: - Search Controller Delegates
extension BooksTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    
    guard let criteria = searchBar.text, !criteria.isEmpty else {
      setupFetchedResultsController(with: "", scope: .bookName)
      return
    }
    let scope = Scope.allCases[searchBar.selectedScopeButtonIndex]
    /*data = filterBooks(criteria, scope: scope)
    self.tableView.reloadData()*/
    setupFetchedResultsController(with: criteria, scope: scope)
  }
}

extension BooksTableViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    print("User changed scope")
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    print("User pressed search button")
  }
}

extension BooksTableViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
    tableView.refreshControl?.beginRefreshing()
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
    tableView.refreshControl?.endRefreshing()
  }
}
