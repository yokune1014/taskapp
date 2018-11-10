//
//  InputViewController.swift
//  taskapp
//
//  Created by Nana Takase on 2018/11/10.
//  Copyright © 2018 yokune1014. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource ,UITextFieldDelegate {
  
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  var task: Task!
  var category = Category()
  let realm = try! Realm()
  var pickerView: UIPickerView = UIPickerView()
  let list = try! Realm().objects(Category.self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //カテゴリテキストビューにPickerViewを設定
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.showsSelectionIndicator = true
    
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
    let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    toolbar.setItems([spacelItem, doneItem], animated: true)
    
    self.categoryTextField.inputView = pickerView
    self.categoryTextField.inputAccessoryView = toolbar
    self.categoryTextField.delegate = self

    //テキストビュー枠線の設定
    contentsTextView.layer.borderWidth = 0.5
    contentsTextView.layer.cornerRadius = 10.0
    contentsTextView.layer.borderColor = UIColor.lightGray.cgColor
    
    titleTextField.text = task.title
    categoryTextField.text = task.category
    contentsTextView.text = task.contents
    datePicker.date = task.date
    
    //背景タップでdismissKeyboard呼び出し
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return  list.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return list[row].category
  }
  
  // 決定ボタン押下
  @objc func done() {
    categoryTextField.endEditing(true)
    if list.count != 0 {
      categoryTextField.text = "\(list[pickerView.selectedRow(inComponent: 0)].category)"
    }
  }
  
  //segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let categoryViewController:CategoryViewController = segue.destination as! CategoryViewController
    //カテゴリのIDを設定
    if list.count != 0 {
      category.id = list.count + 1
    }
    
    categoryViewController.category = category
  }
  
  @objc func dismissKeyboard(){
    //キーボードを閉じる
    view.endEditing(true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    
    //タイトルまたは内容いずれかに値が入力されている場合タスクを登録
    if self.titleTextField.text != "" || contentsTextView.text != "" {
      
      try! realm.write {
        self.task.title = self.titleTextField.text!
        self.task.category = categoryTextField.text!
        self.task.contents = self.contentsTextView.text
        self.task.date = self.datePicker.date
        self.realm.add(self.task, update: true)
      }
      
      setNotification(task: task)
    }
    super.viewWillDisappear(animated)
  }
  
  //タスクのローカル通知を登録
  func setNotification(task: Task){
    let content = UNMutableNotificationContent()
    
    //タイトル設定
    if task.title == ""{
      content.title = "(タイトルなし)"
    }else{
      content.title = task.title
    }
    
    //内容設定
    if task.contents == ""{
      content.body = "(内容なし)"
    }else{
      content.body = task.contents
    }
    content.sound = UNNotificationSound.default()
    
    //ローカル通知が発動するtriggerを作成
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
    let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
    
    //identifier,content,triggerからローカル通知を作成
    let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
    
    //ローカル通知を登録
    let center = UNUserNotificationCenter.current()
    center.add(request){
      (error) in
      print(error ?? "ローカル通知登録 OK") //errorがnilならローカル通知の登録に成功
      // 未通知のローカル通知一覧をログ出力
      center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
        for request in requests {
          print("/---------------")
          print(request)
          print("---------------/")
        }
      }
    }
  }
  
  @IBAction func unwind(_ segue: UIStoryboardSegue) {
    
  }
}

