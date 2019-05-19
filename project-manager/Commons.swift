//
//  Commons.swift
//  project-manager
//
//  Created by Gayashan Bombuwala on 5/19/19.
//  Copyright © 2019 Gayashan Bombuwala. All rights reserved.
//

import UIKit

class Utilities {
    
    static var alert: UIAlertController!
    
    typealias actionHandler = ()  -> Void
    
    static func showConfirmationAlert (title: String, message: String, yesAction: @escaping actionHandler = {() in}, noAction: @escaping actionHandler = {() in}, caller: UIViewController) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            yesAction()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { action in
            noAction()
        }))
        caller.present(alert, animated: true, completion: nil)
    }
}
