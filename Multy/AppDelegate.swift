//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift
import Firebase
import FirebaseMessaging
import Branch
import UserNotifications
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var presentedVC: UIViewController?
    var openedAlert: UIAlertController?
    var sharedDialog: UIActivityViewController?
    var selectedIndexOfTabBar = 0
    var isActiveFirstTime: Bool?
    var enterPinVc: EnterPinViewController?
    var application: UIApplication?
    
    override init() {
        super.init()
        UIViewController.classInit
    }

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.application = application
        // check for screenshot
        NotificationCenter.default.addObserver(
            forName: .UIApplicationUserDidTakeScreenshot,
            object: nil,
            queue: .main) { notification in
                print("\n\nScreennshot!\n\n")
                //executes after screenshot
        }
        
        self.storeKit()
        DataManager.shared.realmManager.getAccount { (acc, err) in
            DataManager.shared.realmManager.fetchCurrencyExchange { (currencyExchange) in
                if currencyExchange != nil {
                    DataManager.shared.currencyExchange.update(currencyExchangeRLM: currencyExchange!)
                }
            }
            isNeedToAutorise = acc != nil
            DataManager.shared.apiManager.userID = acc == nil ? "" : acc!.userID
            //MAKR: Check here isPin option from NSUserDefaults
            UserPreferences.shared.getAndDecryptPin(completion: { (code, err) in
                if code != nil && code != "" {
                    isNeedToAutorise = true
                    let appDel = UIApplication.shared.delegate as! AppDelegate
                    appDel.authorization(isNeedToPresentBiometric: true)
                }
            })
        }
//        exchangeCourse = UserDefaults.standard.double(forKey: "exchangeCourse")
        
        //FOR TEST NOT MAIN STRORYBOARD
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Send", bundle: nil)
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "sendAmount")
//        self.window?.rootViewController = initialViewController
//        self.window?.makeKeyAndVisible()
        
        // for debug and development only
        Branch.getInstance().setDebug()
        Branch.getInstance().initSession(launchOptions: launchOptions) { [weak self] (params, error) in
            if error == nil {
                let dictFormLink = params! as NSDictionary
                if (dictFormLink["address"] != nil) {
                    DataManager.shared.getAccount(completion: { (acc, err) in
                        if acc == nil {
                            return
                        }
                        
                        //FIXME: amountFromLink pass as String
                        var amountFromLink: String?
                        let deepLinkAddressInfoArray = (dictFormLink["address"] as! String).split(separator: ":")
                        
                        let chainNameFromLink = deepLinkAddressInfoArray.first
                        let addressFromLink = deepLinkAddressInfoArray.last
                        if let amount = dictFormLink["amount"] as? String {
                            amountFromLink = amount
                        } else if let number = dictFormLink["amount"] as? NSNumber {
                            amountFromLink = "\(number)"
                        } else {
                            print("\n\n\nAmount from deepLink not parsed!\n\n\n")
                        }
                        
                        let storyboard = UIStoryboard(name: "Send", bundle: nil)
                        let sendStartVC = storyboard.instantiateViewController(withIdentifier: "sendStart") as! SendStartViewController
                        sendStartVC.presenter.transactionDTO.sendAddress = "\(addressFromLink ?? "")"
                        sendStartVC.presenter.transactionDTO.sendAmountString = amountFromLink
                        switch chainNameFromLink {
                        case "ethereum":
                            sendStartVC.presenter.transactionDTO.blockchainType?.blockchain = BLOCKCHAIN_ETHEREUM
                        default: break   //by default create tr for bitcoin
                        }
                        ((self!.window?.rootViewController as! CustomTabBarViewController).selectedViewController as! UINavigationController).pushViewController(sendStartVC, animated: false)
                        sendStartVC.performSegue(withIdentifier: "chooseWalletVC", sender: (Any).self)
                    })
                }
            }
        }
        
        if UserDefaults.standard.value(forKey: "isTermsAccept") != nil {
            self.registerPush()
        }
        let filePathOpt = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        if let filePath = filePathOpt, let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        }
        
        return true
    }

    
    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // handler for URI Schemes (depreciated in iOS 9.2+, but still used by some apps)
        Branch.getInstance().application(app, open: url, options: options)
        
        DataManager.shared.getAccount(completion: { (acc, err) in
            if acc == nil {
                return
            }
            var addressStr = ""
            var amountFromQr: String?
            let array = url.absoluteString.components(separatedBy: CharacterSet(charactersIn: ":?="))
            switch array.count {
            case 1:                              // shit in qr
                let messageFromQr = array[0]
                print(messageFromQr)
            case 2:                              // chain name + address
                addressStr = array[1]
            case 4:                                // chain name + address + amount
                addressStr = array[1]
                amountFromQr = array[3]
            default: break
            }
            
            let storyboard = UIStoryboard(name: "Send", bundle: nil)
            let sendStartVC = storyboard.instantiateViewController(withIdentifier: "sendStart") as! SendStartViewController
            sendStartVC.presenter.transactionDTO.sendAddress = "\(addressStr)"
            sendStartVC.presenter.transactionDTO.sendAmountString = amountFromQr
            ((self.window?.rootViewController as! CustomTabBarViewController).selectedViewController as! UINavigationController).pushViewController(sendStartVC, animated: false)
            sendStartVC.performSegue(withIdentifier: "chooseWalletVC", sender: (Any).self)
        })
        
        
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        DataManager.shared.finishRealmSession()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        window?.endEditing(true)
        NotificationCenter.default.post(name: Notification.Name("hideKeyboard"), object: nil)
        DataManager.shared.finishRealmSession()
        DataManager.shared.realmManager.getAccount { (acc, err) in
            isNeedToAutorise = acc != nil
            self.closePresented()
            //MARK: Check here isPin option from NSUserDefaults
            UserPreferences.shared.getAndDecryptPin(completion: { (code, err) in
                if code != nil && code != "" {
                    isNeedToAutorise = true
                    self.authorization(isNeedToPresentBiometric: false)
                }
            })
        }
        
        DataManager.shared.realmManager.updateCurrencyExchangeRLM(curExchange: DataManager.shared.currencyExchange)
