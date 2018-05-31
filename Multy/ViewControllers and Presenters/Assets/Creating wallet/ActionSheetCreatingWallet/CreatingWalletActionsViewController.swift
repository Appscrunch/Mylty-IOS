//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class CreatingWalletActionsViewController: UIViewController, CancelProtocol, AnalyticsProtocol {

    weak var cancelDelegate: CancelProtocol?
    weak var createProtocol: CreateWalletProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        self.setPresentedVcToDelegate()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        self.cancelDelegate?.presentNoInternet()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.cancelDelegate?.presentNoInternet()
    }
    
    @IBAction func createAction(_ sender: Any) {
        ((cancelDelegate! as! AssetsViewController).tabBarController! as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
        self.dismiss(animated: true) {
            self.createProtocol?.goToCreateWallet()
        }       
    }
    
    @IBAction func importWalletAction(_ sender: Any) {
        unowned let weakSelf =  self
        self.presentDonationAlertVC(from: weakSelf, with: "io.multy.importWallet50")
        logAnalytics()
    }
    
    func logAnalytics() {
        sendDonationAlertScreenPresentedAnalytics(code: donationForImportWallet)
    }
    
    func cancelAction() {
        self.dismiss(animated: true) {
            self.cancelDelegate?.cancelAction()
        }
    }
    
    func donate50(idOfProduct: String) {
        self.dismiss(animated: true) {
            self.cancelDelegate?.donate50!(idOfProduct: idOfProduct)
        }
    }
    
    func presentNoInternet() {
        
    }
}

