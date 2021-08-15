//
//  VODModel.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/12/21.
//

import Foundation
import UIKit

enum PayloadKeys : String, CaseIterable{
    
    /*
        Use these keys to load VODModel objects
    */
    
    case Programs = "programs"
    case NextPage = "next_page"
    case VODDuration = "duration"
    case Images = "images"
    case VODTitle = "title"
    case MediumImageSize = "medium"
    case TinyImageSize = "tiny"
    case VODSchools = "schools"
    case VODSports = "sports"
    case ItemID = "id"
    case ItemName = "name"
    case SportIcon = "icon"

}


public struct VODModel{
    
    /*
        VOD Swift Model
    */
    
    var duration : TimeInterval?
    var thumbnailImage : UIImage?
    var schoolImages : [UIImage]?
    var sportIcons : [UIImage]?
    var schoolNames : [String]?
    var sportNames : [String]?
    var schoolIDs : [String]?
    var sportIDs : [String]?
    var title : String?
    var nextPageURL : String?
    
}
