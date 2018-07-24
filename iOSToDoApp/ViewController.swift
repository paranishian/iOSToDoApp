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
    dynamic var order = 0
}

class ViewController: UITableViewController {
    var items: Results<Task>!
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
        self.realm = try! Realm()
        func updateList() {
            items = realm.objects(Task.self).sorted(byKeyPath: "order")
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
        print(items)
        print("source: %@", sourceIndexPath.row)
        print("dest  : %@", destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let item = items[indexPath.row]
                realm.delete(item)
            }
        }
        if editingStyle == .none {
            print("none!!")
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
                self.realm.add(Task(value: ["text": text, "order": self.realm.objects(Task.self).count + 1]))
            }
        })
        present(alertController, animated: true, completion: nil)
    }
}
