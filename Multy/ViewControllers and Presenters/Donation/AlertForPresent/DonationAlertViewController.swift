//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class DonationAlertViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    weak var cancelDelegate: CancelProtocol?
    
    var idOfProduct: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPresentedVcToDelegate()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        view.setShadow(with: UIColor.gray)
        ipadFix()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cancelBtn.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15)
    }
    
    func ipadFix() {
        if screenHeight == heightOfiPad {
            heightConstraint.constant = 400
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        self.cancelDelegate?.presentNoInternet()
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.cancelDelegate?.presentNoInternet()
        
        sendDonationAlertScreenCancelledAnalytics()
    }
    
    @IBAction func donateAction5(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.cancelDelegate?.cancelAction()
//        self.cancelDelegate?.presentNoInternet()
        sendDonationAlertScreenPressDonateAnalytics()
    }
    
    @IBAction func donate50(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.cancelDelegate?.donate50!(idOfProduct: idOfProduct!)
    }
}
