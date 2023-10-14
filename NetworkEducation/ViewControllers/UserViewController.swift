//
//  UserViewController.swift
//  NetworkEducation
//
//  Created by Ilya Pavlov on 27.08.2023.
//

import UIKit

final class UserViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    

    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        composeUser(user)
    }
    
    private func composeUser(_ user: User) {
        nameLabel.text = "\(user.firstName) \(user.lastName)"

        avatarImageView.kf.setImage(with: user.avatar)
    }

}
