//
//  SetViewCell.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

/**
 The set view cell that shows a episode on the home screen
 */
final class SetViewCell : UITableViewCell {
    
    /// Reuse identifier
    static let identifier = "SetViewCellID"
    
    /// Image view for the background
    @IBOutlet weak var imgBackground : UIImageView?
    
    /// The title label
    @IBOutlet weak var lblTitle : UILabel?
    
    /// The summary label to show the description
    @IBOutlet weak var txtDescription : UILabel?
    
    /// Favourite
    @IBOutlet weak var btnFavourite : FavoritesButton?
    
    var btnnFavouriteTapBlock : ((_ isFavorite: Bool?) -> Void)?
    
    var viewModel: Episode? {
        didSet {
            bindViewModel()
        }
    }
    
    func bindViewModel() {
        guard let model = viewModel else {
            prepareForReuse()
            return
        }
        
        /// Background image
        if let url = URL(string: model.imageURL) {
            imgBackground?.af_setImage(withURL: url)
        } else {
            imgBackground?.image = UIImage(named: "plc-no-image")
        }
        
        /// Title
        lblTitle?.text = model.title
        
        /// Description
        txtDescription?.text = model.summary
        
        /// Favorite button
        btnFavourite?.isFavorite = model.isFavorite
        btnFavourite?.identifier = model.uid
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgBackground?.af_cancelImageRequest()
        imgBackground?.layer.removeAllAnimations()
        imgBackground?.image = UIImage(named: "plc-no-image")
        
        lblTitle?.text = ""
        txtDescription?.text = ""
        
        btnFavourite?.reset()
    }
    
    /// MARK: - Actions
    
    @IBAction func btnFavouritePressed(_ sender: Any) {
        if let block = btnnFavouriteTapBlock {
            block(btnFavourite?.isFavorite)
        }
    }
}
