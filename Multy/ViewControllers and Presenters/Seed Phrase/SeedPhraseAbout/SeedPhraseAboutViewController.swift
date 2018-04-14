//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

class SeedPhraseAboutViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet weak var continueBtn: ZFRippleButton!
    
    @IBOutlet weak var camIcon: UIImageView!
    @IBOutlet weak var snapIcon: UIImageView!
    @IBOutlet weak var spyIcon: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstConstraint: NSLayoutConstraint!   //
    @IBOutlet weak var secondConstraint: NSLayoutConstraint!  // for fix ipad
    @IBOutlet weak var thirdConstraint: NSLayoutConstraint!   //
    
    var whereFrom: UIViewController?
    var isNeedToBackup: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        self.fixiPadUI()
        self.setupUI()
        sendAnalyticsEvent(screenName: screenViewPhrase, eventName: screenViewPhrase)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.continueBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                    UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                       gradientOrientation: .horizontal)
    }
    
    func setupUI() {
        let shadowColor = UIColor(red: 166/255, green: 177/255, blue: 198/255, alpha: 0.26)
        self.camIcon.setShadow(with: shadowColor)
        self.snapIcon.setShadow(with: shadowColor)
        self.spyIcon.setShadow(with: shadowColor)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        self.performSegue(withIdentifier: "seedWordsVC", sender: UIButton.self)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        sendAnalyticsEvent(screenName: screenViewPhrase, eventName: cancelTap)
        self.navigationController?.popViewController(animated: true)
    }
    
    func fixiPadUI() {
        if screenHeight == heightOfiPad {
            self.topConstraint.constant = 15
            self.firstConstraint.constant = 25
            self.secondConstraint.constant = 25
            self.thirdConstraint.constant = 25
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seedWordsVC" {
            let destVC = segue.destination as! SeedPhraseWordViewController
            if self.whereFrom != nil {
                destVC.whereFrom = self.whereFrom
                if self.isNeedToBackup != nil {
                    destVC.isNeedToBackup = self.isNeedToBackup!
                }
            }
        }
    }
    
}
