//
//  EpisodeDetailsHeaderView.swift
//  ostest
//
//  Created by George Danikas on 15/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit

protocol EpisodeDetailsHeaderViewDelegate: class {
    func imageFetchedWithSuccess()
}

final class EpisodeDetailsHeaderView: UITableViewHeaderFooterView {
    
    /// Reuse identifier
    static let identifier = "EpisodeDetailsHeaderID"

    @IBOutlet weak var imgBackground : UIImageView?
    @IBOutlet weak var playVideoImageView: UIImageView?
    @IBOutlet weak var btnFavourite: FavoritesButton?
    
    weak var delegate: EpisodeDetailsHeaderViewDelegate?
    
    var viewModel: Episode? {
        didSet {
            bindViewModel()
        }
    }
    
    func bindViewModel() {
        guard let model = viewModel else {
            return
        }
        
        /// Set background image
        if let url = URL(string: model.imageURL) {
            imgBackground?.af_setImage(
                withURL: url,
                placeholderImage: UIImage(named: "plc-no-image"),
                imageTransition: .crossDissolve(3.0),
                completion: { (dataResponse) in
                    
                    if dataResponse.result.isSuccess {
                        /// Show play video image view
                        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                            self.playVideoImageView?.alpha = 1.0
                        }) { (_) in }
                        
                        self.delegate?.imageFetchedWithSuccess()
                    }
                    
            })
            
        }
        
        /// Set favorite button properties
        btnFavourite?.isFavorite = model.isFavorite
        btnFavourite?.identifier = model.uid
        
        /// Add button action
        btnFavourite?.addTarget(self, action: #selector(self.btnFavouritePressed(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @IBAction func btnFavouritePressed(_ sender: Any) {
        guard let model = viewModel, let btnFavourite = sender as? FavoritesButton else {
            return
        }
        
        Database.instance.updateFavorite(for: model, isFavorite: btnFavourite.isFavorite)
    }

}
