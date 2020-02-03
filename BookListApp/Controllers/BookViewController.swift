//
//  BookViewController.swift
//  BookListApp
//
//  Created by Libranner Leonel Santos Espinal on 03/02/2020.
//  Copyright © 2020 Libranner Leonel Santos Espinal. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {
  
  @IBOutlet var bookCoverImageView: UIImageView!
  @IBOutlet var bookNameTextField: UITextField!
  @IBOutlet var bookAuthorTextField: UITextField!
  
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
    //bookAuthorTextField.text = book.author
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if isEditingMode {
      fillForm(book: self.book!)
    }
  }

}
