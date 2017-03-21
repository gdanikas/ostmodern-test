//
//  FavoritesButton.swift
//  ostest
//
//  Created by George Danikas on 14/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit

final class FavoritesButton: UIButton {

    /// Images for styling
    fileprivate let imageOn = #imageLiteral(resourceName: "ic-favourites-active")
    fileprivate let imageOff = #imageLiteral(resourceName: "ic-favourites")
    
    /// Touch offsets (ensuring to reach the minimum target size of 44px wide 44px height - according to HIG)
    fileprivate let touchTopOffset: CGFloat = 30.0
    fileprivate let touchLeftOffset: CGFloat = 30.0
    fileprivate let touchBottomOffset: CGFloat = 30.0
    fileprivate let touchRightOffset: CGFloat = 30.0
    
    fileprivate let notification = Notification.Name(rawValue: "FavoriteButtonUpdated")
    
    var isFavorite: Bool = false {
        didSet {
            setImage(isFavorite ? imageOn  : imageOff, for: .normal)
        }
    }
    
    var identifier: String!
    
    /// Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Overriding touch offsets
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let  touchEdgeInsets = UIEdgeInsets(top: -touchTopOffset,
                                            left: -touchLeftOffset,
                                            bottom: -touchBottomOffset,
                                            right: -touchRightOffset)
        let touchFrame = UIEdgeInsetsInsetRect(bounds, touchEdgeInsets)
        return touchFrame.contains(point)
    }
    
    fileprivate func setup() {
        /// Initializers
        addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
        
        /// Add notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.catchNotification(notification:)), name: notification, object: nil)
    }
    
    func catchNotification(notification: Notification) -> Void {
        guard let userInfo = notification.userInfo,
            let identifier = userInfo["identifier"] as? String,
            let isFavorite = userInfo["isFavorite"] as? Bool else {
            print("No userInfo found in notification")
            return
        }
        
        if self.identifier == identifier {
            self.isFavorite = isFavorite
        }
    }
    
    func reset() {
        identifier = ""
        isFavorite = false
        setImage(imageOff, for: .normal)
    }

    /// MARK: - Actions
    
    @objc fileprivate func buttonPressed() {
        isFavorite = !isFavorite
        
        let nc = NotificationCenter.default
        nc.post(name: notification,
                object: nil,
                userInfo: ["identifier": identifier, "isFavorite": isFavorite])
    }
    
    deinit {
        /// Remove notification
        NotificationCenter.default.removeObserver(self, name: notification, object: nil)
    }
}
