//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class WebTextPageViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    
    var tagForLoad: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        self.loadPage(tag: tagForLoad)
        self.webView.delegate = self
        self.spiner.hidesWhenStopped = true
    }
    
    func loadPage(tag: Int?) {
        var url = URL(string: "http://multy.io")!
        switch tag {
        case 0:
            url = LocalLanguage.shared.getPPLink()
        case 1:
            url = LocalLanguage.shared.getTOSLink()
        default: break
        }
        self.webView.scalesPageToFit = true
        self.webView.contentMode = .scaleAspectFit
        self.webView.loadRequest(URLRequest(url: url))
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        spiner.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spiner.stopAnimating()
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
