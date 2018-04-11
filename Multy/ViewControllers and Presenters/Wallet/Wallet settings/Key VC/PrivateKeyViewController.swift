//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class PrivateKeyViewController: UIViewController {

    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var keyLbl: UILabel!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var wallet: UserWalletRLM?
    var account: AccountRLM?
    var addressID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.presentedVC = self
        
        setupUI()
    }
    
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        whiteView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15.0)
        if screenHeight == heightOfiPad {
            heightConstraint.constant = 460
        }
        self.keyLbl.text = makePrivateKey()
    }

    @IBAction func copyAction(_ sender: Any) {
//        UIPasteboard.general.string = makeStringWithAddress()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func makePrivateKey() -> String {
        var binaryData = account!.binaryDataString.createBinaryData()!
        let privateKeyString = DataManager.shared.privateKeyString(blockchain: BlockchainType.create(wallet: wallet!),
                                                                   walletID: wallet?.walletID as! UInt32,
                                                                   addressID: UInt32(addressID!),
                                                                   binaryData: &binaryData)
        return privateKeyString
    }
    
}
