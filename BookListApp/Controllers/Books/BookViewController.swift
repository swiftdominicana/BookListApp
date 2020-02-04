//
//  BookViewController.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 03/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import UIKit
import CoreData

protocol BookViewControllerDelegate {
  func didSaveBook(_ bookViewController: BookViewController)
}

class BookViewController: UIViewController {
  @IBOutlet var bookCoverImageView: AsyncImageView!
  @IBOutlet var bookNameTextField: UITextField!
  @IBOutlet var bookAuthorTextField: UITextField!
  @IBOutlet var showQuotesButton: UIButton!
  
  private let segueName = "showQuotes"
  var delegate: BookViewControllerDelegate?
  let book: Book?
  
  private var isEditingMode: Bool {
    return book != nil
  }
  
  init?(coder: NSCoder, book: Book) {
    self.book = book
    super.init(coder: coder)
  }
  
  private func fillForm(book: Book) {
    bookNameTextField.text = book.name
    bookAuthorTextField.text = book.author
    bookCoverImageView.fillWithURL(book.coverImageUrl!, placeholder: nil)
  }
  
  required init?(coder: NSCoder) {
    self.book = nil
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    recognizer.cancelsTouchesInView = false
    view.addGestureRecognizer(recognizer)
    
    if isEditingMode {
      fillForm(book: self.book!)
      navigationItem.rightBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addQuoteButtonTapped))
    }
    
    showQuotesButton.isHidden = !isEditingMode
  }
  
  @IBAction func saveButtonTapped(_ sender: Any) {
    if isValid {
      save()
      delegate?.didSaveBook(self)
      self.dismiss(animated: true)
      return
    }
    
    let alert = UIAlertController(title: "Form Inválido", message: "Favor rellene todos los campos", preferredStyle: .alert)
    
    let alertOkAction = UIAlertAction(title: "Ok", style: .default)
    alert.addAction(alertOkAction)
    
    present(alert, animated: true)
  }
  
  private var isValid: Bool {
    guard
      bookCoverImageView.image != nil,
      !bookNameTextField.text!.isEmpty,
      !bookAuthorTextField.text!.isEmpty
      else {
        return false
    }
    
    return true
  }
  
  @objc func addQuoteButtonTapped(_ sender: Any) {
    let alert = UIAlertController(title: "Agregar Frase", message: "Ingrese la frase que desea guardar", preferredStyle: .alert)
    
    alert.addTextField { (textField) in
    }
    
    let alertOkAction = UIAlertAction(title: "Agregar", style: .default) { [weak self] _ in
      if let quote = alert.textFields?.first?.text,
        let book = self?.book {
        self?.addQuoteToBook(book, quote: quote)
      }
    }
    
    let alertCancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
    
    alert.addAction(alertOkAction)
    alert.addAction(alertCancelAction)
    
    present(alert, animated: true)
  }
  
  private func addQuoteToBook(_ book: Book, quote: String) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }
    
    if let newQuote = NSEntityDescription.insertNewObject(forEntityName: "Quote",
                                                         into: context) as? Quote {
      newQuote.content = quote
      
      book.addToQuotes(newQuote)
      
      do {
        try context.save()
      }
      catch {
        print("Unexpected error: \(error).")
      }
    }
  }
  @IBAction func showQuoteButtonTapped(_ sender: Any) {
    performSegue(withIdentifier: segueName, sender: self)
  }

  @IBSegueAction func showQuotes(_ coder: NSCoder) -> UITableViewController? {
    let quotesViewController = QuotesTableViewController(
      coder: coder, quotes: book!.quotes!)
    
    return quotesViewController
  }
  private func save() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    guard let context = appDelegate?.persistentContainer.viewContext else {
      return
    }
    
    let imageUrl = ImagePersistenceHelper().saveImage(
      bookCoverImageView.image!,
      compression: 0.8)
    
    if isEditingMode, let book = book {
      book.author = bookAuthorTextField.text
      book.name = bookNameTextField.text
      book.coverImageUrl = imageUrl
    }
    else {
      if let newBook = NSEntityDescription.insertNewObject(
        forEntityName: "Book",
        into: context) as? Book {
        newBook.author = bookAuthorTextField.text
        newBook.name = bookNameTextField.text
        newBook.coverImageUrl = imageUrl
      }
    }
    
    do {
      try context.save()
    }
    catch {
      print("Unexpected error: \(error).")
    }
  }
  
  @IBAction func pickImageButtonTapped(_ sender: Any) {
    let actionSheet = UIAlertController(title: "Seleccionar Foto", message: "Favor seleccione una foto", preferredStyle: .actionSheet)
    
    let pickFromGalleryAction = UIAlertAction(title: "Escoger de la galería", style: .default) { [weak self] _ in
      self?.pickImageFromGallery()
    }
    
    let takePhotoAction = UIAlertAction(title: "Tomar foto", style: .default) { [weak self] _ in
      self?.takePhoto()
    }
    
    let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
    
    actionSheet.addAction(pickFromGalleryAction)
    actionSheet.addAction(takePhotoAction)
    actionSheet.addAction(cancelAction)
    
    present(actionSheet, animated: true)
  }
}

extension BookViewController: UINavigationControllerDelegate,  UIImagePickerControllerDelegate {
  func takePhoto() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .camera
    self.present(imagePickerController, animated: true, completion: nil)
  }
  
  func pickImageFromGallery() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .photoLibrary
    self.present(imagePickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    self.bookCoverImageView.image = pickedImage
    
    self.dismiss(animated: true, completion: nil)
  }
}
