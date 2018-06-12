//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = NewWalletTableViewCell

class NewWalletTableViewCell: UITableViewCell {

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var cellNameLbl: UILabel!
    @IBOutlet weak var rigthSmallImage: UIImageView!
//    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var content: UIView!
    
    weak var delegate: OpenCreatingSheet?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func openActionSheet() {
        delegate?.openNewWalletSheet()
    }
    
    func setupForSendStartVC() {
        self.content.backgroundColor = UIColor.white
        self.rigthSmallImage.isHidden = true
        self.topLineView.isHidden = true
        self.cellNameLbl.font = UIFont(name: "Avenir Next Medium", size: 16)
        self.cellNameLbl.text = localize(string: Constants.recentAddressesString)
//        self.makeTopCorners()
    }
    
    func makeTopCorners() {
        let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize.init(width: 15.0, height: 15.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func hideAll(flag: Bool) {
        self.cellNameLbl.isHidden = flag
        self.rigthSmallImage.isHidden = flag
        self.content.backgroundColor = UIColor(red: 236/255, green: 238/255, blue: 247/255, alpha: 1.0)
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Wallets"
    }
}
