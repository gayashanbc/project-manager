//
//  AddEditProjectViewController.swift
//  project-manager
//
//  Created by Gayashan Bombuwala on 5/21/19.
//  Copyright © 2019 Gayashan Bombuwala. All rights reserved.
//

import UIKit

class AddEditProjectViewController: UIViewController {
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var prioritySegmentControl: UISegmentedControl!
    @IBOutlet weak var addToCalendarToggle: UISwitch!
    @IBOutlet weak var dateSegmentControl: UISegmentedControl!
    
    var saveFunction: Utilities.saveFunctionType?
    var resetToDefaults: Utilities.resetToDefaultsFunctionType?
    var projectPlaceholder: Project?
    var isEditView: Bool?
    var startDate: Date?
    var dueDate: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let isEditMode = isEditView else { return }
        
        datePicker.timeZone = TimeZone(identifier: "UTC")
        viewTitleLabel.text = isEditMode ? "Edit Project" : "Add Project"

        startDate = Calendar.current.date(bySetting: .hour, value: 0, of: Date())
        dueDate = Calendar.current.date(bySetting: .hour, value: 1, of: Date())
        
        datePicker.maximumDate = dueDate
        datePicker.minimumDate = startDate
        
        if let project = projectPlaceholder  {
            titleTextField.text = project.title
            notesTextField.text = project.notes
            datePicker.date = project.startDate
            prioritySegmentControl.selectedSegmentIndex = project.priority.rawValue
            addToCalendarToggle.isOn = !project.isAddedToCalendar
            addToCalendarToggle.isEnabled = !project.isAddedToCalendar
            
            startDate = project.startDate
            dueDate = project.dueDate
        }
        titleTextField.becomeFirstResponder()
    }
    
    
    @IBAction func dataSegmentControlValueChanged(_ sender: UISegmentedControl) {
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
        guard let minDate = datePicker.minimumDate else { return }
        guard let maxDate = datePicker.maximumDate else { return }
        
        switch dateSegmentControl.selectedSegmentIndex {
        case 1:
            if sender.date >= minDate {
                dueDate = sender.date
            }
        default:
            if sender.date <= maxDate {
                startDate = sender.date
            }
        }
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
    
    func validateFields() -> Bool {
        if titleTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Project name can't be empty", caller: self)
            return false
        }
        return true
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let reset = resetToDefaults {
            datePicker.minimumDate = nil
            datePicker.maximumDate = nil
            reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
