//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
//    method_exchangeImplementations(originalMethod!, swizzledMethod!)
    let flag = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    if flag {
        class_replaceMethod(UIViewController.self,
                            swizzledSelector,
                            method_getImplementation(swizzledMethod!),
                            method_getTypeEncoding(swizzledMethod!))
    } else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func isOperationSystemAtLeast11() -> Bool {
        return ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 11, minorVersion: 0, patchVersion: 0))
    }

    static let classInit: Void = {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(proj_viewWillAppear(animated:))
        swizzling(UIViewController.self, originalSelector, swizzledSelector)
    }()
    
    @objc func proj_viewWillAppear(animated: Bool) {
        proj_viewWillAppear(animated: animated)
        if !(ConnectionCheck.isConnectedToNetwork()) {
            if self.isKind(of: NoInternetConnectionViewController.self) || self.isKind(of: UIAlertController.self) {
                return
            }
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NoConnectionVC") as! NoInternetConnectionViewController
            
            //case where exists textfields
            let tmvc = UIApplication.topViewController()
            
            if tmvc != nil && (tmvc!.className.hasPrefix("SendDetails") ||
                tmvc!.className.hasPrefix("CustomFee") ||
                tmvc!.className.hasPrefix("SendAmount") ||
                tmvc!.className.hasPrefix("BackupSeedPhraseViewController") ||
                tmvc!.className.hasPrefix("CheckWords")) {
                
            } else if tmvc != nil && tmvc!.shouldRemoveKeyboard() {
                tmvc!.dismissKeyboard()
                
                tmvc!.present(nextViewController, animated: true, completion: nil)
            } else {
                self.present(nextViewController, animated: true, completion: nil)
            }
        }
        //        print("swizzled_layoutSubviews")
    }
    
    func isVisible() -> Bool {
        return self.isViewLoaded && view.window != nil
    }
    
    func shouldRemoveKeyboard() -> Bool {
        if self.className.hasPrefix("SendStart") ||
            self.className.hasPrefix("WalletSettings") ||
            self.className.hasPrefix("CreateWallet") ||
            self.className.hasPrefix("ReceiveAmount") {
                return true
        }
        
        return false
    }
    
    func presentAlert(with message: String?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentDonationVCorAlert() {
        DataManager.shared.realmManager.fetchBTCWallets(isTestNet: false) { (wallets) in
            if wallets == nil || wallets?.count == 0 {
                let message = "You don`t have any Bitcoin wallets yet."
                self.donateOrAlert(isHaveNotEmptyWallet: false, message: message)
                
                return
            }
            
            for wallet in wallets! {
                if wallet.availableAmount() > 0 {
                    let message = "You have nothing to donate.\nRecharge your balance for any of your BTC wallets."  // no money no honey
                    self.donateOrAlert(isHaveNotEmptyWallet: true, message: message)
                    break
                } else { // empty wallet
                    let message = "You have nothing to donate.\nRecharge your balance for any of your BTC wallets."  // no money no honey
                    self.donateOrAlert(isHaveNotEmptyWallet: false, message: message)
                    break
                }
            }
        }
    }
    
    func donateOrAlert(isHaveNotEmptyWallet: Bool, message: String) {
        if isHaveNotEmptyWallet {
            (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let donatSendVC = storyboard.instantiateViewController(withIdentifier: "donatSendVC") as! DonationSendViewController
            donatSendVC.selectedTabIndex = self.tabBarController?.selectedIndex
            self.navigationController?.pushViewController(donatSendVC, animated: true)
        } else {
            self.viewWillAppear(false)
            let alert = UIAlertController(title: "Sorry", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setPresentedVcToDelegate() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.presentedVC = self
    }
    
    func swipeToBack() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func isVCVisible() -> Bool {
        return isViewLoaded && view.window != nil
    }
}
