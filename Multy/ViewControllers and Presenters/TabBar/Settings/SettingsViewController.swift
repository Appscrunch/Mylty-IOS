//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = SettingsViewController

class SettingsViewController: UIViewController, AnalyticsProtocol, CancelProtocol {

    @IBOutlet weak var pinSwitch: UISwitch!
     
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var topVersionLbl: UILabel!
    @IBOutlet weak var botVersionLbl: UILabel!
    
    @IBOutlet weak var pushView: UIView!
    @IBOutlet weak var securityView: UIView!
    @IBOutlet weak var defFiatView: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    //@IBOutlet weak var copyBtnWidthConstraint: NSLayoutConstraint!
    
    let presenter = SettingsPresenter()
//    let authVC = SecureViewController()
    
    var pinStr: String?
    
    let opacityForNotImplementedView: CGFloat = 0.5  // not implemented features
    
    let infoDictionary = Bundle.main.infoDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeVersion()
        self.presenter.settingsVC = self
        setupForNotImplementedViews()
        
        sendAnalyticsEvent(screenName: screenSettings, eventName: screenSettings)
        presenter.tabBarFrame = tabBarController?.tabBar.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.frame = presenter.tabBarFrame!
//        tabBarController?.tabBar.frame = CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49)
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.getPassFromUserDef()
        ipadFix()
//        UserPreferences.shared.getAndDecryptCipheredMode(completion: { (pinMode, error) in
//            self.pinSwitch.isOn = (pinMode! as NSString).boolValue
//        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideCopy()
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func pushAction(_ sender: Any) {
        if self.pushSwitch.isOn {
            sendAnalyticsEvent(screenName: screenSettings, eventName: pushesEnabled)
        } else {
            sendAnalyticsEvent(screenName: screenSettings, eventName: pushesDisabled)
        }
    }
    
    func setupForNotImplementedViews() {
        self.pushView.alpha = opacityForNotImplementedView
//        self.defFiatView.alpha = opacityForNotImplementedView
        self.aboutView.alpha = opacityForNotImplementedView
        self.feedbackView.alpha = opacityForNotImplementedView
    }
    
    func ipadFix() {
        if screenHeight == heightOfiPad {
            self.topConstraint.constant = -40
            self.scrollView.scrollToTop()
            self.bottomConstraint.constant = 0
        }
    }
    
//    @IBAction func onSwitch(_ sender: Any) {
//        if !pinSwitch.isOn {
//                NotificationCenter.default.addObserver(self, selector: #selector(self.disablePin), name: Notification.Name("canDisablePin"), object: nil)
//                pinSwitch.isOn = true
//                authVC.modalPresentationStyle = .overCurrentContext
//                self.present(authVC, animated: true, completion: nil)
//        } else {
//            if self.presenter.canEvaluatePolicy() {
//                UserPreferences.shared.writeCipheredPinMode(mode: 1)
//            } else {
//                pinSwitch.isOn = false
//                let message = "Biometric authentication is not configured on your device"
//                let alert = UIAlertController(title: localize(string: Constants.sorryString), message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: localize(string: Constants.cancelString), style: .cancel, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
    
    @IBAction func showOrHideCopy(_ sender: UIButton, event: UIEvent) {
        if self.copyBtn.alpha == 0.0 {
            let event = event.touches(for: sender)?.first
            let location = event?.location(in: sender)
            showCopy(center: location!)
        } else {
            hideCopy()
        }
    }
    
