//
//  ViewController.swift
//  taskapp
//
//  Created by Nana Takase on 2018/11/08.
//  Copyright © 2018 yokune1014. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  //Realmインスタンス取得
  let realm = try! Realm()
  
  //DB内のタスクが格納されるリスト
  // 日付近い順\順でソート：降順
  // 以降内容をアップデートするとリスト内は自動的に更新される。
  var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    tableView.delegate = self
    tableView.dataSource = self
    searchBar.delegate = self
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  //検索バーに入力された時の処理
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    if searchBar.text == ""{
      taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    }else{
      taskArray = try! Realm().objects(Task.self).filter("category CONTAINS %@", searchBar.text!).sorted(byKeyPath: "date", ascending: false)
    }
    tableView.reloadData()
  }
  
  //クリアボタンが押された時の処理
  func searchBar(_ searchBar: UISearchBar,
                 textDidChange searchText: String){
    if searchText.isEmpty {
      searchBar.endEditing(true)
      taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
      tableView.reloadData()
    }
  }
  
  
  //UITableViewDataSourceプロトコルのメソッド
  //データの数を返すメソッド
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskArray.count
  }
  //セルの内容を返すメソッド
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    //再利用可能なcellを得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    //cellに値を設定する
    let task = taskArray[indexPath.row]
    cell.textLabel?.text = task.title
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let dateString:String = formatter.string(from: task.date)
    cell.detailTextLabel?.text = dateString
    
    return cell
  }
  
  //UITableViewDelegateプロトコルのメソッド
  //セルを選択したときに実行されるメソッド
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "cellSegue", sender: nil)
  }
  
  //セルが削除可能なことを伝えるメソッド
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }
  
  // Delete ボタンが押された時に呼ばれるメソッド
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      
      //削除されたタスクを取得する
      let task = self.taskArray[indexPath.row]
      
      //ローカル通知をキャンセルする
      let center = UNUserNotificationCenter.current()
      center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
      
      // データベースから削除する
      try! realm.write {
        self.realm.delete(self.taskArray[indexPath.row])
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
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
  
  //segueで画面遷移するときに呼ばれる
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let inputViewController:InputViewController = segue.destination as! InputViewController
    
    if segue.identifier == "cellSegue" {
      let indexPath = self.tableView.indexPathForSelectedRow
      inputViewController.task = taskArray[indexPath!.row]
    }else{
      let task = Task()
      task.date = Date()
      
      let allTasks = realm.objects(Task.self)
      if allTasks.count != 0 {
        task.id = allTasks.max(ofProperty: "id")! + 1
      }
      inputViewController.task = task
      
    }
  }
  
  //入力画面から戻ってきたときにTableViewを更新する
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
}
