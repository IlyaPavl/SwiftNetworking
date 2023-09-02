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
    
    /* использовали менеджер, когда нужно было грузить из сети картинку, теперь с помощью KingFisher грузим её в кэш, поэтому и тут комментируем менеджер и в методе
    private let networkManager = NetworkManager.shared
     */
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        composeUser(user)
    }
    
    // метод, который будет заполнять аватар и имя из пользователя
    private func composeUser(_ user: User) {
        nameLabel.text = "\(user.firstName) \(user.lastName)"
//        networkManager.fetchAvatar(from: user.avatar, completion: { [weak self] imageData in
//            self?.avatarImageView.image = UIImage(data: imageData)
//        })
        avatarImageView.kf.setImage(with: user.avatar)
    }

}
