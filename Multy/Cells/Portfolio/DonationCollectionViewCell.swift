//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = DonationCollectionViewCell

class DonationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var midLbl: UILabel!
    @IBOutlet weak var botView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUIfor(view: botView)
    }
    
    func makeCellBy(index: Int) {
        switch index {
        case 0:
            self.backgroundImg.image = #imageLiteral(resourceName: "portfolioDonationImage")
            self.midLbl.text = localize(string: Constants.cryptoPortfolioString)
        case 1:
            self.backgroundImg.image = #imageLiteral(resourceName: "chartsDonationImage")
            self.midLbl.text = localize(string: Constants.currenciesChartsString)
        default: break
        }
    }
    
    func setupUIfor(view: UIView) {
        view.layer.shadowColor = #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.6)
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
//        if screenHeight == heightOfiPad || screenHeight == heightOfFive {   // ipad fix
//            self.backgroundImg.contentMode = .scaleToFill
//        }
    }

}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
    }
}
