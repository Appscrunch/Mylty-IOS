//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class TransactionPendingCell: UITableViewCell {
//    @IBOutlet weak var transactionImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cryptoAmountLabel: UILabel!
    @IBOutlet weak var fiatAmountLabel: UILabel!

    @IBOutlet weak var lockedCryptoAmountLabel: UILabel!
    @IBOutlet weak var lockedFiatAmountLabel: UILabel!
    
    var wallet : UserWalletRLM?
    var histObj = HistoryRLM()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func fillCell() {
        if histObj.txInputs.count == 0 {
            return 
        }
        self.addressLabel.text = histObj.txInputs[0].address
        
        self.cryptoAmountLabel.text = "\(convertSatoshiToBTC(sum: histObj.txOutAmount.uint32Value).fixedFraction(digits: 8)) BTC"
        self.fiatAmountLabel.text = "\((convertSatoshiToBTC(sum: histObj.txOutAmount.uint32Value) * histObj.btcToUsd).fixedFraction(digits: 2)) USD"
        
        
//        if histObj.txStatus.intValue == TxStatus.BlockIncoming.rawValue {
//            lockedCryptoAmountLabel.text = "\"
//            lockedFiatAmountLabel.text = "\((amountInDouble * histObj.btcToUsd).fixedFraction(digits: 2))"
//        } else if histObj.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
//
//        }
        
        let amount = blockedAmount()
        let amountInDouble = convertSatoshiToBTC(sum: amount)
        lockedCryptoAmountLabel.text = "\(amountInDouble.fixedFraction(digits: 8)) BTC"
        lockedFiatAmountLabel.text = "\((amountInDouble * histObj.btcToUsd).fixedFraction(digits: 2)) USD"
    }
    
    func calculateAmount(transactions: List<TxHistoryRLM>) -> UInt32 {
        var sum = UInt32()
        
        transactions.forEach({ sum += $0.amount.uint32Value })
        
        return sum
    }
    
//    func setCorners() {
//        let maskPath = UIBezierPath.init(roundedRect: bounds,
//                                         byRoundingCorners:[.topLeft, .topRight],
//                                         cornerRadii: CGSize.init(width: 15.0, height: 15.0))
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = bounds
//        maskLayer.path = maskPath.cgPath
//        layer.mask = maskLayer
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func blockedAmount() -> UInt32 {
        var sum = UInt32(0)
        
        if histObj.txStatus.intValue == TxStatus.MempoolIncoming.rawValue {
            sum += histObj.txOutAmount.uint32Value
        } else if histObj.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
            let addresses = wallet!.fetchAddresses()
            
            for tx in histObj.txOutputs {
                if addresses.contains(tx.address) {
                    sum += tx.amount.uint32Value
                }
            }
        }
        
        return sum
    }
}
