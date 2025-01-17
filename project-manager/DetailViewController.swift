//
//  DetailViewController.swift
//  project-manager
//
//  Created by Gayashan Bombuwala on 5/16/19.
//  Copyright © 2019 Gayashan Bombuwala. All rights reserved.
//

import UIKit
import CircleProgressBar
import YLProgressBar
import CoreData
import UserNotifications

protocol TasksChangedDelegate: class {
    func tasksChanged()
}

class TaskCell: UITableViewCell {
    @IBOutlet weak var progressBar: YLProgressBar!
    @IBOutlet weak var taskIdLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var daysLeftCircleView: CircleProgressBar!
    
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var percentageCircleView: CircleProgressBar!
    @IBOutlet weak var daysRemainingCircleView: CircleProgressBar!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var projectMetaLabel: UILabel!
    @IBOutlet weak var projectNotesLabel: UILabel!
    
    var tasks: [Task]!
    var taskPlaceholder: Task?
    var isEditView: Bool = false
    var project: Project? {
        didSet {
            refreshUI()
        }
    }
    weak var delegate: TasksChangedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        
        percentageCircleView.startAngle = 270
        percentageCircleView.progressBarWidth = 5
        percentageCircleView.hintViewSpacing = 5
        percentageCircleView.progressBarTrackColor = .gray
        percentageCircleView.progressBarProgressColor = .green
        percentageCircleView.setProgress(0.0, animated: true, duration: 1)
        
        daysRemainingCircleView.startAngle = 270
        daysRemainingCircleView.progressBarWidth = 5
        daysRemainingCircleView.hintViewSpacing = 5
        daysRemainingCircleView.progressBarTrackColor = .gray
        daysRemainingCircleView.setProgress(0.0, animated: true, duration: 1)
        daysRemainingCircleView.setHintTextGenerationBlock { (progress) -> String? in
            return String.init(format: "%.0f", arguments: [progress * 100])
        }
        daysRemainingCircleView.progressBarProgressColor = nil
        addTaskButton.isEnabled = false
        
        if let selectedProject = project {
            tasks = Utilities.fetchFromDBContext(entityName: "Task", predicate: NSPredicate(format: "project.projectId = %@", selectedProject.projectId!))
        } else {
            tasks = Array()
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddEditTaskViewController {
            let popover = segue.destination as? AddEditTaskViewController
            
            popover?.isEditView = isEditView ? true : false
            popover?.taskPlaceholder = taskPlaceholder
            popover?.delegate = self
            popover?.saveFunction = {(popoverViewController) in
                self.saveTask(popoverViewController as! AddEditTaskViewController)
            }
            popover?.resetToDefaults = { () in
                self.isEditView = false
                self.taskPlaceholder = nil
                self.addTaskButton.imageView?.image = UIImage(named: "addTask")
            }
        }
    }
    
    func saveTask(_ data: AddEditTaskViewController) {
        if let task = taskPlaceholder {
            task.title = data.titleTextField.text!
            task.startDate = data.startDate!
            task.dueDate = data.dueDate!
            task.progress = data.progressSlider.value / 100
            task.notes = data.notesTextField.text!
            
           
            if !task.isAddedNotification && data.addNotificationToggle.isOn {
                addNotification(for: task)
                task.isAddedNotification = true
            }
            
            if let taskIndex = tasks.firstIndex(where: {$0.taskId == task.taskId}) {
                tasks[taskIndex] = task
            }
        } else {
            let task = Task(context: Utilities.getDBContext())
                    task.title = data.titleTextField.text!
                    task.startDate = data.startDate!
                    task.dueDate = data.dueDate!
                    task.progress = data.progressSlider.value / 100
                    task.notes = data.notesTextField.text
                    task.project = project
            
            if data.addNotificationToggle.isOn {
                addNotification(for: task)
                task.isAddedNotification = true
            }
            self.tasks.append(task)
        
        }
        Utilities.saveDBContext()
        delegate?.tasksChanged()
        self.tasksTableView.reloadData()
        refreshUI()
    }

