//
//  ImageURL+CoreDataProperties.swift
//  FinalProject
//
//  Created by sergey on 22.06.2023.
//
//

import Foundation
import CoreData


extension ImageURL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageURL> {
        return NSFetchRequest<ImageURL>(entityName: "ImageURL")
    }

    @NSManaged public var url: String

}
