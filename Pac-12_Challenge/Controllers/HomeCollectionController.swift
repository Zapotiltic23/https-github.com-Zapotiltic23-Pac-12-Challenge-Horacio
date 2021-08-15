//
//  ViewController.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/12/21.
//

import UIKit

class HomeCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    
    fileprivate var pac12ImageLogo : UIImageView = {
        
        let logoImage = UIImage(named: "pac12")
        let logo = UIImageView(image: logoImage)
        logo.contentMode = .scaleAspectFit
        
        return logo
        
    }()
    
    fileprivate var loadingLogo : UIImageView = {
        
        let logoImage = UIImage(named: "pac12")
        let logo = UIImageView(image: logoImage)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        
        return logo
        
    }()
    
    fileprivate var mxnLogo : UIImageView = {
        
        let logoImage = UIImage(named: "MxN")
        let logo = UIImageView(image: logoImage)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        
        return logo
        
    }()
    
    fileprivate var loadingSpinner : UIActivityIndicatorView = {
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.backgroundColor = .pac12NavyBlue
        spinner.color = .white
        
        return spinner
        
    }()
    
    fileprivate lazy var VODCardWidth : CGFloat = view.bounds.width
    fileprivate lazy var VODCardHeight : CGFloat = view.bounds.height / 2
    fileprivate var vodModels = [VODModel]()
    fileprivate let cellID = "VODCell"
    let is_iPad : Bool = {return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad}()
    fileprivate var pac12VODsEndPoint : String = "http://api.pac-12.com/v3/vod?page=&pagesize=10&sort=&sports=&school=&events=&tags=&start=&end=&playlists=&published_by=&publish_to=&publish_to_mobile=&content_types=&show="
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadVODs), name:NSNotification.Name(rawValue: "reloadHomeController"), object: nil)

    }//End of viewWillAppear()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "reloadHomeController"), object: nil)

    }//End of viewWillDisappear()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setUpConstraints()
        setUpNavigationBar()
        setupCollectionView()
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else {return}
            self.loadVODModels(url: self.pac12VODsEndPoint)
        }
        
    }//End of viewDidLoad()
    
    
    fileprivate func updateLoadingIndicatorConstraints(){
        
        /*
            Updates the loading indicator constraints when infinity
            scrolling is enabled.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        loadingSpinner.removeConstraints(loadingSpinner.constraints)
        loadingSpinner.removeFromSuperview()
        self.view.addSubview(loadingSpinner)
        
        loadingSpinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        loadingSpinner.heightAnchor.constraint(equalToConstant: 80).isActive = true
        loadingSpinner.widthAnchor.constraint(equalToConstant: 80).isActive = true

    }//End of updateLoadingIndicatorConstraints()

    @objc private func loadVODs(){
        
        /*
            Reloads collection view. Called from the NotificationCenter
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        self.collectionView.reloadData()
        
    }//End of loadVODs()

    fileprivate func setUpConstraints(){
        
        /*
            Adds all views and constraints on the UIcollectionViewController. Do additional layouts.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        self.view.addSubview(loadingLogo)
        self.view.addSubview(loadingSpinner)
        loadingSpinner.startAnimating()
        
        loadingLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingLogo.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loadingLogo.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4).isActive = true
        loadingLogo.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3).isActive = true
        
        loadingSpinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingSpinner.topAnchor.constraint(equalTo: loadingLogo.bottomAnchor).isActive = true
        loadingSpinner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loadingSpinner.widthAnchor.constraint(equalToConstant: 50).isActive = true

    }//End of setUpConstraints()

    fileprivate func setupCollectionView(){
        
        /*
            Perform collectionview setup for VOD cards.
            In specific, register a custom cell class and cosmetic changes
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        self.collectionView.register(VODCell.self, forCellWithReuseIdentifier: cellID)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .pac12NavyBlue
        self.collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        self.collectionView.showsVerticalScrollIndicator = false
        
    }//End of setupCollectionView()

    fileprivate func setUpNavigationBar(){
        
        /*
            Perform navbar setup for the UICollectionViewController.
            Adds titles, logos & styles to the navbar.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        let pacLogo = UIBarButtonItem(customView: pac12ImageLogo)
        let mxnLogo = UIBarButtonItem(customView: mxnLogo)
        
        pacLogo.customView?.translatesAutoresizingMaskIntoConstraints = false
        pacLogo.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        pacLogo.customView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        mxnLogo.customView?.translatesAutoresizingMaskIntoConstraints = false
        mxnLogo.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        mxnLogo.customView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.navigationController?.navigationBar.barTintColor = .pac12NavyBlue
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.leftBarButtonItem = pacLogo
        self.navigationItem.rightBarButtonItem = mxnLogo
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "TradeGothicLT-Bold", size: 10)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        guard let titleFont = UIFont(name: "TradeGothicLT-Bold", size: 25) else {
            self.navigationItem.title = "Videos On Demand"
            return
        }
        
        let navBarTitleLabel = UILabel()
        navBarTitleLabel.text = "Videos On Demand"
        navBarTitleLabel.font = titleFont
        navBarTitleLabel.textColor = .white
        self.navigationItem.titleView = navBarTitleLabel

    }//End of setUpNavigationBar()

    func loadVODModels(url: String){
        
        /*
            Fetchs and loads 10 VODs on to the collectionview. The fetching & loading
            dynamic happens serially to ensure this function can download all data
            before loading the models. After the models are loaded, the next 10 VODs
            are inserted and displayed onto the collectionview,
         
            Params [IN]:
            [IN]: url - Pac-12's endpoint string
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        ConnectionManager.shared.fetchVODS(urlString: url, downloadCompletion: {[weak self](loadedModels) in
            
            guard let self = self else {return}
            guard let models = loadedModels else {
                self.handleIncompleteDownload()
                return
            }
            
            //I need to create the next 10 indexPaths in which to insert my new VODs...
            let n = max(self.vodModels.count,0)
            let x = max(models.count,0)
            let range : [Int] = [Int](n..<n+x)
            let paths = range.map({IndexPath(item: $0, section: 0)})
            
            //Append the next 10 VODs to our model array & reload ...
            self.vodModels.append(contentsOf: models)
            self.collectionView.insertItems(at: paths)
            self.collectionView.reloadItems(at: paths)
            self.loadingLogo.alpha = 0
            self.loadingSpinner.alpha = 0
            self.loadingSpinner.stopAnimating()
        })
        
    }//End of loadVODModels()

    func handleIncompleteDownload(){
        
        /*
            Display an alert if an error was encountered while quering Pac-12's servers,
            deserializing payloads, unwrapping objects etc. You are given the option to
            re-try downloading or simply dismiss.
         
            Params [IN]:
            [IN]: N/A
            
            Returns [OUT]:
            [OUT]: N/A
        */
        
        let alertTitle : String = "Unable to Load VODs"
        let message : String = "There's no more content or and error ocurred while loading!"
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        let manageSubscriptionAction = UIAlertAction(title: "Try again?", style: .default) { [weak self] (action) in
            // handle response here.'
            guard let self = self else {return}
            self.loadVODModels(url: self.pac12VODsEndPoint)
        }
        
        manageSubscriptionAction.setValue(UIColor.white, forKey: "titleTextColor")
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        alert.addAction(manageSubscriptionAction)

        self.present(alert, animated: true)
        
    }//End of handleIncompleteDownload()
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        vodModels.count
        
    }//End of numberOfItemsInSection()
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let vodCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! VODCell
        let image = vodModels[indexPath.item].thumbnailImage
        let currentDuration = vodModels[indexPath.item].duration ?? 0

        vodCell.titleLabel.text = vodModels[indexPath.item].title
        vodCell.thumbnailImageView.image = image
        vodCell.schoolNames = vodModels[indexPath.item].schoolNames ?? [String]()
        vodCell.sportNames = vodModels[indexPath.item].sportNames ?? [String]()
        vodCell.schoolCrests = vodModels[indexPath.item].schoolImages ?? [UIImage]()
        vodCell.sportIcons = vodModels[indexPath.item].sportIcons ?? [UIImage]()
        vodCell.durationLabel.text = (currentDuration / 1000).astimeIntervalMinSec()
