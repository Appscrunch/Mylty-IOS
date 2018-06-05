//
//  WalletCollectionViewCell.swift
//  Multy
//
//  Created by Artyom Alekseev on 15.05.2018.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import UIKit
import Lottie

class WalletCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tokenImage: UIImageView!
    @IBOutlet weak var walletNameLbl: UILabel!
    @IBOutlet weak var cryptoSumLbl: UILabel!
    @IBOutlet weak var cryptoNameLbl: UILabel!
    @IBOutlet weak var fiatSumLbl: UILabel!
    @IBOutlet weak var viewForShadow: UIView!
    
    var wallet: UserWalletRLM?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupShadow()
    }
    
    func setupShadow() {
        viewForShadow.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.6))
    }
    
    func fillInCell() {
        let blockchainType = BlockchainType.create(wallet: wallet!)
        self.tokenImage.image = UIImage(named: blockchainType.iconString)
        let sumInFiat = wallet!.sumInFiat.fixedFraction(digits: 2)
        self.walletNameLbl.text = self.wallet!.name
        self.cryptoSumLbl.text  = self.wallet!.sumInCrypto.fixedFraction(digits: 8)
        self.cryptoNameLbl.text = blockchainType.shortName
        self.fiatSumLbl.text = "\(sumInFiat) \(self.wallet!.fiatSymbol)"
    }
}
