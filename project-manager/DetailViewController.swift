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

struct Task {
    var id: String
    var projectId: String
    var title: String
    var dueDate: Date
    var progress: Float
    var notes: String
    var isAddedNotification = false
    
    init(projectId: String, title: String, dueDate: Date, progress: Float, notes: String) {
        self.id = UUID().uuidString
        self.projectId = "12345"
        self.title = title
        self.dueDate = dueDate
        self.progress = progress
        self.notes = notes
        print(progress)
    }
}

class TaskCell: UITableViewCell {
    @IBOutlet weak var progressBar: YLProgressBar!
    @IBOutlet weak var taskIdLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var daysLeftCircleView: CircleProgressBar!
    
}

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        
        percentageCircleView.startAngle = 270
        percentageCircleView.progressBarWidth = 5
        percentageCircleView.hintViewSpacing = 5
        percentageCircleView.progressBarTrackColor = .gray
        percentageCircleView.progressBarProgressColor = .green
        percentageCircleView.setProgress(0.2, animated: true, duration: 1)
        
        daysRemainingCircleView.startAngle = 270
        daysRemainingCircleView.progressBarWidth = 5
        daysRemainingCircleView.hintViewSpacing = 5
        daysRemainingCircleView.progressBarTrackColor = .gray
        daysRemainingCircleView.setProgress(0.5, animated: true, duration: 1)
        daysRemainingCircleView.setHintTextGenerationBlock { (progress) -> String? in
            return String.init(format: "%.0f", arguments: [progress * 100])
        }
        
        tasks = Array(repeating: Task.init(projectId: "12345", title: "Welcome to Sri Lanka", dueDate: Date(), progress: 10, notes: "Some notes about this task"), count: 3)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddEditTaskViewController {
            let popover = segue.destination as? AddEditTaskViewController
            
            popover?.isEditView = isEditView ? true : false
            popover?.taskPlaceholder = taskPlaceholder
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskCell
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        cell.progressBar.type = .flat
        cell.progressBar.progress = CGFloat(tasks[indexPath.row].progress / 100)
        cell.progressBar.trackTintColor = .green
        cell.progressBar.indicatorTextDisplayMode = .fixedRight
        
        cell.titleLabel.text = tasks[indexPath.row].title
        cell.dueDateLabel.text = formatter.string(from: tasks[indexPath.row].dueDate)
        cell.notesLabel.text = tasks[indexPath.row].notes
        cell.taskIdLabel.text = String(indexPath.row + 1)
        
        cell.daysLeftCircleView.startAngle = 270
        cell.daysLeftCircleView.progressBarWidth = 5
        cell.daysLeftCircleView.hintViewSpacing = 5
        cell.daysLeftCircleView.progressBarTrackColor = .gray
        cell.daysLeftCircleView.progressBarProgressColor = .green
        cell.daysLeftCircleView.setProgress(CGFloat(getDaysDifference(between: Date(), and: tasks[indexPath.row].dueDate) / 100), animated: true, duration: 1)
        cell.daysLeftCircleView.hintTextFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        cell.daysLeftCircleView.setHintTextGenerationBlock { (progress) -> String? in
            return String.init(format: "%.0f", arguments: [progress * 100])
        }
        
        return cell
    }
    
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
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete task: " + self.tasks[indexPath.row].title, yesAction: {() in
                self.tasks.remove(at: indexPath.row)
                self.tasksTableView.deleteRows(at: [indexPath], with: .automatic)
            }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = .red
        return action
    }
    
    // TODO: Show an alert when succesfully saved
    func saveTask(_ data: AddEditTaskViewController) {
        if var task = taskPlaceholder {
            task.title = data.titleTextField.text!
            task.dueDate = data.dueDatePicker.date
            task.progress = data.progressSlider.value
            task.notes = data.notesTextField.text!
            
            if !task.isAddedNotification && data.addNotificationToggle.isOn {
                addNotification(for: task)
                task.isAddedNotification = true
            }
            
            if let taskIndex = tasks.firstIndex(where: {$0.id == task.id}) {
                tasks[taskIndex] = task
            }
        } else {
            var task =
                Task(
                    projectId: "12345",
                    title: data.titleTextField.text!,
                    dueDate: data.dueDatePicker.date,
                    progress: data.progressSlider.value,
                    notes: data.notesTextField.text!)
            
            if data.addNotificationToggle.isOn {
                addNotification(for: task)
                task.isAddedNotification = true
            }
            
            self.tasks.append(task)
            
        }
        self.tasksTableView.reloadData()
    }

    func addNotification(for task: Task) {
    
    }
    
    func getDaysDifference(between firstDate: Date, and secondDate: Date) -> Float {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        
        print(calendar.dateComponents([.day], from: date1, to: date2).day!)
        
        return Float(calendar.dateComponents([.day], from: date1, to: date2).day!)
    }
}
