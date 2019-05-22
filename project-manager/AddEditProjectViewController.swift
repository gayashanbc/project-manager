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
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var prioritySegmentControl: UISegmentedControl!
    @IBOutlet weak var addToCalendarToggle: UISwitch!
    @IBOutlet weak var priorityStackView: UIStackView!
    
    typealias saveFunctionType = (_ viewController: UIViewController) -> Void
    typealias resetToDefaultsFunctionType = () -> Void
    
    var viewTitle: String?
    var hasPriorityStackView: Bool? = true
    var saveFunction: saveFunctionType?
    var resetToDefaults: resetToDefaultsFunctionType?
    var projectPlaceholder: Project?
    var isEditView: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let isEditMode = isEditView else { return }

        viewTitleLabel.text = isEditMode ? "Edit " + viewTitle! : "Add " + viewTitle!
        dueDatePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        if hasPriorityStackView == false {
            priorityStackView.removeFromSuperview()
        }
        
        if let project = projectPlaceholder  {
            titleTextField.text = project.title
            notesTextField.text = project.notes
            dueDatePicker.date = project.dueDate
            prioritySegmentControl.selectedSegmentIndex = project.priority.rawValue
            addToCalendarToggle.isOn = !project.isAddedToCalendar
            addToCalendarToggle.isEnabled = !project.isAddedToCalendar
        }
        
        titleTextField.becomeFirstResponder()
    }
    
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let save = saveFunction else {
            preconditionFailure("Save function not defined")
        }
        
        if validateFields() {
            save(self)
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
            reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
