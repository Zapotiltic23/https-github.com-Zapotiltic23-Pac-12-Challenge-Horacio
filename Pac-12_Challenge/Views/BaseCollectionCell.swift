//
//  BaseCell.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/14/21.
//

import Foundation
import UIKit

class BaseCollectionCell: UICollectionViewCell{
            
    /*
        Base Cell class that inehrets from UICollectionViewCell
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
    
    func setupViews() {
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}//End of class BaseCell