    func addNotification(for task: Task) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("Notification print permission granted")
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Project: " + task.project!.title!
        content.body = "The following task has not been completed on time.\nTask: " + task.title! + "\nDue Date: " + Utilities.getFormattedDateString(for: task.dueDate, format: "yyyy-MM-dd")
        
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: task.dueDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let uuid = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let e = error {
                print(e)
            }
        }
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        if let selectedProject = project {
            
            projectTitleLabel.text = selectedProject.title
            projectMetaLabel.text = (selectedProject.priority.getAsString()) + " Priority | Due " + Utilities.getFormattedDateString(for: selectedProject.dueDate, format: "yyyy-MM-dd")
            projectNotesLabel.text = "Notes: " + selectedProject.notes!
            percentageCircleView.setProgress(CGFloat(selectedProject.progress.value), animated: true, duration: 1)
            percentageCircleView.progressBarProgressColor = selectedProject.progress.color
            daysRemainingCircleView.setProgress(selectedProject.daysRemaining.value, animated: true, duration: 1)
            daysRemainingCircleView.progressBarTrackColor = selectedProject.daysRemaining.color
            daysRemainingCircleView.progressBarProgressColor = selectedProject.daysRemaining.color
            tasks = Utilities.fetchFromDBContext(entityName: "Task", predicate: NSPredicate(format: "project.projectId = %@", selectedProject.projectId!))
            tasksTableView.reloadData()
            addTaskButton.isEnabled = true
        }
        
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskCell
        
        cell.progressBar.setProgress(CGFloat(tasks[indexPath.row].progress), animated: true)
        cell.progressBar.trackTintColor = .gray
        cell.progressBar.progressTintColor = tasks[indexPath.row].progressColor
        cell.progressBar.indicatorTextDisplayMode = .fixedRight
        
        cell.titleLabel.text = tasks[indexPath.row].title
        cell.dueDateLabel.text = Utilities.getFormattedDateString(for: tasks[indexPath.row].dueDate, format: "yyyy-MM-dd")
        cell.notesLabel.text = tasks[indexPath.row].notes
        cell.taskIdLabel.text = String(indexPath.row + 1)
        
        cell.daysLeftCircleView.startAngle = 270
        cell.daysLeftCircleView.progressBarWidth = 5
        cell.daysLeftCircleView.hintViewSpacing = 5
        cell.daysLeftCircleView.progressBarTrackColor = tasks[indexPath.row].daysRemaining.color
        cell.daysLeftCircleView.progressBarProgressColor = tasks[indexPath.row].daysRemaining.color
        cell.daysLeftCircleView.setProgress(tasks[indexPath.row].daysRemaining.value, animated: true, duration: 1)
        cell.daysLeftCircleView.hintTextFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        cell.daysLeftCircleView.setHintTextGenerationBlock { (progress) -> String? in
            return String.init(format: "%.0f", arguments: [progress * 100])
        }
        
        return cell
    }
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditView = true
            self.taskPlaceholder = self.tasks[indexPath.row]
            self.addTaskButton.imageView?.image = UIImage(named: "editTask")
            self.performSegue(withIdentifier: "taskViewSegue", sender: self)
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.backgroundColor = .brown
        return action
    }
    
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete task: " + self.tasks[indexPath.row].title!, yesAction: {() in
                Utilities.getDBContext().delete(self.tasks[indexPath.row])
                Utilities.saveDBContext()
                self.tasks.remove(at: indexPath.row)
                self.tasksTableView.deleteRows(at: [indexPath], with: .automatic)
                self.delegate?.tasksChanged()
                self.refreshUI()
            }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = .red
        return action
    }
}

extension DetailViewController: ProjectSelectionDelegate {
    func projectSelected(_ newProject: Project) {
        project = newProject
    }
}

extension DetailViewController: ItemActionDelegate {
    func itemAdded(title: String) {
        Utilities.showInformationAlert(title: "Alert", message: "New task: \(title)\nSuccessfully Added", caller: self)
    }
    
    func itemEdited(title: String) {
        Utilities.showInformationAlert(title: "Alert", message: "Task: \(title)\nSuccessfully Edited", caller: self)
    }
}
