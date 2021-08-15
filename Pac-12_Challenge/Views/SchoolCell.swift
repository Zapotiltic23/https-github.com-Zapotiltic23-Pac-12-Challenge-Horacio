//
//  SchoolCell.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/14/21.
//

import UIKit


class SchoolCell : BaseTableCell{
    
    var schoolImageView : UIImageView = {
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: UIImage.SymbolWeight.light, scale: UIImage.SymbolScale.large)
        let placeholderImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: imageConfig)
        let thumbnail = UIImageView(image: placeholderImage)
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.layer.borderWidth = 1
        thumbnail.layer.borderColor = UIColor.clear.cgColor
        thumbnail.clipsToBounds = true
        
        return thumbnail
        
    }()
    
    var schoolLabel : UILabel = {
        
        let title = PaddedLabel(withInsets: 0, 0, 10, 10)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .natural
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 2
        title.textColor = .white
        title.layer.borderWidth = 1
        title.layer.borderColor = UIColor.clear.cgColor
        title.clipsToBounds = true
        
        return title
        
    }()
    
    override func setupViews() {
        super.setupViews()
        setUpConstraints()
        
        self.backgroundColor = .pac12NavyBlue
        self.selectionStyle = .none
        
    }//End of setupViews()
    
    fileprivate func setUpConstraints(){
        
        /*
            Adds all views and constraints on the cell. Do additional layouts.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        self.addSubview(schoolImageView)
        self.addSubview(schoolLabel)
        
        schoolImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        schoolImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        schoolImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6).isActive = true
        schoolImageView.widthAnchor.constraint(equalTo: schoolImageView.heightAnchor).isActive = true
        
        schoolLabel.leadingAnchor.constraint(equalTo: schoolImageView.trailingAnchor, constant: 10).isActive = true
        schoolLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        schoolLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        schoolLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }//End of setUpConstraints()

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        schoolLabel.text = nil
        schoolImageView.image = nil
        
    }//End of prepareForReuse()

    
}
