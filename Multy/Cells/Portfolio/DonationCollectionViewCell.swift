//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

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
            self.midLbl.text = "Crypto portfolio"
        case 1:
            self.backgroundImg.image = #imageLiteral(resourceName: "chartsDonationImage")
            self.midLbl.text = "Currencies charts"
        default: break
        }
    }
    
    func setupUIfor(view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        if screenHeight == heightOfiPad || screenHeight == heightOfFive {   // ipad fix
            self.backgroundImg.contentMode = .scaleToFill
        }
    }

}
