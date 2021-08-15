//
//  SchoolCell.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/14/21.
//

import UIKit

class BaseTableCell : UITableViewCell{
    
    /*
        Base Cell class that inehrets from UITableViewCell
    */
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()

    }
        
    func setupViews() {

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
    
}


