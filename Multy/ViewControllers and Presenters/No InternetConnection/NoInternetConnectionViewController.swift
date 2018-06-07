//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = NoInternetConnectionViewController

class NoInternetConnectionViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet var backView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendAnalyticsEvent(screenName: screenNoInternet, eventName: screenNoInternet)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backView.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                  UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                    gradientOrientation: .topRightBottomLeft)
        
        self.tryAgainBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                     UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                       gradientOrientation: .horizontal)
    }
    
    @IBAction func tryAgainAction(_ sender: Any) {
        sendAnalyticsEvent(screenName: screenNoInternet, eventName: checkTap)
        if ConnectionCheck.isConnectedToNetwork() {
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: localize(string: Constants.noInternetString), message: localize(string: Constants.connectDeviceString), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
    }
}
