//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = WrongSeedPhraseViewController

class WrongSeedPhraseViewController: UIViewController, AnalyticsProtocol {
    
    let presenter = WrongSeedPhrasePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.mainVC = self
        sendAnalyticsEvent(screenName: screenFailRestore, eventName: screenFailRestore)
        sendAnalyticsEvent(screenName: screenFailRestore, eventName: seedBackupFailed)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAction(_ sender : UIButton) {
        let allVCs = self.navigationController!.viewControllers
        
        let alert = UIAlertController(title: localize(string: Constants.cancelString), message: "Are you really want to cancel?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if allVCs.count > 5 {
                let destinationVC = allVCs[allVCs.count - 6]
                self.navigationController?.popToViewController(destinationVC, animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
            self.sendAnalyticsEvent(screenName: screenFailRestore, eventName: cancelTap)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func tryAgainAction(_ sender : UIButton) {
        let allVCs = self.navigationController!.viewControllers
        if allVCs.count == 3 {
            self.presenter.prevVC?.isNeedToClean = true
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if allVCs.count > 2 {
            let destinationVC = allVCs[allVCs.count - 3]
            self.navigationController?.popToViewController(destinationVC, animated: true)
        }
        sendAnalyticsEvent(screenName: screenFailRestore, eventName: tryAgainTap)
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Seed"
    }
}
