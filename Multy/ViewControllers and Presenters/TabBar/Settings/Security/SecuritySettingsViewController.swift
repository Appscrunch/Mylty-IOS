//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = SecuritySettingsViewController

class SecuritySettingsViewController: UIViewController, AnalyticsProtocol, CancelProtocol {
    
    @IBOutlet weak var seedLbl: UILabel!  // if backup not complete - text = "Backup Seed" - else - text = "View Seed Phrase"
    @IBOutlet weak var entranceView: UIView!
    @IBOutlet weak var entranceTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noneLbl: UILabel!
    @IBOutlet weak var warningImg: UIImageView!
    
    var isNeedToBackup: Bool?
    
    weak var resetDelegate: CancelProtocol?
    
    let opacityForNotImplementedView: CGFloat = 0.5  // not implemented features
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        sendAnalyticsEvent(screenName: screenSecuritySettings, eventName: screenSecuritySettings)
//        self.entranceView.alpha = opacityForNotImplementedView
//        self.entranceView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.detectingSeed()
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        sendAnalyticsEvent(screenName: screenSecuritySettings, eventName: closeTap)
    }
    
    @IBAction func resetAllDataAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Settings", bundle: nil)
        let resetVC = storyBoard.instantiateViewController(withIdentifier: "resetAllDataVC") as! ResetAllDataViewController
        resetVC.modalPresentationStyle = .overCurrentContext
        resetVC.modalTransitionStyle = .crossDissolve
        resetVC.cancelDelegate = self
        self.present(resetVC, animated: true, completion: nil)
        sendAnalyticsEvent(screenName: screenSecuritySettings, eventName: resetTap)
    }
    
    @IBAction func goToEntranceSettingsAction(_ sender: Any) {
//        self.overlayBlurredBackgroundView()
        self.performSegue(withIdentifier: "entranceSettingsVC", sender: sender)
        sendAnalyticsEvent(screenName: screenSecuritySettings, eventName: blockSettingsTap)
    }
    
    @IBAction func restoreSeedAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SeedPhrase", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "seedAbout") as! SeedPhraseAboutViewController
        destVC.whereFrom = self
        if self.isNeedToBackup == true {
            destVC.isNeedToBackup = self.isNeedToBackup
        }
        self.navigationController?.pushViewController(destVC, animated: true)
        sendAnalyticsEvent(screenName: screenSecuritySettings, eventName: viewSeedTap)
    }
    
    func detectingSeed() {
        DataManager.shared.getAccount { (acc, erro) in
            if acc?.seedPhrase != nil && acc?.seedPhrase != "" {
                self.isNeedToBackup = true
            } else {
                self.isNeedToBackup = false
            }
            self.setupUi()
        }
    }
    
    func setupUi() {
        UserPreferences.shared.getAndDecryptPin { [unowned self] (pin, err) in
            if pin == nil {
                self.entranceTopConstraint.constant = 12
                self.noneLbl.isHidden = false
                self.warningImg.isHidden = false
            } else {
                self.entranceTopConstraint.constant = 20
                self.noneLbl.isHidden = true
                self.warningImg.isHidden = true
            }
            if self.isNeedToBackup! {
                self.seedLbl.text = self.localize(string: Constants.backupSeedPhraseNeededString)
            } else {
                self.seedLbl.text = self.localize(string: Constants.viewSeedPhraseString)
            }
        }
    }
    
    func cancelAction() {
        self.navigationController?.popToRootViewController(animated: true)
        self.resetDelegate?.cancelAction()
//        RealmManager.shared.clearRealm { (ok, err) in
//            if err == nil {
//
////                DispatchQueue.main.async {
////                    self.navigationController?.popToRootViewController(animated: false)
////                    self.tabBarController?.selectedIndex = 0
////                }
//            }
//        }
    }
    
    func presentNoInternet() {
        removeBlurredBackgroundView()
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .extraLight)
        view.addSubview(blurredBackgroundView)
        
        //        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        //        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.frame = view.bounds
        //        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        view.addSubview(blurEffectView)
    }
    
    func removeBlurredBackgroundView() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinVC" {
            let destVC = segue.destination as! EnterPinViewController
            destVC.cancelDelegate = self
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Setting"
    }
}
