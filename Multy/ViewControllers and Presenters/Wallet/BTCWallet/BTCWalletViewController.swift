//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias TableViewDelegate = BTCWalletViewController
private typealias ScrollViewDelegate = BTCWalletViewController
private typealias TableViewDataSource = BTCWalletViewController
private typealias CollectionViewDelegateFlowLayout = BTCWalletViewController
private typealias CancelDelegate = BTCWalletViewController
private typealias LocalizeDelegate = BTCWalletViewController

class BTCWalletViewController: UIViewController, AnalyticsProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var backView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var emptySecondLbl: UILabel!
    @IBOutlet weak var emptyArrowImg: UIImageView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    var backupView : UIView?

    @IBOutlet weak var heightOfBottomBar: NSLayoutConstraint!
    @IBOutlet weak var bottomTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customHeader: UIView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    
    
    var presenter = BTCWalletPresenter()
    
    var isBackupOnScreen = true
//    let progressHUD = ProgressHUD(text: "Updating...")
    let loader = PreloaderView(frame: HUDFrame, text: "Updating...", image: #imageLiteral(resourceName: "walletHuge"))
    
    var visibleCells = 5  // iphone 6  height 667
    let gradientLayer = CAGradientLayer()
    
    var isSocketInitiateUpdating = false
    
    var lastY: CGFloat = 0.0
    
    
    var recog: UIPanGestureRecognizer?
    var startY: CGFloat = 0.0
    var startHeight: CGFloat = 0.0
    var lastContentOffset: CGFloat = 0
    
    var headerTopY: CGFloat = 0.0
    var backupTopY: CGFloat = 0.0
    var tableTopY: CGFloat = 0.0
    var collectionStartY: CGFloat = 0.0
    
    var isCanUpdate = true
    var isTableOnTop = false
    
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.blue
//        refreshControl.backgroundColor = .blue
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spiner.isHidden = true
        spiner.stopAnimating()
        loader.show(customTitle: Constants.updatingString)
        view.addSubview(loader)
        loader.hide()
        self.swipeToBack()
        presenter.mainVC = self
        presenter.fixConstraints()
        presenter.registerCells()
        checkVisibleCellsWithHetight()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateExchange), name: NSNotification.Name("exchageUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateWalletAfterSockets), name: NSNotification.Name("transactionUpdated"), object: nil)
        
        
        
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: "\(screenWalletWithChain)\(presenter.wallet!.chain)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        self.titleLbl.text = self.presenter.wallet?.name
        self.backUpView(height: 272)
        self.fixForX()
        self.presenter.getHistoryAndWallet()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            
        } else {
            //            self.tableView.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
            //                                                       UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
            //                                         gradientOrientation: .topRightBottomLeft)
        }
        self.fixForX()
        self.startHeight = self.tableView.frame.size.height
        self.collectionStartY = self.collectionView.frame.origin.y
        self.customHeader.roundCorners(corners: [.topRight, .topLeft], radius: 20)
        setupUI()
    }
    
    func setupUI() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(changeTableY))
        let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(changeTableY))
        if self.tableView.gestureRecognizers?.count == 5 {
            self.tableView.addGestureRecognizer(gestureRecognizer)
            self.customHeader.addGestureRecognizer(gestureRecognizer2)
            self.recog = gestureRecognizer
        }
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(setTableToBot))
        self.backImage.addGestureRecognizer(tap)
        self.backImage.isUserInteractionEnabled = true
        self.customHeader.isUserInteractionEnabled = true
        
        self.tableView.isScrollEnabled = false
        self.tableView.bounces = true
        self.collectionView.backgroundColor = .clear
        self.tableView.backgroundColor = .white
        makeConstantsForAnimation()
    }
    
    @objc func setTableToBot(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.customHeader.frame.origin.y = self.startY - 20
            self.backupView?.frame.origin.y = self.startY - 40
            self.tableView.frame.origin.y = self.startY + 10
            self.tableView.frame.size.height = self.startHeight
            self.tableView.scrollToTop()
            self.tableView.isScrollEnabled = false
            self.collectionView.frame.origin.y = self.collectionStartY
            self.checkrecogOnTable()
            self.isCanUpdate = true
            self.spiner.stopAnimating()
            self.spiner.isHidden = true
            self.isTableOnTop = false
        }
    }
    
    @objc func setTableToTop() {
        UIView.animate(withDuration: 0.1) {
            self.customHeader.frame.origin.y = self.headerTopY
            self.backupView?.frame.origin.y = self.backupTopY
            self.tableView.frame.size.height = self.view.frame.height - self.headerTopY - self.bottomView.frame.height - 30
            self.tableView.frame.origin.y = self.tableTopY
            self.tableView.isScrollEnabled = true
            self.tableView.removeGestureRecognizer(self.recog!)
            self.spiner.stopAnimating()
            self.spiner.isHidden = true
            self.isTableOnTop = true
        }
    }
    
    func makeConstantsForAnimation() {
        switch screenHeight {
        case heightOfX:
            headerTopY = 100
            backupTopY = 80
            tableTopY = 130
        default:
            headerTopY = 70
            backupTopY = 60
            tableTopY = 100
        }
        if self.presenter.blockedAmount != 0 {
            UIView.animate(withDuration: 0.2) {
                self.backImage.frame.size.height = 382
                self.collectionView.frame.size.height = 260
                self.collectionView.frame.origin.y = self.collectionStartY
                self.customHeader.frame.origin.y = 352
                self.tableView.frame.origin.y = 382
                self.tableView.frame.size.height = screenHeight - self.tableView.frame.origin.y - self.bottomView.frame.height
                self.changeBackupY()
            }
        } else {
            setTableToBot(duration: 0.2)
        }
        self.fixForX()
        self.startY = self.backImage.frame.height
        self.startHeight = self.tableView.frame.size.height
    }
    
    func changeBackupY() {
        if self.backupView != nil {
            self.backupView?.frame.origin.y = self.customHeader.frame.origin.y - 10
        }
    }
    
    func checkrecogOnTable() {
        if !self.tableView.gestureRecognizers!.contains(recog!) {
            self.tableView.addGestureRecognizer(recog!)
        }
    }
    
    func checkVisibleCellsWithHetight() {
        if screenHeight == heightOfStandard {
            visibleCells = 5
        } else if screenHeight == heightOfPlus || screenHeight == heightOfX {
            visibleCells = 7
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
        self.presenter.getHistoryAndWallet()
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.tableView.isUserInteractionEnabled = false
        self.presenter.getHistoryAndWallet()
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: "\(pullWalletWithChain)\(presenter.wallet?.chain)")
    }
    
    @objc func updateExchange() {
        let firstCell = self.tableView.cellForRow(at: [0,0]) as? BTCWalletHeaderTableViewCell
        firstCell?.updateUI()
    }
    
    func updateHistory() {
        if presenter.historyArray.count > 0 {
            hideEmptyLbls()
        }
        
        for cell in self.tableView.visibleCells {
            if cell.isKind(of: TransactionWalletCell.self) {
                if let indexPath = self.tableView.indexPath(for: cell) {
                    (cell as! TransactionWalletCell).changeState(isEmpty: indexPath.row > presenter.numberOfTransactions()) // since we begin transactions from index 1
                    (cell as! TransactionWalletCell).fillCell()
                } else {
                    //How is that possible?
                }
            } else if cell.isKind(of: TransactionPendingCell.self) {
                (cell as! TransactionPendingCell).fillCell()
            }
        }
    }
    
    func backUpView(height: CGFloat) {
        if self.isBackupOnScreen == false {
//            if backupView != nil && backupView!.frame.origin.y + 20 != height {
//                backupView!.frame = CGRect(x: 16, y: self.tableView.frame.origin.y - 40, width: screenWidth - 32, height: 40)
//            }
            return
        }
        backupView = UIView()
        backupView!.frame = CGRect(x: 16, y: self.tableView.frame.origin.y - 40, width: screenWidth - 32, height: 40)
        backupView!.layer.cornerRadius = 20
        backupView!.backgroundColor = .white
        
        backupView!.setShadow(with: #colorLiteral(red: 0.1490196078, green: 0.2980392157, blue: 0.4156862745, alpha: 0.3))
        
        if self.presenter.account?.seedPhrase != nil && self.presenter.account?.seedPhrase != "" {
            backupView!.isHidden = false
        } else {
            backupView!.isHidden = true
        }
        
        if self.view.subviews.contains(backupView!) {
            return
        }
        
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "warninngBig")
        image.frame = CGRect(x: 13, y: 11, width: 22, height: 22)
        
        let chevron = UIImageView()
        chevron.image = #imageLiteral(resourceName: "chevronRed")
        chevron.frame = CGRect(x: backupView!.frame.width - 35, y: 15, width: 11, height: 11)
        
        let btn = UIButton()
        btn.frame = CGRect(x: 50, y: 0, width: chevron.frame.origin.x - 50, height: backupView!.frame.height)
        btn.setTitle(localize(string: Constants.backupNeededString), for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(goToSeed), for: .touchUpInside)
        
        backupView!.addSubview(chevron)
        backupView!.addSubview(btn)
        backupView!.addSubview(image)
        self.view.addSubview(backupView!)
        self.isBackupOnScreen = false
    }
    
    @objc func goToSeed() {
        let stroryboard = UIStoryboard(name: "SeedPhrase", bundle: nil)
        let vc = stroryboard.instantiateViewController(withIdentifier: "seedAbout")
        self.navigationController?.pushViewController(vc, animated: true)
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: backupSeedTap)
    }
    
    @IBAction func closeAction() {
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: closeTap)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: "\(settingsWithChainTap)\(presenter.wallet!.chain)")
        self.performSegue(withIdentifier: "settingsVC", sender: sender)
    }
    
 
    
    func fixUiWithPendingTransactions() {
        let numberOfPending = presenter.getNumberOfPendingTransactions()
        let numberOfTransactions = presenter.numberOfTransactions()
        if screenHeight == heightOfPlus && numberOfTransactions < 5 {
            if numberOfPending > 2 {
                self.tableView.isScrollEnabled = true
            }
        } else if screenHeight == heightOfStandard && numberOfTransactions < 5 {
            if numberOfPending > 1 {
                self.tableView.isScrollEnabled = true
            }
        }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if presenter.wallet!.availableAmount.isZero {
            self.presentAlert(with: localize(string: Constants.noFundsString))
            
            return
        }
        
        let storyboard = UIStoryboard(name: "Send", bundle: nil)
        let sendStartVC = storyboard.instantiateViewController(withIdentifier: "sendStart") as! SendStartViewController
        sendStartVC.presenter.transactionDTO.choosenWallet = self.presenter.wallet
        sendStartVC.presenter.isFromWallet = true
        self.navigationController?.pushViewController(sendStartVC, animated: true)
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: "\(sendWithChainTap)\(presenter.wallet!.chain)")
    }
    
    @IBAction func receiveAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Receive", bundle: nil)
        let receiveDetailsVC = storyboard.instantiateViewController(withIdentifier: "receiveDetails") as! ReceiveAllDetailsViewController
        receiveDetailsVC.presenter.wallet = self.presenter.wallet
        self.navigationController?.pushViewController(receiveDetailsVC, animated: true)
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: "\(receiveWithChainTap)\(presenter.wallet!.chain)")
    }
    
    @IBAction func exchangeAction(_ sender: Any) {
        unowned let weakSelf =  self
        self.presentDonationAlertVC(from: weakSelf, with: "io.multy.addingExchange50")
//        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: "\(exchangeWithChainTap)\(presenter.wallet!.chain)")
        logAnalytics()
    }
    
    func logAnalytics() {
        sendDonationAlertScreenPresentedAnalytics(code: donationForExchangeFUNC)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transactionVC" {
//            let transactionVC = segue.destination as! TransactionViewController
        } else if segue.identifier == "settingsVC" {
            let settingsVC = segue.destination as! WalletSettingsViewController
            settingsVC.presenter.wallet = self.presenter.wallet
        }
    }
    
    func hideEmptyLbls() {
        self.emptySecondLbl.isHidden = true
        self.emptyArrowImg.isHidden = true
    }
    
    func fixForiPad() {
        if screenHeight == heightOfiPad {
            hideEmptyLbls()
            self.bottomTableConstraint.constant = -50
        }
    }
    
    func fixForX() {
        if screenHeight == heightOfX {
            self.bottomView.frame.size.height = 83
//            self.heightOfBottomBar.constant = 83
            self.bottomConstraint.constant = 30
//        } else if screenHeight == heightOfStandard {

//            self.bottomConstraint.constant = 30
        }
    }
    
    func fixForPlus() {
        if screenHeight == heightOfPlus {
            self.bottomTableConstraint.constant = -50
        }
    }
    
    func updateUI() {
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }

}


