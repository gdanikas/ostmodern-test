//
//  NoDataLabel.swift
//  ostest
//
//  Created by George Danikas on 15/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit

final class NoDataLabel: UILabel {
    fileprivate var emptyMessagge = NSLocalizedString("No data is currently available", comment: "")
    
    convenience init(withFrame frame: CGRect, message: String?) {
        self.init(frame: frame)
        
        if let msg = message {
            emptyMessagge = msg
        }
        
        setupView()
    }
    
    fileprivate func setupView() {
        text = emptyMessagge
        font = UIFont.systemFont(ofSize: 22.0, weight: UIFontWeightLight)
        textColor = .white
        numberOfLines = 0
        textAlignment = .center
        
        sizeToFit()
    }
}
