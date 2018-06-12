//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = CreateOrRestoreBtnTableViewCell

class CreateOrRestoreBtnTableViewCell: UITableViewCell {

    @IBOutlet weak var content: UIView!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.content.backgroundColor = UIColor(red: 236/255, green: 238/255, blue: 247/255, alpha: 1.0)
        
//        self.backView.layer.shadowColor = UIColor.black.cgColor
//        self.backView.layer.shadowOpacity = 0.1
//        self.backView.layer.shadowOffset = .zero
//        self.backView.layer.shadowRadius = 2
        
        setupShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func makeRestoreCell() {
        self.leftImage.image = #imageLiteral(resourceName: "restoreMulty")
        self.mainLabel.text = localize(string: Constants.restoreMultyString)
    }
    
    func setupShadow() {
        shadowView.setShadow(with: UIColor.gray)
    }
    
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
    }
}
