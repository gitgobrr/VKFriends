//
//  UserImage+CoreDataProperties.swift
//  FinalProject
//
//  Created by sergey on 21.06.2023.
//
//

import Foundation
import CoreData
import UIKit


extension UserImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserImage> {
        return NSFetchRequest<UserImage>(entityName: "UserImage")
    }

    @NSManaged public var image: UIImage?
    @NSManaged public var url: URL?

}
