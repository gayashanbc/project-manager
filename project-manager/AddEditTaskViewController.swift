//
//  AddEditTaskViewController.swift
//  project-manager
//
//  Created by Gayashan Bombuwala on 5/25/19.
//  Copyright © 2019 Gayashan Bombuwala. All rights reserved.
//

import UIKit

class AddEditTaskViewController: UIViewController {
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var addNotificationToggle: UISwitch!
    @IBOutlet weak var progressTitleLabel: UILabel!
    
    var hasPriorityStackView: Bool? = true
    var saveFunction: Utilities.saveFunctionType?
    var resetToDefaults: Utilities.resetToDefaultsFunctionType?
    var taskPlaceholder: Task?
    var isEditView: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let isEditMode = isEditView else { return }
        
        viewTitleLabel.text = isEditMode ? "Edit Task" : "Add Task"
        dueDatePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        
        if let task = taskPlaceholder  {
            titleTextField.text = task.title
            notesTextField.text = task.notes
            dueDatePicker.date = task.dueDate
            progressTitleLabel.text = "Progress = " + String(task.progress.rounded()) + "%"
            progressSlider.value = task.progress
            addNotificationToggle.isOn = !task.isAddedNotification
            addNotificationToggle.isEnabled = !task.isAddedNotification
        }
        
        
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        progressTitleLabel.text = "Progress = " + String(sender.value.rounded()) + "%"
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let reset = resetToDefaults {
            reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func validateFields() -> Bool {
        if titleTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Task name can't be empty", caller: self)
            return false
        }
        return true
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let save = saveFunction else {
            preconditionFailure("Save function not defined")
        }
        
        if validateFields() {
            save(self)
            if let reset = resetToDefaults {
                reset()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
