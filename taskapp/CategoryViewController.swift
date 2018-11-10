//
//  CategoryViewController.swift
//  taskapp
//
//  Created by Nana Takase on 2018/11/10.
//  Copyright © 2018 yokune1014. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController{
  
  let realm = try! Realm()
  var category:  Category!
  
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var addButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
          print("-----")
          print(category.category)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if self.textField.text != ""{

      try! realm.write {
        self.category.id = category.id
        self.category.category = self.textField.text!
        self.realm.add(self.category, update: true)
      }
      
      print("-----")
      print(category.category)
    }
  }
}


