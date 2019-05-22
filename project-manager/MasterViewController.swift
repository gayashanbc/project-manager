//
//  MasterViewController.swift
//  project-manager
//
//  Created by Gayashan Bombuwala on 5/16/19.
//  Copyright © 2019 Gayashan Bombuwala. All rights reserved.
//

import UIKit
import EventKit

enum ProjectPriority: Int {
    case Low, Medium, High
    
    func getAsString() -> String {
        switch self {
        case .High:
            return "High"
        case .Medium:
            return "Medium"
        default:
            return "Low"
        }
    }
}

struct Project {
    var id: String
    var title: String
    var dueDate: Date
    var priority: ProjectPriority
    var notes: String
    var eventIdentifier: String?
    var isAddedToCalendar = false
    
    init(title: String, dueDate: Date, priority: ProjectPriority, notes: String) {
        self.id = UUID().uuidString
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.notes = notes
    }
}

class ProjectCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
}

class MasterViewController: UITableViewController {
    
    @IBOutlet weak var addProjectButton: UIBarButtonItem!
    
    var projects: [Project]!
    var projectPlaceholder: Project?
    var isEditView: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        projects = Array(repeating: Project.init(title: "Final Year Project", dueDate: Date(), priority: .High, notes: "Something has to be done on time before it ends."), count: 5)
        
        print(projects!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddEditProjectViewController {
            let popover = segue.destination as? AddEditProjectViewController
            
            popover?.viewTitle = "Project"
            popover?.isEditView = isEditView ? true : false
            popover?.projectPlaceholder = projectPlaceholder
            popover?.saveFunction = {(popoverViewController) in
                self.saveProject(popoverViewController as! AddEditProjectViewController)
            }
            popover?.resetToDefaults = { () in
                self.isEditView = false
                self.projectPlaceholder = nil
                self.addProjectButton.image = UIImage(named: "add")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as! ProjectCell
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        cell.titleLabel.text = projects[indexPath.row].title
        cell.dueDateLabel.text = formatter.string(from: projects[indexPath.row].dueDate)
        cell.priorityLabel.text = projects[indexPath.row].priority.getAsString()
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
            self.isEditView = true
            self.projectPlaceholder = self.projects[indexPath.row]
            self.addProjectButton.image = UIImage(named: "edit")
            self.performSegue(withIdentifier: "popoverSegue", sender: self)
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
    
    func addProject() -> Bool {
        return true
    }
    
    func saveProject(_ data: AddEditProjectViewController) {
        if var project = projectPlaceholder {
            project.title = data.titleTextField.text!
            project.dueDate = data.dueDatePicker.date
            project.priority = assignPriority(for: data.prioritySegmentControl.selectedSegmentIndex)
            project.notes = data.notesTextField.text!
            
            if !project.isAddedToCalendar && data.addToCalendarToggle.isOn {
                addEventToCalendar(for: project)
                project.isAddedToCalendar = true
            }
            
            if let projectIndex = projects.firstIndex(where: {$0.id == project.id}) {
                projects[projectIndex] = project
            }
        } else {
            var project =
                Project(
                    title: data.titleTextField.text!,
                    dueDate: data.dueDatePicker.date,
                    priority: assignPriority(for: data.prioritySegmentControl.selectedSegmentIndex),
                    notes: data.notesTextField.text!)
            
            if data.addToCalendarToggle.isOn {
                addEventToCalendar(for: project)
                project.isAddedToCalendar = true
            }
            
            self.projects.append(project)
            
        }
        self.tableView.reloadData()
    }
    
    func assignPriority(for index: Int) -> ProjectPriority {
        switch index {
        case 1:
            return .Medium
        case 2:
            return .High
        default:
            return .Low
        }
    }
    
    func addEventToCalendar (for project: Project) {
        let eventStore : EKEventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                let event: EKEvent = EKEvent(eventStore: eventStore)
                
                // TODO: Fix same date error when saving
                event.title = project.title
                event.startDate = Date()
                event.endDate = project.dueDate
                event.notes = project.notes
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    preconditionFailure("Failed to save event with error : \(error)")
                }
            }
            else {
                preconditionFailure("Failed to save event with error : \(String(describing: error)) or access not granted")
            }
        }
    }
}
