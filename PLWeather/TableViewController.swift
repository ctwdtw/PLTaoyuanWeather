//
//  TableViewController.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import UIKit

struct TableOfContent {
  var content: String!
  func printContent() {
    print(self.content)
  }
}



struct Book {
  var id: String!
  var msg: String!
  var author: String!
  var tableOfContet: TableOfContent?
}




class TableViewController: UITableViewController {
  var modelArray: [Int] = [1]
  override func viewDidLoad() {
    super.viewDidLoad()
    //let content = TableOfContent(content: "hello content")
    var book = Book(id: nil, msg: nil, author: nil, tableOfContet: nil)
    book.tableOfContet?.content = "hello"
    
    var book2 = Book(id: nil, msg: nil, author: nil, tableOfContet: nil)
    print(book.msg)
    book2.msg = book.msg
    
    
    
    

    
    
  }
  
  @IBAction func AddBtnPressed(_ sender: Any) {
    var last = modelArray.last!
    let index = modelArray.index(of: last)!
    modelArray.insert(last+1, at: index+1)
    let indexPath = IndexPath(row: index+1, section: 0)
    tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.right)
    
  
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return modelArray.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    let number = modelArray[indexPath.row]
    cell.textLabel?.text = "this is \(number)"
    
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
    return true
  }
  
  
  
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      //Delete the row from the data source
      modelArray.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      
    } else if editingStyle == .insert {
      //Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
      
      
    }
  }
  
  
  /*
   Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
