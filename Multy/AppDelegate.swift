//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift
import Firebase
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var presentedVC: UIViewController?
    var openedAlert: UIAlertController?
    
    override init() {
        super.init()
        UIViewController.classInit
    }

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        // check for screenshot
        NotificationCenter.default.addObserver(
            forName: .UIApplicationUserDidTakeScreenshot,
            object: nil,
            queue: .main) { notification in
                print("\n\nScreennshot!\n\n")
                //executes after screenshot
        }

        self.performFirstEnterFlow()

        DataManager.shared.realmManager.getAccount { (acc, err) in
            isNeedToAutorise = acc != nil

            //MAKR: Check here isPin option from NSUserDefaults
            UserPreferences.shared.getAndDecryptCipheredMode(completion: { (pinMode, error) in
                isNeedToAutorise = (pinMode! as NSString).boolValue
                self.authorization()
            })
        }
        
        exchangeCourse = UserDefaults.standard.double(forKey: "exchangeCourse")
        
        //FOR TEST NOT MAIN STRORYBOARD
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Send", bundle: nil)
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "sendAmount")
//        self.window?.rootViewController = initialViewController
//        self.window?.makeKeyAndVisible()
        
        
//        let branch: Branch = Branch.getInstance()
//        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
//            if error == nil {
//                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
//                // params will be empty if no data found
//                // ... insert custom logic here ...
//                print("params: %@", params as? [String: AnyObject] ?? {})
//            }
//        })
        // for debug and development only
        Branch.getInstance().setDebug()
        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
//            print(params as? [String: AnyObject] ?? {})
            if error == nil {
                let dictFormLink = params! as NSDictionary
                if (dictFormLink["address"] != nil) {
                    DataManager.shared.getAccount(completion: { (acc, err) in
                        if acc == nil {
                            return
                        }
                        let chainNameFromLink = (dictFormLink["address"] as! String).split(separator: ":").first
                        let addressFromLink = (dictFormLink["address"] as! String).split(separator: ":").last
                        let amountFromLink = dictFormLink["amount"] as! Double
                        
                        let storyboard = UIStoryboard(name: "Send", bundle: nil)
                        let sendStartVC = storyboard.instantiateViewController(withIdentifier: "sendStart") as! SendStartViewController
                        sendStartVC.presenter.addressSendTo = "\(addressFromLink ?? "")"
                        sendStartVC.presenter.amountInCrypto = amountFromLink
                        ((self.window?.rootViewController as! CustomTabBarViewController).selectedViewController as! UINavigationController).pushViewController(sendStartVC, animated: false)
                        sendStartVC.performSegue(withIdentifier: "chooseWalletVC", sender: (Any).self)
                    })
//                    self.window?.rootViewController?.navigationController?.pushViewController(sendStartVC, animated: false)
//                    let chooseWalletVC = WalletChoooseViewController()
//                    self.window?.rootViewController?.navigationController?.pushViewController(chooseWalletVC, animated: true)
                }
            }
        }
        
        return true
    }
    
    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        // pass the url to the handle deep link call
//        let branchHandled = Branch.getInstance().application(application,
//                                                             open: url,
//                                                             sourceApplication: sourceApplication,
//                                                             annotation: annotation
//        )
//        if (!branchHandled) {
//            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
//        }
//
//        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // handler for URI Schemes (depreciated in iOS 9.2+, but still used by some apps)
        Branch.getInstance().application(app, open: url, options: options)
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
        NotificationCenter.default.post(name: Notification.Name("hideKeyboard"), object: nil)
        DataManager.shared.finishRealmSession()
        DataManager.shared.realmManager.getAccount { (acc, err) in
            isNeedToAutorise = acc != nil
            
            //MARK: Check here isPin option from NSUserDefaults
            UserPreferences.shared.getAndDecryptCipheredMode(completion: { (pinMode, error) in
                 isNeedToAutorise = (pinMode as! NSString).boolValue
            })

            if self.presentedVC != nil {
                self.presentedVC?.dismiss(animated: true, completion: nil)
                self.openedAlert?.dismiss(animated: true, completion: nil)
            }
        }
        
        UserDefaults.standard.set(exchangeCourse, forKey: "exchangeCourse")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if self.presentedVC != nil {
            presentedVC?.dismiss(animated: true, completion: nil)
            openedAlert?.dismiss(animated: true, completion: nil)
        }
        
        exchangeCourse = UserDefaults.standard.double(forKey: "exchangeCourse")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.authorization()
        exchangeCourse = UserDefaults.standard.double(forKey: "exchangeCourse")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DataManager.shared.finishRealmSession()
        UserDefaults.standard.set(exchangeCourse, forKey: "exchangeCourse")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func performFirstEnterFlow() {
        guard self.window != nil && self.window?.rootViewController != nil else {
            return
        }
        
        let assetVC = self.window?.rootViewController?.childViewControllers[0].childViewControllers[0] as! AssetsViewController
        switch isDeviceJailbroken() {
        case true:
            assetVC.presenter.isJailed = true
        case false:
            assetVC.presenter.isJailed = false
            DataManager.shared.getServerConfig { (hardVersion, softVersion, err) in
                let dictionary = Bundle.main.infoDictionary!
                let buildVersion = (dictionary["CFBundleVersion"] as! NSString).integerValue
                
                //MARK: change > to <
                if err != nil || buildVersion > hardVersion! {
                    assetVC.isFlowPassed = true
                    assetVC.viewDidLoad()
                    let _ = UserPreferences.shared
                    self.saveMkVersion()
                } else {
                    assetVC.presentUpdateAlert()
                }
            }
        }
    }
    
    func saveMkVersion(){
        if UserDefaults.standard.value(forKey: "MKVersion") != nil {
            
        } else {
            UserDefaults.standard.set("1.0", forKey: "MKVersion")
        }
    }
    
    func authorization() {
        if isNeedToAutorise {
            self.window?.isUserInteractionEnabled = false
            let authVC = SecureViewController()
//            authVC.modalPresentationStyle = .overCurrentContext
            let selectedIndex = (self.window?.rootViewController as! CustomTabBarViewController).selectedIndex
            (self.window?.rootViewController?.childViewControllers[selectedIndex] as! UINavigationController).topViewController?.present(authVC, animated: true, completion: nil)
            isNeedToAutorise = false
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

