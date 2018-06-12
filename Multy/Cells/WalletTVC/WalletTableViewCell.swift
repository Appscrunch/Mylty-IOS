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
    
    @IBOutlet weak var viewForShadow: UIView!
    
    var isBorderOn = false
    
    var wallet: UserWalletRLM?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setupShadow()
//        self.backView.layer.shadowColor = UIColor.black.cgColor
//        self.backView.layer.shadowOpacity = 0.1
//        self.backView.layer.shadowOffset = .zero
//        self.backView.layer.shadowRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupShadow() {
        viewForShadow.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.6))
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
        let blockchainType = BlockchainType.create(wallet: wallet!)
        self.tokenImage.image = UIImage(named: blockchainType.iconString)
        self.walletNameLbl.text = self.wallet!.name
        self.cryptoNameLbl.text = blockchainType.shortName
        self.fiatSumLbl.text = wallet!.sumInFiatString + " " + self.wallet!.fiatSymbol
        // FIXME: refactor
        if blockchainType.blockchain == BLOCKCHAIN_BITCOIN {
            self.cryptoSumLbl.text  = self.wallet!.sumInCrypto.fixedFraction(digits: 8)
        } else if blockchainType.blockchain == BLOCKCHAIN_ETHEREUM {
            let sumInCrypto = wallet!.ethWallet!.allBalance
            self.cryptoSumLbl.text  = sumInCrypto.cryptoValueString(for: BLOCKCHAIN_ETHEREUM)
        }
    
        if wallet != nil {
            self.statusImage.isHidden = !wallet!.isTherePendingTx.boolValue
        }
    }
}
