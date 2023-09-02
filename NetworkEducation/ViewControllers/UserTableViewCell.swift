//
//  UserTableViewCell.swift
//  NetworkEducation
//
//  Created by Ilya Pavlov on 27.08.2023.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    func configureCell(with user: User) {
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        if user.avatar != nil {
            avatarImageView.kf.setImage(with: user.avatar)
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }

}
