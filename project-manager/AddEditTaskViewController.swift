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
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var addNotificationToggle: UISwitch!
    @IBOutlet weak var progressTitleLabel: UILabel!
    @IBOutlet weak var dateSegmentControl: UISegmentedControl!
    
    var hasPriorityStackView: Bool? = true
    var saveFunction: Utilities.saveFunctionType?
    var resetToDefaults: Utilities.resetToDefaultsFunctionType?
    var taskPlaceholder: Task?
    var isEditView: Bool?
    var startDate: Date?
    var dueDate: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let isEditMode = isEditView else { return }
        
        viewTitleLabel.text = isEditMode ? "Edit Task" : "Add Task"
        datePicker.timeZone = TimeZone(identifier: "UTC")
        
        startDate = Calendar.current.date(bySetting: .hour, value: 0, of: Date())
        dueDate = Calendar.current.date(bySetting: .hour, value: 1, of: Date())
        
        if let task = taskPlaceholder  {
            titleTextField.text = task.title
            notesTextField.text = task.notes
            datePicker.date = task.startDate
            progressTitleLabel.text = "Progress = " + String(task.progress.rounded()) + "%"
            progressSlider.value = task.progress
            addNotificationToggle.isOn = !task.isAddedNotification
            addNotificationToggle.isEnabled = !task.isAddedNotification
            
            startDate = task.startDate
            dueDate = task.dueDate
        }
        
        
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func dateSegmentControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            datePicker.minimumDate = startDate
            datePicker.maximumDate = nil
            datePicker.date = dueDate!
        default:
            datePicker.minimumDate = nil
            datePicker.maximumDate = dueDate
            datePicker.date = startDate!
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        
        // TODO: This works when used directly without let or guarad, fix this.
        switch dateSegmentControl.selectedSegmentIndex {
        case 1:
            if let minDate = datePicker.minimumDate {
                if sender.date >= minDate {
                    dueDate = sender.date
                }
            } else {
                dueDate = sender.date
            }
            
        default:
            if let maxDate = datePicker.maximumDate {
                if sender.date <= maxDate {
                    startDate = sender.date
                }
            } else {
                startDate = sender.date
            }
        }
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        progressTitleLabel.text = "Progress = " + String(sender.value.rounded()) + "%"
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let reset = resetToDefaults {
            datePicker.minimumDate = nil
            datePicker.maximumDate = nil
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
                datePicker.minimumDate = nil
                datePicker.maximumDate = nil
                reset()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
