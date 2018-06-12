//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = ActivityViewController

class ActivityViewController: UIViewController, CancelProtocol, AnalyticsProtocol {
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var donatView: UIView!
    
    var presenter = ActivityPresenter()
    
    var message = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.mainVC = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        sendAnalyticsEvent(screenName: screenActivity, eventName: screenActivity)
        
        newsView.layer.shadowColor = #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.3)
        newsView.layer.shadowOpacity = 1
        newsView.layer.shadowOffset = .zero
        newsView.layer.shadowRadius = 20
        
        presenter.tabBarFrame = tabBarController?.tabBar.frame
        
        ipadFix()
        presenter.tabBarFrame = tabBarController?.tabBar.frame
        setupView()
    }
    
    func setupView() {
        self.donatView.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9994150996, alpha: 1)
        self.donatView.layer.borderWidth = 1
    }
    
    func ipadFix() {
        if screenHeight == heightOfiPad {
            donatView.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
        tabBarController?.tabBar.frame = presenter.tabBarFrame!
//        tabBarController?.tabBar.frame = CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func goToAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webView = storyboard.instantiateViewController(withIdentifier: "ActivityWebViewVC")
        self.navigationController?.pushViewController(webView, animated: true)
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
    }
    
    @IBAction func donatAction(_ sender: Any) {
        unowned let weakSelf =  self
        self.presentDonationAlertVC(from: weakSelf, with: "io.multy.addingActivity50")
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        logAnalytics()
    }
    
    func logAnalytics() {
        sendDonationAlertScreenPresentedAnalytics(code: donationForActivitySC)
    }
    
    func cancelAction() {
//        presentDonationVCorAlert()
        self.makePurchaseFor(productId: "io.multy.addingActivity5")
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
    }
    
    func donate50(idOfProduct: String) {
        self.makePurchaseFor(productId: idOfProduct)
    }
    
    func presentNoInternet() {
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Activity"
    }
}