//        vodCell.durationLabel.layer.cornerRadius = vodCell.durationLabel.frame.width / 12

        vodCell.layer.cornerRadius = VODCardWidth / 20
        vodCell.schoolNamesTableView.reloadData()
        vodCell.sportsNamesTableView.reloadData()
        
        return vodCell
        
    }//End of cellForItemAt()
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Let's figure out VOD card height ...
        let heightDivisor : CGFloat = 1.5
        var padding : CGFloat = 20
        let horizontalPaddings : CGFloat = 2.0
        
        if is_iPad{
            padding = 120
        }else{
            padding = 20
        }
        
        let w = view.bounds.width - (padding * horizontalPaddings)
        let h = view.bounds.height / heightDivisor
        
        VODCardHeight = h
        VODCardWidth = w
        
        return CGSize(width: w, height: h)
        
    }//End of sizeForItemAt()
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 30
        
    }//End of minimumLineSpacingForSectionAt()
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         
        //We reached the end of the collection view, lets load the next 10 VODs...
        if (indexPath.row == vodModels.count - 1 ) {
            
            //Unwrap next page's url ...
            guard let nextURL = vodModels.last?.nextPageURL else {
                handleIncompleteDownload()
                return
            }
            pac12VODsEndPoint = nextURL
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                
                //Load VODs in the background ...
                guard let self = self else {return}
                self.loadVODModels(url: self.pac12VODsEndPoint)
                
                DispatchQueue.main.async {[weak self] in
                    
                    //Invoke loading spinner to indicate activity ...
                    guard let self = self else {return}
                    self.updateLoadingIndicatorConstraints()
                    self.loadingSpinner.startAnimating()
                    self.loadingSpinner.alpha = 1
                    self.loadingSpinner.backgroundColor = .pac12MainBlue
                    self.loadingSpinner.color = .white
                    self.loadingSpinner.layer.cornerRadius = self.loadingSpinner.bounds.width / 6
                    
                }//End of DispatchQueue.main()
                
            }//End of DispatchQueue.global()

        }//End of conditional

    }//End of willDisplay()
    
    
    
    


}

