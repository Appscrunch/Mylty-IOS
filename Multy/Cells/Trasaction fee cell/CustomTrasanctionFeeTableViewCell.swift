//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = CustomTrasanctionFeeTableViewCell

class CustomTrasanctionFeeTableViewCell: UITableViewCell {

    @IBOutlet weak var customFeeImage: UIImageView!
    @IBOutlet weak var toplbl: UILabel!
    @IBOutlet weak var middleLbl: UILabel!
    @IBOutlet weak var valuelbl: UILabel!
    @IBOutlet weak var checkImg: UIImageView!
    
    @IBOutlet weak var gasPriceValueLbl: UILabel!
    @IBOutlet weak var gasLimitValueLbl: UILabel!
    @IBOutlet weak var customTopConstraint: NSLayoutConstraint!
    
    var blockchainType: BlockchainType?
    var value = UInt64(0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func constructString() -> String {
//        let sumInCrypto = (Double(value) / 100000000.0) * 225
//        let sumInFiat = sumInCrypto * DataManager.shared.makeExchangeFor(blockchainType: blockchainType!)
//        return "~ " + "\(sumInCrypto.fixedFraction(digits: 8)) BTC / \(sumInFiat.fixedFraction(digits: 2)) USD"
        
        if blockchainType?.blockchain == BLOCKCHAIN_BITCOIN {
            return "\(value) " + localize(string: Constants.satoshiPerByteShortString)
        } else if blockchainType?.blockchain == BLOCKCHAIN_ETHEREUM {
            return "\(value / 1000000000)" + " GWei/Gas"
        } else {
            return ""
        }
    }
    
    func setupUI() {
//        self.middleLbl.isHidden = true
        checkImg.isHidden = false
        toplbl.isHidden = false
        toplbl.text = constructString()
//        self.valuelbl.isHidden = false
//        self.valuelbl.text = "\(Int(self.value))"
    }
    
    func hideCustomPrice() {
        toplbl.isHidden = true
    }
    
    func setupUIFor(gasPrice: Int?, gasLimit: Int?) {
        //        self.middleLbl.isHidden = true
        self.checkImg.isHidden = false
        //        self.toplbl.isHidden = false
        //        self.valuelbl.isHidden = false
        if gasLimit != nil && gasPrice != nil {
            gasLimitValueLbl.text = "\(gasLimit!)"
            gasPriceValueLbl.text = "\(gasPrice!)"
            if customTopConstraint != nil {
                customTopConstraint.constant = 12
            }
        }
        
        //        self.valuelbl.text = "\(Int(self.value))"
    }
    
    func reloadUI() {
        if customTopConstraint != nil {
            self.customTopConstraint.constant = 20
        }
        
        self.middleLbl.isHidden = false
        self.checkImg.isHidden = true
        self.toplbl.isHidden = true
        self.valuelbl.isHidden = true
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
