//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift
import Alamofire
import CryptoSwift
//import BiometricAuthentication

private typealias ScrollViewDelegate = AssetsViewController
private typealias CollectionViewDelegate = AssetsViewController
private typealias CollectionViewDelegateFlowLayout = AssetsViewController
private typealias TableViewDelegate = AssetsViewController
private typealias TableViewDataSource = AssetsViewController
private typealias PresentingSheetDelegate = AssetsViewController
private typealias CancelDelegate = AssetsViewController
private typealias CreateWalletDelegate = AssetsViewController

class AssetsViewController: UIViewController, AnalyticsProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    weak var backupView: UIView?
    
    let presenter = AssetsPresenter()
    let progressHUD = ProgressHUD(text: Constants.AssetsScreen.progressString)
    
    var isSeedBackupOnScreen = false
    
    var isFirstLaunch = true
    
    var isFlowPassed = false
    
    var isSocketInitiateUpdating = false
    
    var isInsetCorrect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.backUpView()
        
        tableView.accessibilityIdentifier = "AssetsTableView"
        view.isUserInteractionEnabled = false
        registerCells()
        presenter.assetsVC = self
        presenter.tabBarFrame = tabBarController?.tabBar.frame
        navigationController?.setNavigationBarHidden(true, animated: false)

        guard isFlowPassed else {
            self.view.isUserInteractionEnabled = true
            return
        }
        
        let isFirst = DataManager.shared.checkIsFirstLaunch()
        if isFirst {
            sendAnalyticsEvent(screenName: screenFirstLaunch, eventName: screenFirstLaunch)
            self.view.isUserInteractionEnabled = true
            return
        }
        
        sendAnalyticsEvent(screenName: screenMain, eventName: screenMain)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateExchange), name: NSNotification.Name("exchageUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateWalletAfterSockets), name: NSNotification.Name("transactionUpdated"), object: nil)
        
        let _ = MasterKeyGenerator.shared.generateMasterKey{_,_, _ in }
        
        checkOSForConstraints()

        self.view.addSubview(progressHUD)
        if self.presenter.account != nil {
            tableView.frame.size.height = screenHeight - tabBarController!.tabBar.frame.height
        }
        //MAKE: first launch
//        let _ = DataManager.shared
        
//        DataManager.shared.startCoreTest()
        
        //MARK: test
//        progressHUD.show()
        presenter.auth()
        
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        }
        
//        DataManager.shared.coreLibManager.startSwiftTest()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.presenter.isJailed {
            self.presentWarningAlert(message: Constants.Security.jailbrokenDeviceWarningString)
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.isInsetCorrect = true
//        presenter.contentOffset = tableView.contentOffset
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: presenter.account == nil)
        
        if !self.isFirstLaunch {
            self.presenter.updateWalletsInfo()
        }
        self.isFirstLaunch = false
        guard isFlowPassed == true else {
            return
        }


        self.tabBarController?.tabBar.frame = self.presenter.tabBarFrame!
        if self.presenter.account != nil {
            tableView.frame.size.height = screenHeight - tabBarController!.tabBar.frame.height
        }
        
        //FIXME: PROBABLE for the best solution
        //here fixed hiding table botton behind tabbar
