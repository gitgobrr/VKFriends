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
        self.friendsTableView.reloadData()
    }
    
    @IBAction func refresh() {
        guard let user = profileModel.user else { return }
        profileModel.loadFriends(of: user)
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
        profileModel.delegate = self
        profileModel.loadProfile(1)
        friendsCount.adjustsFontSizeToFitWidth = true
    }
    
    let profileModel = Profile()
    
    var friendList: [User] = []
    
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
            cell.userName.text = user.name()
            profileModel.loadImage(url: user.photo100) { image in
                cell.img.image = UIImage(data: image)
                cell.img.roundImage()
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
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == "info cell" {
            var strToCopy = cell?.textLabel?.text
            strToCopy?.removeFirst(4)
            UIPasteboard.general.string = strToCopy
            return
        }
        
        friendList[indexPath.section].isCollapsed.toggle()
        tableView.reloadSections([indexPath.section], with: .automatic)
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
        profileModel.loadImage(url: user.photoMax) { imageData in
            self.userImage.image = UIImage(data: imageData)
            self.userImage.roundImage()
        }
        if user.isClosed != nil {
            if user.isClosed! {
                friendsCount.text = "profile is private"
                friendList = []
                friendsTableView.reloadData()
                return
            }
        } else {
            friendsCount.text = "profile deactivated"
            friendList = []
            friendsTableView.reloadData()
            return
        }
        profileModel.loadFriends(of: user)
    }
    
    func updateFriends(_ friends: [User]) {
        friendList = friends
        friendsCount.text = friends.count == 1 ? "1 Friend" : "\(friends.count) Friends"
        option.selectedSegmentIndex = 0
        friendsTableView.reloadData()
        if friends.count > 0 {
            friendsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func displayError(_ errorMessage: String) {
        friendsCount.text = errorMessage
    }
}