//        UserDefaults.standard.set(exchangeCourse, forKey: "exchangeCourse")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is ter4minated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.closePresented()
        isActiveFirstTime = true
//        exchangeCourse = UserDefaults.standard.double(forKey: "exchangeCourse")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        self.authorization()
        if isActiveFirstTime == nil || isActiveFirstTime == true {
            if let vcOnScren = (window?.rootViewController?.childViewControllers[selectedIndexOfTabBar] as! UINavigationController).topViewController {
                if let presentedPinVC = vcOnScren.presentedViewController {
                    let pinVc = presentedPinVC as? EnterPinViewController
                    pinVc?.isNeedToPresentBiometric = true
                    pinVc?.viewWillAppear(true)
                }
                if let seedVC = vcOnScren as? CheckWordsViewController {
                    seedVC.wordTF.becomeFirstResponder()
                } else if let seedVC = vcOnScren as? PinCodeViewController {
                    seedVC.pinTF.becomeFirstResponder()
                } else if let receiveVC = vcOnScren as? ReceiveAmountViewController {
                    receiveVC.amountTF.becomeFirstResponder()
                } else if let amountVC = vcOnScren as? SendAmountViewController {
                    amountVC.amountTF.becomeFirstResponder()
                } else if let amountVC = vcOnScren as? SendAmountEthViewController {
                    amountVC.amountTF.becomeFirstResponder()
                }
            }
            isActiveFirstTime = false
        }
//        exchangeCourse = UserDefaults.standard.double(forKey: "exchangeCourse")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DataManager.shared.realmManager.updateCurrencyExchangeRLM(curExchange: DataManager.shared.currencyExchange)
//        UserDefaults.standard.set(exchangeCourse, forKey: "exchangeCourse")
        DataManager.shared.finishRealmSession()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func saveMkVersion(){
        if UserDefaults.standard.value(forKey: "MKVersion") != nil {
            
        } else {
            UserDefaults.standard.set("1.0", forKey: "MKVersion")
        }
    }
    
    func authorization(isNeedToPresentBiometric: Bool) {
        if isNeedToAutorise {
//            self.window?.isUserInteractionEnabled = false
//            let authVC = SecureViewController()
//            authVC.modalPresentationStyle = .overCurrentContext
            let selectedIndex = (self.window?.rootViewController as! CustomTabBarViewController).selectedIndex
            let vcOnScreen = (self.window?.rootViewController?.childViewControllers[selectedIndex] as! UINavigationController).topViewController
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let pinVC = storyboard.instantiateViewController(withIdentifier: "pinVC") as! EnterPinViewController
//            pinVC.cancelDelegate = self
            pinVC.whereFrom = vcOnScreen
            pinVC.isNeedToPresentBiometric = isNeedToPresentBiometric
            pinVC.hideCancel()
            pinVC.modalPresentationStyle = .overCurrentContext
            
            vcOnScreen?.present(pinVC, animated: true, completion: nil)
            isNeedToAutorise = false
            selectedIndexOfTabBar = selectedIndex
        }
    }
    
    func closePresented() {
        if self.presentedVC != nil {
            self.presentedVC?.dismiss(animated: true, completion: nil)
        }
        
        if self.enterPinVc != nil {
            self.enterPinVc?.hideCancel()
        }
        
        if self.openedAlert != nil {
            self.openedAlert?.dismiss(animated: true, completion: nil)
        }
        if self.sharedDialog != nil {
            self.sharedDialog?.dismiss(animated: true, completion: nil)
        }
    }
    
    func storeKit() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }

//    func realmConfig () {
//        let config = Realm.Configuration(
//            // Set the new schema version. This must be greater than the previously used
//            // version (if you've never set a schema version before, the version is 0).
//            schemaVersion: 1,
//
//            // Set the block which will be called automatically when opening a Realm with
//            // a schema version lower than the one set above
//            migrationBlock: { migration, oldSchemaVersion in
//
//                if oldSchemaVersion < 1 {
//                    //                    MARK: here is simple example
//
//                    //                    migration.enumerate(WorkoutSet.className()) { oldObject, newObject in
//                    //                        newObject?["setCount"] = setCount
//                    //                    }
//                }
//            }
//        )
//        Realm.Configuration.defaultConfiguration = config
//    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print(notification.description)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        let token = Messaging.messaging().fcmToken
        print("FCM token: \(fcmToken)")
        ApiManager.shared.pushToken = fcmToken
        DataManager.shared.getAccount { (acc, err) in
            Messaging.messaging().subscribe(toTopic: "btcTransactionUpdate-\(acc?.userID ?? "userId is empty")")  //userID
        }
    }
    
    func registerPush() {
        if #available(iOS 10.0, *) {
//             For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
//             For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
            Messaging.messaging().isAutoInitEnabled = true
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            self.application!.registerUserNotificationSettings(settings)
        }
        self.application!.registerForRemoteNotifications()
        if Messaging.messaging().fcmToken != nil {
            ApiManager.shared.pushToken = Messaging.messaging().fcmToken as! String
        }
    }
}