//
//        if tableView.contentOffset.y + screenHeight > tableView.contentSize.height {
//            tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height - screenHeight)
//        }
//        if presenter.account != nil && tableView.numberOfRows(inSection: 0) > presenter.tappedIndexPath.row {
//            tableView.reloadData()
//            tableView.scrollToRow(at: presenter.tappedIndexPath, at: .bottom, animated: true)
//        }
    }
    
    override func viewDidLayoutSubviews() {
//        if isInsetCorrect {
//            self.tableView.contentInset.bottom = 0
//        } else {
//            self.tableView.contentInset.bottom = 49
//        }
    }
    
    @objc func updateExchange() {
//        let offsetBeforeUpdate = self.tableView.contentOffset
//        self.tableView.reloadData()
//        self.tableView.setContentOffset(offsetBeforeUpdate, animated: false)
        for cell in self.tableView.visibleCells {
            if cell.isKind(of: WalletTableViewCell.self) {
                (cell as! WalletTableViewCell).fillInCell()
            }
        }
    }
    
    @objc func updateWalletAfterSockets() {
        if isSocketInitiateUpdating {
            return
        }
        
        if !isVisible() {
            return
        }
        
        isSocketInitiateUpdating = true
        presenter.getWalletVerboseForSockets { (_) in
            self.isSocketInitiateUpdating = false
            
            for cell in self.tableView.visibleCells {
                if cell.isKind(of: WalletTableViewCell.self) {
                    (cell as! WalletTableViewCell).fillInCell()
                }
            }
        }
    }
    
    func backUpView() {
//        if isSeedBackupOnScreen {
//            if presenter.account!.isSeedPhraseSaved() {
//                backupView?.removeFromSuperview()
//                isSeedBackupOnScreen = false
//            }
//
//            return
//        }
        
        if backupView != nil {
            return
        }
        
        let view = UIView()
        if screenHeight == heightOfX {
            view.frame = CGRect(x: 16, y: 50, width: screenWidth - 32, height: Constants.AssetsScreen.backupButtonHeight)
        } else {
            view.frame = CGRect(x: 16, y: 25, width: screenWidth - 32, height: Constants.AssetsScreen.backupButtonHeight)
        }
        
        view.layer.cornerRadius = 20
        view.backgroundColor = #colorLiteral(red: 0.9229970574, green: 0.08180250973, blue: 0.2317947149, alpha: 1)
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        
//        if !presenter.account!.isSeedPhraseSaved() {
            view.isHidden = false
//            isSeedBackupOnScreen = true
            let image = UIImageView()
            image.image = #imageLiteral(resourceName: "warninngBigWhite")
            image.frame = CGRect(x: 13, y: 11, width: 22, height: 22)
            
            let btn = UIButton()
            btn.frame = CGRect(x: 50, y: 0, width: view.frame.width - 35, height: view.frame.height)
            btn.setTitle("Backup is needed!", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont(name: "Avenir-Next", size: 6)
            btn.contentHorizontalAlignment = .left
            btn.addTarget(self, action: #selector(goToSeed), for: .touchUpInside)
            
            view.addSubview(btn)
            view.addSubview(image)
            backupView = view
            self.view.addSubview(backupView!)
            view.isHidden = true
            view.isUserInteractionEnabled = false
//        } else {
//            view.isHidden = true
//        }
    }
    
    @objc func goToSeed() {
        sendAnalyticsEvent(screenName: screenMain, eventName: backupSeedTap)
        let stroryboard = UIStoryboard(name: "SeedPhrase", bundle: nil)
        let vc = stroryboard.instantiateViewController(withIdentifier: "seedAbout")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //////////////////////////////////////////////////////////////////////
    //test
    
    func fetchAssets() {
        guard presenter.account?.token != nil else {
            return
        }
        
        DataManager.shared.apiManager.getAssets(completion: { (assetsDict, error) in
             print(assetsDict as Any)
        })
    }
    
    func getTransInfo() {
        DataManager.shared.apiManager.getTransactionInfo(transactionString: "d83a5591585f05dc367d5e68579ece93240a6b4646133a38106249cadea53b77") { (transDict, error) in
                                                            guard transDict != nil else {
                                                                return
                                                            }
                                                            
                                                            print(transDict)
        }
    }
    //////////////////////////////////////////////////////////////////////
    
    
    //MARK: Setup functions
    
    func checkOSForConstraints() {
        if #available(iOS 11.0, *) {
            //OK: Storyboard was made for iOS 11
        } else {
            self.tableViewTopConstraint.constant = 0
//            self.tableViewBottomConstraint.constant = 50
        }
    }
    
    func registerCells() {
        let walletCell = UINib.init(nibName: "WalletTableViewCell", bundle: nil)
        self.tableView.register(walletCell, forCellReuseIdentifier: "walletCell")
        
        let portfolioCell = UINib.init(nibName: "PortfolioTableViewCell", bundle: nil)
        self.tableView.register(portfolioCell, forCellReuseIdentifier: "portfolioCell")
        
        let newWalletCell = UINib.init(nibName: "NewWalletTableViewCell", bundle: nil)
        self.tableView.register(newWalletCell, forCellReuseIdentifier: "newWalletCell")
        
        let textCell = UINib.init(nibName: "TextTableViewCell", bundle: nil)
        self.tableView.register(textCell, forCellReuseIdentifier: "textCell")
        
        let logoCell = UINib.init(nibName: "LogoTableViewCell", bundle: nil)
        self.tableView.register(logoCell, forCellReuseIdentifier: "logoCell")
        
        let createOrRestoreCell = UINib.init(nibName: "CreateOrRestoreBtnTableViewCell", bundle: nil)
        self.tableView.register(createOrRestoreCell, forCellReuseIdentifier: "createOrRestoreCell")
    }
    
    func goToWalletVC(indexPath: IndexPath) {
        let walletVC = presenter.getWalletViewController(indexPath: indexPath)
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
    
    func updateUI() {
        self.tableView.reloadData()
    }
    
    func presentWarningAlert(message: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let slpashScreen = storyboard.instantiateViewController(withIdentifier: "splash") as! SplashViewController
        slpashScreen.isJailAlert = 1
        self.present(slpashScreen, animated: true, completion: nil)
    }
    
    func presentUpdateAlert() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let slpashScreen = storyboard.instantiateViewController(withIdentifier: "splash") as! SplashViewController
        slpashScreen.isJailAlert = 0
        self.present(slpashScreen, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.createWalletVCSegueID {
            let createVC = segue.destination as! CreateWalletViewController
            createVC.presenter.account = presenter.account
        }
    }
    
    func changePageControl(currentpage: Int) {
//        let headerCell = tableView(tableView, cellForRowAt: [0, 0]) as? PortfolioTableViewCell
//        headerCell?.changePageControl(currentPage: currentpage)
    }
}

extension CreateWalletDelegate: CreateWalletProtocol {
    func goToCreateWallet() {
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        self.performSegue(withIdentifier: Constants.Storyboard.createWalletVCSegueID, sender: Any.self)
    }
}

extension CancelDelegate: CancelProtocol {
    func cancelAction() {
        presentDonationVCorAlert()
    }
    
    func presentNoInternet() {
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: presenter.account == nil)
    }
}

extension PresentingSheetDelegate: OpenCreatingSheet {
    //MARK: CreateNewWalletProtocol
    func openNewWalletSheet() {
        if self.presenter.account == nil {
            return
        }
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        sendAnalyticsEvent(screenName: screenMain, eventName: createWalletTap)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let creatingVC = storyboard.instantiateViewController(withIdentifier: "creatingVC") as! CreatingWalletActionsViewController
        creatingVC.cancelDelegate = self
        creatingVC.createProtocol = self
        creatingVC.modalPresentationStyle = .overCurrentContext
        self.present(creatingVC, animated: true, completion: nil)
    }
}

extension TableViewDelegate : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.tappedIndexPath = indexPath
        
        switch indexPath {
        case [0,0]:
            sendAnalyticsEvent(screenName: screenMain, eventName: logoTap)
            break
        case [0,1]:
            break
            //            if self.presenter.account == nil {
            //                break
            //            }
        //            self.present(actionSheet, animated: true, completion: nil)
        case [0,2]:
            if self.presenter.account == nil {
                //                progressHUD.show()
                //                presenter.guestAuth(completion: { (answer) in
                sendAnalyticsEvent(screenName: screenFirstLaunch, eventName: createFirstWalletTap)
                self.performSegue(withIdentifier: "createWalletVC", sender: Any.self)
                //                })
            } else {
                if self.presenter.isWalletExist() {
                    goToWalletVC(indexPath: indexPath)
                } else {
                    break
                }
            }
        case [0,3]:
            if self.presenter.account == nil {
                sendAnalyticsEvent(screenName: screenFirstLaunch, eventName: restoreMultyTap)
                let storyboard = UIStoryboard(name: "SeedPhrase", bundle: nil)
                let backupSeedVC = storyboard.instantiateViewController(withIdentifier: "backupSeed") as! CheckWordsViewController
                backupSeedVC.isRestore = true
                self.navigationController?.pushViewController(backupSeedVC, animated: true)
            } else {
                if self.presenter.isWalletExist() {
                    goToWalletVC(indexPath: indexPath)
                }
            }
        default:
            if self.presenter.isWalletExist() {
                goToWalletVC(indexPath: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath == [0,0] {
//            //            return 283  //portfolio height
//            if self.presenter.account?.seedPhrase != nil && self.presenter.account?.seedPhrase != "" {
//                if self.presenter.account != nil {
//                    if screenHeight == heightOfX {
//                        //                    return 255 //logo height
//                        return 400
//                    } else {
//                        //                    return 245
//                        return 390
//                    }
//                }else {
//                    if screenHeight == heightOfX {
//                        return 255 //logo height
//                    } else {
//                        return 245
//                    }
//                }
//            } else {
//                if self.presenter.account != nil {
//                    //                                return 220  //logo
//                    return 340
//                } else {
//                    return 220  //logo
//                }
//            }
//        } else if indexPath == [0, 1] {
//            return 75
//        } else {
//            return 104   // wallet height
//            //            return 100
//        }
        
        switch indexPath {
        case [0,0]:         // PORTFOLIO CELL  or LOGO
            if presenter.account == nil {
                return 220
            } else {
                if presenter.account!.isSeedPhraseSaved() {
                    return 340
                } else {
                    return 340 + Constants.AssetsScreen.backupAssetsOffset
                }
            }
        case [0,1]:        // !!!NEW!!! WALLET CELL
            return 75
        case [0,2]:
            if self.presenter.account != nil {
                if presenter.isWalletExist() {
                    return 104
                } else {
                    return 121
                }
            } else {   // acc == nil
                return 100
            }
        case [0,3]:
            if self.presenter.account != nil {
                return 104
            } else {
                return 100
            }
        default:
            return 104
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [0,0]:         // PORTFOLIO CELL  or LOGO
            if presenter.account == nil {
                return 220
            } else {
                if presenter.account!.isSeedPhraseSaved() {
                    return 340
                } else {
                    return 340 + Constants.AssetsScreen.backupAssetsOffset
                }
            }
        case [0,1]:        // !!!NEW!!! WALLET CELL
            return 75
        case [0,2]:
            if self.presenter.account != nil {
                if presenter.isWalletExist() {
                    return 104
                } else {
                    return 121
                }
            } else {   // acc == nil
                return 100
            }
        case [0,3]:
            if self.presenter.account != nil {
                return 104
            } else {
                return 100
            }
        default:
            return 104
        }
    }
    
    override var preferredContentSize: CGSize {
        get {
            self.tableView.layoutIfNeeded()
            return self.tableView.contentSize
        }
        set { }
    }
}

extension TableViewDataSource : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.presenter.account != nil {
            if presenter.isWalletExist() {
                return 2 + presenter.account!.wallets.count  // logo / new wallet /wallets
            } else {
                return 3                                     // logo / new wallet / text cell
            }
        } else {
            return 4                                         // logo / empty cell / create wallet / restore
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0,0]:         // PORTFOLIO CELL  or LOGO
            if presenter.account == nil {
                let logoCell = self.tableView.dequeueReusableCell(withIdentifier: "logoCell") as! LogoTableViewCell
                return logoCell
            } else {
                let portfolioCell = self.tableView.dequeueReusableCell(withIdentifier: "portfolioCell") as! PortfolioTableViewCell
                portfolioCell.mainVC = self
                portfolioCell.delegate = self
                
                return portfolioCell
            }
        case [0,1]:        // !!!NEW!!! WALLET CELL
            let newWalletCell = self.tableView.dequeueReusableCell(withIdentifier: "newWalletCell") as! NewWalletTableViewCell
            newWalletCell.delegate = self
            
            if presenter.account == nil {
                newWalletCell.hideAll(flag: true)
            } else {
                newWalletCell.hideAll(flag: false)
            }
            
            return newWalletCell
        case [0,2]:
            if self.presenter.account != nil {
                //MARK: change logiv
                
                if presenter.isWalletExist() {
                    let walletCell = self.tableView.dequeueReusableCell(withIdentifier: "walletCell") as! WalletTableViewCell
                    //                    walletCell.makeshadow()
                    walletCell.wallet = presenter.account?.wallets[indexPath.row - 2]
                    walletCell.accessibilityIdentifier = "\(indexPath.row - 2)"
                    walletCell.fillInCell()
                    
                    return walletCell
                } else {
                    let textCell = self.tableView.dequeueReusableCell(withIdentifier: "textCell") as! TextTableViewCell
                    
                    return textCell
                }
            } else {   // acc == nil
                let createCell = self.tableView.dequeueReusableCell(withIdentifier: "createOrRestoreCell") as! CreateOrRestoreBtnTableViewCell
                
                return createCell
            }
        case [0,3]:
            if self.presenter.account != nil {
                let walletCell = self.tableView.dequeueReusableCell(withIdentifier: "walletCell") as! WalletTableViewCell
                //                walletCell.makeshadow()
                walletCell.wallet = presenter.account?.wallets[indexPath.row - 2]
                walletCell.accessibilityIdentifier = "\(indexPath.row - 2)"
                walletCell.fillInCell()
                
                return walletCell
            } else {
                let restoreCell = self.tableView.dequeueReusableCell(withIdentifier: "createOrRestoreCell") as! CreateOrRestoreBtnTableViewCell
                restoreCell.makeRestoreCell()
                
                return restoreCell
            }
        default:
            let walletCell = self.tableView.dequeueReusableCell(withIdentifier: "walletCell") as! WalletTableViewCell
            
            walletCell.wallet = presenter.account?.wallets[indexPath.row - 2]
            walletCell.accessibilityIdentifier = "\(indexPath.row - 2)"
            walletCell.fillInCell()
            
            return walletCell
        }
    }
}

extension CollectionViewDelegateFlowLayout : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: screenWidth, height: 277 /* (screenWidth / 375.0)*/)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CollectionViewDelegate : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let donatAlert = storyboard.instantiateViewController(withIdentifier: "donationAlert") as! DonationAlertViewController
        donatAlert.modalPresentationStyle = .overCurrentContext
        donatAlert.cancelDelegate = self
        present(donatAlert, animated: true, completion: nil)
        (tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        
        logAnalytics(indexPath: indexPath)
    }
    
    func logAnalytics(indexPath: IndexPath) {
        let eventCode = indexPath.row == 0 ? donationForPortfolioSC : donationForChartsSC
        sendDonationAlertScreenPresentedAnalytics(code: eventCode)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let firstCell = self.tableView.cellForRow(at: [0,0]) else { return }
        (firstCell as! PortfolioTableViewCell).pageControl.currentPage = indexPath.row
    }
}

extension ScrollViewDelegate: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let pageNumber = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
//        changePageControl(currentpage: pageNumber)
    }
}
