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
  private var data = [Book]()
  private var searchController = UISearchController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRefreshControl()
    loadData()
    setupSearchController()
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "showBookModal", sender: self)
    
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
      deleteBook(data[indexPath.row])
      data.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  @IBAction func addBookButtonTapped(_ sender: Any) {
    performSegue(withIdentifier: "showBookModal", sender: self)
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
  
  
  @IBSegueAction func showBookModal(_ coder: NSCoder) -> UIViewController? {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
      
      let book = data[indexPath.row]
      let bookViewController = BookViewController(coder: coder, book: book)
      bookViewController?.delegate = self
      return bookViewController
    }
    
    let bookViewController = BookViewController(coder: coder)
    bookViewController?.delegate = self
    return bookViewController
  }
}

//MARK: - Book View Controller Delegate
extension BooksTableViewController: BookViewControllerDelegate {
  func didSaveBook(_ bookViewController: BookViewController) {
    self.loadData()
  }
}

//MARK: - Search Controller Delegates
extension BooksTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    
    guard let criteria = searchBar.text, !criteria.isEmpty else {
      loadData()
      return
    }
    let scope = Scope.allCases[searchBar.selectedScopeButtonIndex]
    data = filterBooks(criteria, scope: scope)
    self.tableView.reloadData()
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
      /*predicate = NSCompoundPredicate(
        type: .or,
        subpredicates: [
          NSPredicate(format: "name CONTAINS[cd] %@", criteria),
          NSPredicate(format: "author CONTAINS[cd] %@", criteria)
        ])*/
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
