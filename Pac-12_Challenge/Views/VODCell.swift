//
//  VODCell.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/14/21.
//

import Foundation
import UIKit

class VODCell: BaseCollectionCell, UITableViewDelegate, UITableViewDataSource{
    
    var thumbnailImageView : UIImageView = {
        
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
    
    var titleLabel : UILabel = {
        
        let title = PaddedLabel(withInsets: 0, 0, 10, 10)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.sizeToFit()
        title.textAlignment = .natural
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 4
        title.textColor = .white
        title.layer.borderWidth = 1
        title.layer.borderColor = UIColor.clear.cgColor
        title.backgroundColor = .clear
        title.clipsToBounds = true
        title.isUserInteractionEnabled = false
        
        return title
        
    }()
    
    var durationLabel : UILabel = {
        
        let title = PaddedLabel(withInsets: 0, 0, 5, 5)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.textColor = .white
        title.backgroundColor = .pac12NavyBlue
        title.layer.borderWidth = 1
        title.layer.borderColor = UIColor.clear.cgColor
        title.clipsToBounds = true
        
        return title
        
    }()
    
    fileprivate lazy var dataSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["School", "Sport"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = .pac12MainBlue
        sc.selectedSegmentIndex = 0 //Selects index one by default
        let is_iPad : Bool = {return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad}()
        sc.addTarget(self, action: #selector(handleSegmentedIndexChange), for: .valueChanged)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        var titleFontSize : CGFloat = 18//iPhones

        if is_iPad{
            titleFontSize = 25
        }else{
            titleFontSize = 18
        }
        
        guard let titleFont = UIFont(name: "TradeGothicLT-Bold", size: titleFontSize) else {
            return sc
        }
        sc.setTitleTextAttributes([NSAttributedString.Key.font: titleFont], for: .normal)
        


        return sc
    }()
    
    lazy var schoolNamesTableView: UITableView = {
        
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .pac12NavyBlue
        table.allowsSelection = false
        table.clipsToBounds = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        
        return table
        
    }()
    
    lazy var sportsNamesTableView: UITableView = {
        
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .pac12NavyBlue
        table.allowsSelection = false
        table.clipsToBounds = true
        table.alpha = 0
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        
        return table
        
    }()
    
    fileprivate let schoolNameCellID = "schoolNameCellID"
    fileprivate let sportsNameCellID = "sportsNameCellID"

    var schoolNames : [String]?
    var sportNames : [String]?
    var schoolCrests : [UIImage]?
    var sportIcons : [UIImage]?

    
    override func setupViews() {
        super.setupViews()
        
        self.clipsToBounds = true
        self.backgroundColor = .clear
        addConstraints()
        setUptableView()

        
    }//End of setupViews()

    
    fileprivate func setUptableView(){
        
        /*
            Perform tableview setup for both schools and sports.
            In specific, register custom cell classes
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        schoolNamesTableView.register(SchoolCell.self, forCellReuseIdentifier: schoolNameCellID)
        sportsNamesTableView.register(SportCell.self, forCellReuseIdentifier: sportsNameCellID)

    }//End of setUptableView()

    @objc fileprivate func handleSegmentedIndexChange(){
        
        /*
            Handles a segmented control index change. When the index changes,
            the appropiate table is pushed to the front & made visible to present
            either school or sport names.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        

        if dataSegmentedControl.selectedSegmentIndex == 0{
            
            //When index == 0, present schools...
            self.sendSubviewToBack(sportsNamesTableView)
            self.bringSubviewToFront(schoolNamesTableView)
            sportsNamesTableView.alpha = 0
            schoolNamesTableView.alpha = 1

            schoolNamesTableView.reloadData()
            
        }else{
            
            //Else, present sports...
            self.sendSubviewToBack(schoolNamesTableView)
            self.bringSubviewToFront(sportsNamesTableView)
            sportsNamesTableView.alpha = 1
            schoolNamesTableView.alpha = 0
            
            sportsNamesTableView.reloadData()
        }
            
        
    }//End of handleSegmentedIndexChange()
    
    
    fileprivate func addConstraints(){
        
        /*
            Adds all views and constraints on the cell. Do additional layouts.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        // a+b+c+d = 1
        let a : CGFloat = 0.14 //titleLabel height
        let b : CGFloat = 0.5 //thumbnailImageView height
        let c : CGFloat = 0.06 //dataSegmentedControl height
        let d : CGFloat = 0.3 //sportsNamesTableView & schoolNamesTableView height

        //Add all views/subviews & constraints...
        self.addSubview(titleLabel)
        self.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(durationLabel)
        self.addSubview(dataSegmentedControl)
        self.addSubview(schoolNamesTableView)
        self.addSubview(sportsNamesTableView)
        
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: a).isActive = true
        
        thumbnailImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        thumbnailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: b).isActive = true
        
        durationLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -10).isActive = true
        durationLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -10).isActive = true
        durationLabel.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.1).isActive = true
        durationLabel.widthAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 0.15).isActive = true
        
        dataSegmentedControl.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor).isActive = true
        dataSegmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        dataSegmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        dataSegmentedControl.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: c).isActive = true
        
        schoolNamesTableView.topAnchor.constraint(equalTo: dataSegmentedControl.bottomAnchor).isActive = true
        schoolNamesTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        schoolNamesTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        schoolNamesTableView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: d).isActive = true
        
        sportsNamesTableView.topAnchor.constraint(equalTo: dataSegmentedControl.bottomAnchor).isActive = true
        sportsNamesTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        sportsNamesTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        sportsNamesTableView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: d).isActive = true
        
        self.durationLabel.layer.cornerRadius = 50 / 8
        self.sendSubviewToBack(sportsNamesTableView)
        self.bringSubviewToFront(schoolNamesTableView)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
                
    }//End of addConstraints()
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        thumbnailImageView.image = nil
        sportNames = nil
        schoolNames = nil
        schoolCrests = nil
        sportIcons = nil
        
    }//End of prepareForReuse()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == schoolNamesTableView{
            return schoolNames?.count ?? 0
        }else{
            return sportNames?.count ?? 0
        }
        
    }//End of numberOfRowsInSection()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let placeholderConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: UIImage.SymbolWeight.light, scale: UIImage.SymbolScale.medium)
        let placeholderImage = UIImage(systemName: "questionmark.square.dashed", withConfiguration: placeholderConfig)
        
        if tableView == schoolNamesTableView{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: schoolNameCellID, for: indexPath) as! SchoolCell
            cell.schoolLabel.textColor = .white
            cell.schoolImageView.tintColor = .white
            
            if indexPath.item >= schoolNames?.count ?? 0{
                return cell
            }
            
            cell.schoolImageView.image = schoolCrests?[indexPath.item] ?? placeholderImage
            cell.schoolLabel.text = schoolNames?[indexPath.item]
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: sportsNameCellID, for: indexPath) as! SportCell
            cell.sportLabel.textColor = .white
            cell.sportImageView.tintColor = .white

            if indexPath.item >= sportNames?.count ?? 0{
                return cell
            }
            
            cell.sportImageView.image = sportIcons?[indexPath.item]
            cell.sportLabel.text = sportNames?[indexPath.item]
            
            return cell
            
        }
        
    }//End of cellForRowAt()
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let listRowHeight : CGFloat = tableView.bounds.height / 3
        
        return listRowHeight
        
    }//End of heightForRowAt()
    
    
}
