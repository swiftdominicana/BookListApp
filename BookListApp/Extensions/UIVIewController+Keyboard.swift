//
//  UIVIewController+Keyboard.swift
//  TsaChat1819
//
//  Created by Libranner Leonel Santos Espinal on 24/02/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import UIKit

extension UIViewController {
  @objc func hideKeyboard() {
    self.view.endEditing(true)
  }
}

