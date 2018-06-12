//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = TermsOfServiceViewController

class TermsOfServiceViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    @IBOutlet weak var agreeTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        self.loadPage()
        self.webView.delegate = self
        self.spiner.hidesWhenStopped = true
        agreeTextLabel.text = localize(string: Constants.agreeWithTermsString)
    }
    
    func loadPage() {
        let url = LocalLanguage.shared.getTOSLink()
        self.webView.scalesPageToFit = true
        self.webView.contentMode = .scaleAspectFit
        self.webView.loadRequest(URLRequest(url: url))
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        spiner.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spiner.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    
    @IBAction func acceptAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.registerPush()
        
        UserDefaults.standard.set(false, forKey: "isTermsAccept")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        let url = LocalLanguage.shared.getPPLink()
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let webTextVC = storyboard.instantiateViewController(withIdentifier: "webText") as! WebTextPageViewController
//        webTextVC.tagForLoad = 0
//        self.present(webTextVC, animated: true, completion: nil)
    }
    
    @IBAction func discardAction(_ sender: Any) {
        let message = localize(string: Constants.useTermsOfService)
        let alert = UIAlertController(title: localize(string: Constants.sorryString), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localize(string: Constants.cancelString), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
    }
}