    func showCopy(center: CGPoint) {
        copyBtn.center = center
        copyBtn.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5) {
            self.copyBtn.alpha = 1.0
        }
    }
    
    func hideCopy() {
        self.copyBtn.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.copyBtn.alpha = 0
        }
    }
    
    @IBAction func copyAction(_ sender: Any) {
        hideCopy()
        UIPasteboard.general.string = "\(self.topVersionLbl.text!)\n\(self.botVersionLbl.text!)"
    }
    
    @IBAction func goToSecuritySettingsAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        if self.pinStr == nil {
            let secureSettingsVC = storyboard.instantiateViewController(withIdentifier: "securitySettings") as! SecuritySettingsViewController
            secureSettingsVC.resetDelegate = self
            self.navigationController?.pushViewController(secureSettingsVC, animated: true)
        } else {
            (self.tabBarController as! CustomTabBarViewController).menuButton.isHidden = true
            (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
            let pinVC = storyboard.instantiateViewController(withIdentifier: "pinVC") as! EnterPinViewController
            pinVC.cancelDelegate = self
            pinVC.whereFrom = self
            pinVC.modalPresentationStyle = .overCurrentContext
            self.present(pinVC, animated: true, completion: nil)
        }
        sendAnalyticsEvent(screenName: screenSettings, eventName: securitySettingsTap)
    }
    
    @IBAction func currencyAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let currencyVC = storyboard.instantiateViewController(withIdentifier: "currencyVC")
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
    @objc func disablePin() {
        self.pinSwitch.isOn = false
        NotificationCenter.default.removeObserver(self)
        UserPreferences.shared.writeCipheredPinMode(mode: 0)
    }
    
    @IBAction func goToExchangeAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let exchangeVC = storyboard.instantiateViewController(withIdentifier: "exchangeVC")
        self.navigationController?.pushViewController(exchangeVC, animated: true)
    }
    
    func cancelAction() {
        RealmManager.shared.clearRealm { (ok, err) in
            DataManager.shared.finishRealmSession()
            UserDefaults.standard.removeObject(forKey: "databasePassword")
            DataManager.shared.clearDB { (err) in
                let assetVC = self.tabBarController?.childViewControllers[0].childViewControllers[0] as! AssetsViewController
                UserDefaults.standard.removeObject(forKey: "isFirstLaunch")
                UserDefaults.standard.removeObject(forKey: "pin")
                UserDefaults.standard.removeObject(forKey: "isTermsAccept")
                assetVC.isFirstLaunch = true
                assetVC.presenter.account = nil
                exit(0)
//                assetVC.viewDidLoad()
//                (self.tabBarController as! CustomTabBarViewController).setSelectIndex(from: 4, to: 0)
            }
        }
    }
    
    func presentNoInternet() {
        self.goToSecureSettings()
    }
    
    func getPassFromUserDef() {
        UserPreferences.shared.getAndDecryptPin { (pin, err) in
                self.pinStr = pin
        }
    }
    
    func goToSecureSettings() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let secureSettingsVC = storyboard.instantiateViewController(withIdentifier: "securitySettings") as! SecuritySettingsViewController
        secureSettingsVC.resetDelegate = self
        self.navigationController?.pushViewController(secureSettingsVC, animated: true)
    }
    
    @IBAction func privacyAndTermsAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webTextPage = storyboard.instantiateViewController(withIdentifier: "webText") as! WebTextPageViewController
        webTextPage.tagForLoad = sender.tag
        self.navigationController?.pushViewController(webTextPage, animated: true)
    }
    
    
    func appVersion() -> String {
        return infoDictionary["CFBundleShortVersionString"] as! String
    }
    
    func buildVersion() -> String {
        return infoDictionary["CFBundleVersion"] as! String
    }
    
    func getGitTag() -> String {
        return infoDictionary["GIT_TAG_NAME"] as! String
    }
    
    func getGitBranch() -> String {
        return infoDictionary["GIT_BRANCH_NAME"] as! String
    }
    
    func getGitCommitHash() -> String {
        return infoDictionary["GIT_COMMIT_HASH"] as! String
    }
    
    func getCoreLibVersion() -> String {
        return CoreLibManager.shared.getCoreLibVersion()
    }
    
    func makeVersion() {
        self.topVersionLbl.text = "Multy Ctypto Wallet v.\(appVersion()).\(buildVersion())"
        self.botVersionLbl.text = "Git tag: \(getGitTag())\nGit branch name: \(getGitBranch())\nGit commit hash: \(getGitCommitHash())\n\nCore version: \(getCoreLibVersion())\n\nEnvironment: \(apiUrl)"
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Setting"
    }
}
