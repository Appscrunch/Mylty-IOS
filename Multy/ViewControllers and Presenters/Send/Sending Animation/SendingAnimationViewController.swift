//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

class SendingAnimationViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet var backView: UIView!
    @IBOutlet weak var sendingImage: UIImageView!
    @IBOutlet weak var sendingLbl: UILabel!
    @IBOutlet weak var closeBtn: ZFRippleButton!
    
    let when = DispatchTime.now() + 0.1 // change 2 to desired number of seconds

    var chainId: Int?
    
    var indexForTabBar: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.sendOK()
        }
        if chainId == nil {
            return
        }
        sendAnalyticsEvent(screenName: "\(screenSendSuccessWithChain)\(chainId!)", eventName: "\(screenSendSuccessWithChain)\(chainId!)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backView.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                  UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                    gradientOrientation: .topRightBottomLeft)
        
        self.closeBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                  UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                    gradientOrientation: .horizontal)
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        if indexForTabBar == nil {
            self.tabBarController?.selectedIndex = 0
        } else {
            if let tbc = self.tabBarController as? CustomTabBarViewController {
                tbc.setSelectIndex(from: indexForTabBar!, to: indexForTabBar!)
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func sendOK() {
        self.sendingImage.image = #imageLiteral(resourceName: "completeIcon")
        self.sendingLbl.text = "Succsess!"
        self.closeBtn.isHidden = false
    }
}
