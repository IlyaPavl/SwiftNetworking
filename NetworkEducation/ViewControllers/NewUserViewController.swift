//
//  NewUserViewController.swift
//  NetworkEducation
//
//  Created by Ilya Pavlov on 30.08.2023.
//

import UIKit

final class NewUserViewController: UIViewController {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    
    var delegate: NewUserViewControllerDelegate?
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let user = User(id: 0, firstName: firstNameTF.text ?? "", lastName: lastNameTF.text ?? "")
        delegate?.createUser(user)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    

}

