//
//  CachedImage+CoreDataProperties.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/11/21.
//
//

import Foundation
import CoreData


extension CachedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedImage> {
        return NSFetchRequest<CachedImage>(entityName: "CachedImage")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var imageID: String?

}

extension CachedImage : Identifiable {

}
