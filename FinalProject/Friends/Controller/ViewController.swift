//
//  ViewController.swift
//  vkAPI
//
//  Created by sergey on 18.02.2018.
//  Copyright © 2018 sergey. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFName: UILabel!
    @IBOutlet weak var userLName: UILabel!
    @IBOutlet weak var friendsCount: UILabel!
    @IBOutlet weak var option: UISegmentedControl!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    //MARK: IBAction
    @IBAction func optionChanged() {
        switch self.option.selectedSegmentIndex {
        case 0:
            friendList = profileModel.friends
        case 1:
            friendList = profileModel.onlineFriends
        default:
            friendList = profileModel.offlineFriends
        }
        if friendList.count == 1 {
            self.friendsCount.text = "1 Friend"
        } else {
            self.friendsCount.text = "\(friendList.count) Friends"
        }
        if self.option.selectedSegmentIndex == 0 {
            friendsCount.text = "\(profileModel.friendCount) Friends"
        }
        self.friendsTableView.reloadData()
    }
    
    @IBAction func refresh() {
        guard let user = profileModel.user else { return }
        profileModel.loadFriends(user)
    }
    
    @IBAction func findById(_ sender: UITextField) {
        if let id = Int(sender.text!), id > 0 {
            profileModel.loadProfile(id)
        }
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        userFName.text = ""
        userLName.text = ""
        friendsCount.text = ""
        friendsCount.adjustsFontSizeToFitWidth = true
        friendsTableView.prefetchDataSource = self
        
        profileModel.delegate = self
    }
    
    let profileModel = Profile()
    
    var friendList: [User] = []
    
    private let coreDataManager = CoreDataManager.shared
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: UITableViewDataSource -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        friendList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendList[section].isCollapsed ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = friendList[indexPath.section]
        if indexPath.row == 0 {
            let cell = friendsTableView.dequeueReusableCell(withIdentifier: "user cell")! as! UserCell
            cell.updateCellText(user.name())
            let request = profileModel.loadImage(url: user.photo100) { image in
                let userImg = ImageURL(context: self.coreDataManager.mainContext)
                userImg.url = user.photo100.lastPathComponent
                self.coreDataManager.saveContext()
                cell.updateCellImage(image)
                self.profileModel.imageRequests.removeValue(forKey: indexPath)
            }
            profileModel.imageRequests[indexPath] = request
            cell.onReuse = {
                self.profileModel.imageRequests[indexPath]?.cancel()
                self.profileModel.imageRequests.removeValue(forKey: indexPath)
                cell.updateCellImage(nil)
            }
            return cell
        } else {
            let cell = friendsTableView.dequeueReusableCell(withIdentifier: "info cell")!
            cell.textLabel?.text = "id: \(user.id)"
            return cell
        }
    }
    
    //MARK: UITableViewDelegate -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "My", bundle: .main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "Friends") as? ViewController {
            navigationController?.pushViewController(vc, animated: true)
            vc.profileModel.loadProfile((friendList[indexPath.section].id))
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if friendList.count < profileModel.friendCount {
            if indexPath.section == profileModel.friends.count - 1 {
                profileModel.loadFriends(profileModel.user!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row > 0 { return 44 }
        return 53
    }
    
}

//MARK: ProfileDelegate

extension ViewController: ProfileDelegate {
    func updateUser(_ user: User) {
        userFName.text = user.firstName
        userLName.text = user.lastName
        profileModel.loadImage(url: user.photoMax) { image in
            self.userImage.image = image
            self.userImage.roundImage()
        }
        if friendList.count > 0 {
        friendsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func updateFriends() {
        friendList = profileModel.friends
        friendsCount.text = profileModel.friendCount == 1 ? "1 Friend" : "\(profileModel.friendCount) Friends"
        option.selectedSegmentIndex = 0
        friendsTableView.reloadData()
    }
    
    func displayError(_ errorMessage: String) {
        friendsCount.text = errorMessage
    }
}

// MARK: UITableViewDataSourcePrefetching

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let user = friendList[indexPath.section]
            guard let _ = profileModel.imageRequests[indexPath] else {
                profileModel.imageRequests[indexPath] = profileModel.loadImage(url: user.photo100, completionHandler: { image in
                    let userImg = ImageURL(context: self.coreDataManager.mainContext)
                    userImg.url = user.photo100.lastPathComponent
                    self.coreDataManager.saveContext()
                })
                return
            }
        }
    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let request = profileModel.imageRequests[indexPath] {
                request.cancel()
                profileModel.imageRequests.removeValue(forKey: indexPath)
            }
        }
    }
}
