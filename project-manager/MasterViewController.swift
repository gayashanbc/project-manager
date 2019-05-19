//
//  MasterViewController.swift
//  project-manager
//
//  Created by Gayashan Bombuwala on 5/16/19.
//  Copyright © 2019 Gayashan Bombuwala. All rights reserved.
//

import UIKit

enum ProjectPriority: String {
    case High
    case Medium
    case Low
}

struct Project {
    static var autoIncrementedId: Int = 0
    var id: Int
    var title: String
    var dueDate: Date
    var priority: ProjectPriority
    var notes: String
    
    init(title: String, dueDate: Date, priority: ProjectPriority, notes: String) {
        Project.autoIncrementedId += 1
        self.id = Project.autoIncrementedId
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.notes = notes
    }
}

class ProjectCell: UITableViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
}

class MasterViewController: UITableViewController {
    
    var projects: [Project]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
     // tableView.dataSource = self
        
        projects = Array(repeating: Project.init(title: "Final Year Project", dueDate: Date(), priority: .High, notes: "Something has to be done on time before it ends."), count: 5)
        
        print(projects!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        self.editButtonItem.title = "Modify"
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return projects.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as! ProjectCell
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        cell.idLabel.text = String(indexPath.row)
        cell.titleLabel.text = projects[indexPath.row].title
        cell.dueDateLabel.text = formatter.string(from: projects[indexPath.row].dueDate)
        cell.priorityLabel.text = projects[indexPath.row].priority.rawValue
        cell.notesLabel.text = projects[indexPath.row].notes

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.backgroundColor = .brown
        return action
    }
    
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete: " + self.projects[indexPath.row].title, yesAction: {() in
                self.projects.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = .red
        return action
    }

}
