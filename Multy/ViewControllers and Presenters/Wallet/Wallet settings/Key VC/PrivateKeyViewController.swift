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
        UIPasteboard.general.string = makePrivateKey()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let objectsToShare = [makePrivateKey()]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        activityVC.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            } else {
//                if let appName = activityType?.rawValue {
//                    self.sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(self.wallet!.chain)", eventName: "\(shareToAppWithChainTap)\(self.wallet!.chain)_\(appName)")
//                }
            }
        }
        activityVC.setPresentedShareDialogToDelegate()
        self.present(activityVC, animated: true, completion: nil)
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
