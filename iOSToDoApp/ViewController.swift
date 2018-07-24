//
//  ViewController.swift
//  iOSToDoApp
//
//  Created by Nishihara Kiyoshi on 2018/07/18.
//  Copyright © 2018年 Nishihara Kiyoshi. All rights reserved.
//

import UIKit
import RealmSwift

struct RealmModel {
    
    struct realm{
        
        static var realmTry  = try!Realm()
        static var realmsSet = Task()
        static var usersSet = RealmModel.realm.realmTry.objects(Task.self)
        
    }
}

// MARK: Model

final class TaskList: Object {
    dynamic var text = ""
    dynamic var id = ""
    let items = List<Task>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Task: Object {
    dynamic var text = ""
    dynamic var completed = false
}

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "My Tasks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
    }
    
    // MARK: UITableView
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return RealmModel.realm.usersSet.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = RealmModel.realm.usersSet[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.alpha = item.completed ? 0.5 : 1
        return cell
    }
    
    // MARK: Functions
    
    func add() {
        let alertController = UIAlertController(title: "New Task", message: "Enter Task Name", preferredStyle: .alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Task Name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
            let newTask = Task(value: ["text": text])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(newTask)
                print("Task saved")
            }

            self.tableView.reloadData()
        })
        present(alertController, animated: true, completion: nil)
    }
}