extension CancelDelegate : CancelProtocol {
    func cancelAction() {
//        presentDonationVCorAlert()
        self.makePurchaseFor(productId: "io.multy.addingExchange5")
    }
    
    func donate50(idOfProduct: String) {
        self.makePurchaseFor(productId: idOfProduct)
    }
    
    func presentNoInternet() {
        
    }
}

extension TableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.presenter.numberOfTransactions() == 0 {
            return
        }
        let countOfHistObjs = self.presenter.numberOfTransactions()
        if indexPath.row >= countOfHistObjs && countOfHistObjs <= visibleCells {
            return
        }
        
        let storyBoard = UIStoryboard(name: "Wallet", bundle: nil)
        let transactionVC = storyBoard.instantiateViewController(withIdentifier: "transaction") as! TransactionViewController
        transactionVC.presenter.histObj = presenter.historyArray[indexPath.row]
        transactionVC.presenter.blockchainType = BlockchainType.create(wallet: presenter.wallet!)
        transactionVC.presenter.wallet = presenter.wallet!
        self.navigationController?.pushViewController(transactionVC, animated: true)
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(presenter.wallet!.chain)", eventName: "\(transactionWithChainTap)\(presenter.wallet!.chain)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < presenter.numberOfTransactions() && presenter.isTherePendingMoney(for: indexPath) { // <= since we begins from 1
            return 135
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.tableView.addGestureRecognizer(recog!)
        }
    }
    
    @IBAction func changeTableY(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        if isTableOnTop && translation.y < 0 {
            return
        }
        if self.customHeader.frame.origin.y + translation.y < 100 {
            if self.customHeader.frame.origin.y + translation.y > 80 {
                
            } else {
                self.setTableToTop()
                if self.presenter.numberOfTransactions() > 5 {
                    self.tableView.removeGestureRecognizer(recog!)
                } else {
                    return
                }
            }
        }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let coef: CGFloat = self.presenter.wallet!.isTherePendingAmount() ? 20 : 9
            if translation.y > 0 && self.tableView.frame.origin.y > self.startY + 10 {
                UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                    if self.spiner.isAnimating == false {
                        self.spiner.isHidden = false
                        self.spiner.startAnimating()
                    }
                    var transY = translation.y > 200 ? translation.y : translation.y/2
                    transY = transY > 250 ? transY : transY/2
                    self.tableView.frame.size.height = self.tableView.frame.size.height - transY
                    self.tableView.center = CGPoint(x: self.view.center.x, y: self.tableView.center.y + transY)
                    gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
                    self.backupView?.frame.origin.y = self.tableView.frame.origin.y - 50
                    self.customHeader.frame.origin.y = self.tableView.frame.origin.y - 30
                    let coef: CGFloat = self.presenter.wallet!.isTherePendingAmount() ? 20 : 9
                    self.collectionView.frame.origin.y = self.customHeader.frame.origin.y - self.collectionView.frame.height - coef
                    if self.tableView.frame.origin.y > (self.startY + self.tableTopY) / 2 {
                        if self.tableView.frame.origin.y > screenHeight/2 + 40 {
                            self.updateByPull()
                            self.isCanUpdate = false
                        }
                    }
                }) { (bool) in
                    
                }
            } else {
                tableView.frame.size.height = tableView.frame.size.height - translation.y
                tableView.center = CGPoint(x: self.view.center.x, y: self.tableView.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
                self.backupView?.frame.origin.y = self.tableView.frame.origin.y - 50
                self.customHeader.frame.origin.y = self.tableView.frame.origin.y - 30
                if self.tableView.frame.origin.y > startY + 10 {
                    self.collectionView.frame.origin.y = self.customHeader.frame.origin.y - self.collectionView.frame.height - coef
                }
            }
        }
        
        //auto animation for go to top or bottom
        if gestureRecognizer.state == .ended {
            if self.tableView.frame.origin.y > (startY + tableTopY) / 2 {
                self.setTableToBot(duration: 0.5)
            } else {
                self.setTableToTop()
            }
        }
    }
    
    func updateByPull() {
        if isCanUpdate {
            self.presenter.getHistoryAndWallet()
        }
    }
}

