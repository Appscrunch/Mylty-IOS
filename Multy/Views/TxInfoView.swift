//
//  TxInfoView.swift
//  Multy
//
//  Created by Artyom Alekseev on 06.06.2018.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import UIKit

class TxInfoView: UIView {
    
    init(frame: CGRect, sumInCryptoString: String, sumInFiatString: String) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        let sumInCryptoLabel = UILabel(frame: CGRect.zero)
        sumInCryptoLabel.translatesAutoresizingMaskIntoConstraints = false
        sumInCryptoLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
        sumInCryptoLabel.adjustsFontSizeToFitWidth = true
        sumInCryptoLabel.minimumScaleFactor = 0.5
        sumInCryptoLabel.text = sumInCryptoString
        self.addSubview(sumInCryptoLabel)
        
        let sumInFiatLabel = UILabel(frame: CGRect.zero)
        sumInFiatLabel.translatesAutoresizingMaskIntoConstraints = false
        sumInFiatLabel.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        sumInFiatLabel.textColor = #colorLiteral(red: 0.5294117647, green: 0.631372549, blue: 0.7725490196, alpha: 1)
        sumInFiatLabel.adjustsFontSizeToFitWidth = true
        sumInFiatLabel.minimumScaleFactor = 0.5
        sumInFiatLabel.text = sumInFiatString
        self.addSubview(sumInFiatLabel)
        
        let sumInCryptoLabelCenterXConstraint = NSLayoutConstraint(item: sumInCryptoLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let sumInCryptoLabelLeadingConstraint = NSLayoutConstraint(item: sumInCryptoLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20)
        let sumInCryptoLabelTopConstraint = NSLayoutConstraint(item: sumInCryptoLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
        let sumLabelsVerticalSpacingConstraint = NSLayoutConstraint(item: sumInCryptoLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: sumInFiatLabel, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 2)
        let sumInFiatLabelCenterXConstraint = NSLayoutConstraint(item: sumInFiatLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let sumInFiatLabelLeadingConstraint = NSLayoutConstraint(item: sumInFiatLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20)
        let sumInFiatLabelBottomConstraint = NSLayoutConstraint(item: sumInFiatLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -10)
        self.addConstraints([sumInCryptoLabelCenterXConstraint, sumInCryptoLabelLeadingConstraint, sumInCryptoLabelTopConstraint, sumLabelsVerticalSpacingConstraint, sumInFiatLabelCenterXConstraint, sumInFiatLabelLeadingConstraint, sumInFiatLabelBottomConstraint])
        self.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
