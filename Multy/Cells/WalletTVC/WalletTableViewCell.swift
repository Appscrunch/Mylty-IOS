//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tokenImage: UIImageView!
    @IBOutlet weak var walletNameLbl: UILabel!
    @IBOutlet weak var cryptoSumLbl: UILabel!
    @IBOutlet weak var cryptoNameLbl: UILabel!
    @IBOutlet weak var fiatSumLbl: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var statusImage: UIImageView!
    
    var isBorderOn = false
    
    var wallet: UserWalletRLM?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.backView.layer.shadowColor = UIColor.black.cgColor
        self.backView.layer.shadowOpacity = 0.1
        self.backView.layer.shadowOffset = .zero
        self.backView.layer.shadowRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
//    func makeshadow() {
//        self.backView.dropShadow(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 1.0, offSet: CGSize(width: -1, height: 1), radius: 4, scale: true)
//    }
    
    func makeBlueBorderAndArrow() {
        self.backView.layer.borderWidth = 2
        self.backView.layer.borderColor = #colorLiteral(red: 0, green: 0.4823529412, blue: 1, alpha: 1)
        self.arrowImage.image = #imageLiteral(resourceName: "checkmark")
        self.isBorderOn = true
    }
    
    func clearBorderAndArrow() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat, .autoreverse], animations: {
            self.backView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }, completion:nil)
        
        self.backView.layer.borderWidth = 0
        self.arrowImage.image = nil
        self.isBorderOn = false
    }
    
    func fillInCell() {
//        if self.wallet?.cryptoName == "BTC" {
            self.tokenImage.image = #imageLiteral(resourceName: "btcIconBig")
//        }
        let sumInFiat = (self.wallet!.sumInCrypto * exchangeCourse).fixedFraction(digits: 2)
        self.walletNameLbl.text = self.wallet!.name
        self.cryptoSumLbl.text  = self.wallet!.sumInCrypto.fixedFraction(digits: 8)
        self.cryptoNameLbl.text = self.wallet!.cryptoName
        self.fiatSumLbl.text = "\(sumInFiat) \(self.wallet!.fiatSymbol)"
        
        if wallet != nil {
            self.statusImage.isHidden = !wallet!.isTherePendingAmount()
        }
    }
}
