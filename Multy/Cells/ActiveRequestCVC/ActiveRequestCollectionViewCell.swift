//
//  ActiveRequestCollectionViewCell.swift
//  Multy
//
//  Created by Artyom Alekseev on 16.05.2018.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import UIKit

class ActiveRequestCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var requestImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        requestImage.layer.cornerRadius = requestImage.frame.size.width/2
        requestImage.layer.masksToBounds = true
    }

    var request : PaymentRequest?
    
    func fillInCell() {
        if request != nil {
            requestImage.backgroundColor  = request!.color
        }
    }
}
