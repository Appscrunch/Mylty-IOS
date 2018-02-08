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

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
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
}
