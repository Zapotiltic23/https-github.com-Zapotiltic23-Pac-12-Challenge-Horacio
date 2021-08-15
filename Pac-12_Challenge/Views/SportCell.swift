//
//  SportCell.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/14/21.
//

import UIKit

class SportCell : BaseTableCell{
    
    var sportImageView : UIImageView = {
        
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
    
    var sportLabel : UILabel = {
        
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
        
        self.selectionStyle = .none
        self.backgroundColor = .pac12NavyBlue
        
    }//End of setupViews()
    
    fileprivate func setUpConstraints(){
        
        /*
            Adds all views and constraints on the cell. Do additional layouts.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        self.addSubview(sportLabel)
        self.addSubview(sportImageView)

        sportImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        sportImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        sportImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6).isActive = true
        sportImageView.widthAnchor.constraint(equalTo: sportImageView.heightAnchor).isActive = true
                
        sportLabel.leadingAnchor.constraint(equalTo: sportImageView.trailingAnchor, constant: 10).isActive = true
        sportLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        sportLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sportLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }//End of setUpConstraints()

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        sportImageView.image = nil
        sportLabel.text = nil
        
    }//End of prepareForReuse()

    
}
