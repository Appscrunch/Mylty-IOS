//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = ResetAllDataViewController

class ResetAllDataViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    weak var cancelDelegate: CancelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.presentedVC = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        ipadFix()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cancelBtn.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15)
    }
    
    func ipadFix() {
        if screenHeight == heightOfiPad {
            self.heightConstraint.constant = 440
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        sendAnalyticsEvent(screenName: screenSecuritySettings, eventName: resetDeclined)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetAction(_ sender: Any) {
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: {
                self.cancelDelegate?.cancelAction()
            })
            self.sendAnalyticsEvent(screenName: screenSecuritySettings, eventName: resetComplete)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Settings"
    }
}
