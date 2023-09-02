//
//  UsersListViewController.swift
//  NetworkEducation
//
//  Created by Ilya Pavlov on 22.08.2023.
//

import UIKit
import Alamofire

protocol NewUserViewControllerDelegate{
    func createUser(_ user: User)
}

final class UsersListViewController: UITableViewController {
    
    private var users = [User]()
    private let networkManager = NetworkManager.shared
    private var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        navigationItem.title = "Заголовок"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        fetchUsers()
                
        showSpinner(in: tableView)
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser"  {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            let user = users[indexPath.row]
            
            let userVC = segue.destination as? UserViewController
            userVC?.user = user
        } else if segue.identifier == "newUser" {
            let navigationVC = segue.destination as? UINavigationController
            let newUserVC = navigationVC?.topViewController as? NewUserViewController
            newUserVC?.delegate = self
        }
    }
    
    // MARK: - Private methods
    
    private func showAlert(withError networkError: AFError) {
        let alert = UIAlertController(title: networkError.localizedDescription, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showSpinner(in view: UIView) {
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}




// MARK: - Networking

extension UsersListViewController {
    private func fetchUsers() {
        networkManager.fetchUsers { [weak self] result in
            self?.activityIndicator.stopAnimating()

            switch result {

            case .success(let users):
                self?.users = users

            case .failure(let error):
                print("error in fetchUsers - \(error)")
                self?.showAlert(withError: error)
            }
            self?.tableView.reloadData()
        }
    }
    
    
    private func post(user: User) {
        networkManager.post(user) { [weak self] result in
            switch result {
            case .success(let postUserQuery):
                // создать пользователя в usreList
                print("\(postUserQuery)")
                self?.users.append(User(postUserQuery: postUserQuery))
                self?.tableView.reloadData()
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
    private func deleteUserWith(id: Int, at indexPath: IndexPath) {
        // старый способ конфигурации удаления
        networkManager.deleteUser(with: id) { [weak self] success in
            if success {
                print("User \(id) is deleted")
                self?.users.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                self?.showAlert(withError: .explicitlyCancelled)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension UsersListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserTableViewCell else { return UITableViewCell() }
        
        // создаем пользователя для ячейки
        let user = users[indexPath.row]
        
        cell.configureCell(with: user)
        /*
         оформляем ячейку (для ячейки по умолчанию)
         var content = cell.defaultContentConfiguration()
         content.text = user.firstName
         content.secondaryText = user.lastName
         
         content.image = UIImage(systemName: "face.smiling")
         cell.contentConfiguration = content
         
         // подягиваем аватарку
         networkManager.fetchAvatar(from: user.avatar) { imageData in
         content.image = UIImage(data: imageData)
         content.imageProperties.cornerRadius = tableView.rowHeight / 2
         
         cell.contentConfiguration = content
         }
         */
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = users[indexPath.row]
            deleteUserWith(id: user.id, at: indexPath)
        }
    }
}

// MARK: - NewUserVCDelegate

extension UsersListViewController: NewUserViewControllerDelegate {
    func createUser(_ user: User) {
        post(user: user)
    }
}