extension ScrollViewDelegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -20 {
            setTableToBot(duration: 0.2)
            tableView.scrollToRow(at: [0,0], at: .top, animated: false)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
}

extension TableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // check number of transactions
        // else return some empty cells
        let countOfHistObjects = self.presenter.numberOfTransactions()
        if countOfHistObjects > 0 {
            self.tableView.isScrollEnabled = true
            if countOfHistObjects < 10 {
                return 10
            } else {
                return countOfHistObjects
            }
        } else {
            if screenHeight == heightOfX {
                return 13
            }
            return 10
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countOfHistObjs = self.presenter.numberOfTransactions()
        
        if indexPath.row < countOfHistObjs && presenter.isTherePendingMoney(for: indexPath) {
            let pendingTrasactionCell = tableView.dequeueReusableCell(withIdentifier: "TransactionPendingCellID") as! TransactionPendingCell
            pendingTrasactionCell.selectionStyle = .none
            pendingTrasactionCell.histObj = presenter.historyArray[indexPath.row]
            pendingTrasactionCell.wallet = presenter.wallet
            pendingTrasactionCell.fillCell()
            
            return pendingTrasactionCell
        } else {
            let transactionCell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionWalletCellID") as! TransactionWalletCell
            transactionCell.selectionStyle = .none
            if countOfHistObjs > 0 {
                if indexPath.row >= countOfHistObjs {
                    transactionCell.changeState(isEmpty: true)
                } else {
                    transactionCell.histObj = presenter.historyArray[indexPath.row]
                    transactionCell.wallet = presenter.wallet!
                    transactionCell.fillCell()
                    transactionCell.changeState(isEmpty: false)
                    self.hideEmptyLbls()
                    if indexPath.row != 1 {
                        transactionCell.changeTopConstraint()
                    }
                }
            } else {
                transactionCell.changeState(isEmpty: true)
                fixForiPad()
            }
            
            return transactionCell
        }
    }
}

extension CollectionViewDelegateFlowLayout : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightForFirstCell : CGFloat = presenter.blockedAmount == 0 ? 190.0 : 250.0
        return CGSize(width: screenWidth, height: heightForFirstCell)
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

extension BTCWalletViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return (self.wallet?.addresses.count)!
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "MainWalletCollectionViewCellID", for: indexPath) as! BTCWalletHeaderCollectionViewCell
        cell.wallet = self.presenter.wallet
        cell.blockedAmount = self.presenter.blockedAmount
        cell.mainVC = self
        cell.fillInCell()
        
        return cell
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Wallets"
    }
}
