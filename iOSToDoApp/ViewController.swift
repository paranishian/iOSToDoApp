//
//  ViewController.swift
//  iOSToDoApp
//
//  Created by Nishihara Kiyoshi on 2018/07/18.
//  Copyright © 2018年 Nishihara Kiyoshi. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: Model

final class TaskList: Object {
    dynamic var id = 0
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
    var items = List<Task>()
    var notificationToken: NotificationToken?
    var realm: Realm!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRealm()
    }
    
    func setupUI() {
        title = "My Tasks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func setupRealm() {
        let config = Realm.Configuration(schemaVersion: 1)
        self.realm = try! Realm(configuration: config)
        func updateList() {
            // まだTaskListが存在しない場合は追加する
            if realm.objects(TaskList.self).count == 0 {
                try! realm.write {
                    realm.add(TaskList())
                }
            }
            if let list = realm.objects(TaskList.self).first {
                items = list.items
            }
            tableView.reloadData()
        }
        updateList()
        // Notify us when Realm changes
        self.notificationToken = self.realm.observe { _,_ in
            updateList()
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: UITableView
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.alpha = item.completed ? 0.5 : 1
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            items.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let item = items[indexPath.row]
                realm.delete(item)
            }
        }
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

            try! self.realm.write {
                self.items.insert(Task(value: ["text": text]), at: self.items.filter("completed = false").count)
            }
        })
        present(alertController, animated: true, completion: nil)
    }
}
