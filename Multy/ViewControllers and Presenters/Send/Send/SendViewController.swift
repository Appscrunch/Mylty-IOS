//
//  SendViewController.swift
//  Multy
//
//  Created by Artyom Alekseev on 15.05.2018.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import UIKit
import Lottie
import UPCarouselFlowLayout

enum SendMode {
    case searching
    case prepareSending
    case inSend
}

private typealias LocalizeDelegate = SendViewController

class SendViewController: UIViewController {
    @IBOutlet weak var walletsCollectionView: UICollectionView!
    @IBOutlet weak var walletsCollectionViewFL: UICollectionViewFlowLayout!
    @IBOutlet weak var searchingRequestsHolderView: UIView!
    @IBOutlet weak var foundActiveRequestsHolderView: UIView!
    @IBOutlet weak var activeRequestsAmountLabel: UILabel!
    @IBOutlet weak var activeRequestsCollectionView: UICollectionView!
    @IBOutlet weak var activeRequestsCollectionViewFL: UPCarouselFlowLayout!
    @IBOutlet weak var selectedRequestAmountLabel: UILabel!
    @IBOutlet weak var selectedRequestAddressLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var recentImageView: UIImageView!
    @IBOutlet weak var animationHolderView: UIView!
    @IBOutlet weak var navigationButtonsHolderBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationButtonsHolderView: UIView!
    
    @IBOutlet weak var walletsClonesHolderView: UIView!
    @IBOutlet weak var leftWalletsClonesHolderView: UIView!
    @IBOutlet weak var rightWalletsClonesHolderView: UIView!
    @IBOutlet weak var leftWalletsClonesLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightWalletsClonesTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftWalletsClonesWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightWalletsClonesWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activeRequestsClonesHolderView: UIView!
    @IBOutlet weak var leftActiveRequestsClonesHolderView: UIView!
    @IBOutlet weak var rightActiveRequestsClonesHolderView: UIView!
    @IBOutlet weak var leftActiveRequestsClonesLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightActiveRequestsClonesTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftActiveRequestsClonesWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightActiveRequestsClonesWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bluetoothDisabledContentView: UIView!
    @IBOutlet weak var bluetoothEnabledContentView: UIView!
    @IBOutlet weak var activeRequestsAmountTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bluetoothErrorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bluetoothEnabledContentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchingActiveRequestsLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var sendTipLabel: UILabel!
    @IBOutlet weak var sendTipView: UIView!
    
    var txInfoView: TxInfoView?
    var txTokenImageView: UIImageView?
    var selectedRequestAmountCloneLabel: UILabel?
    var selectedRequestAddressCloneLabel: UILabel?
    
    var searchingAnimationView : LOTAnimationView?
    var sendLongPressGR : UILongPressGestureRecognizer?
    var sendSwipeGR : UISwipeGestureRecognizer?
    
    let presenter = SendPresenter()
    
    private var indexOfWalletsCellBeforeDragging = 0
    private var indexOfActiveRequestsCellBeforeDragging = 0
    
    var swipePrevLocation : CGPoint?
    
    var sendMode = SendMode.searching
    let ANIMATION_DURATION = 0.2
    let activeRequestCloneViewTag = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        fixUIForX()
        
        walletsCollectionViewFL.minimumLineSpacing = 0
        activeRequestsCollectionViewFL.spacingMode = .fixed(spacing: 0)
        
        qrCodeImageView.image = qrCodeImageView.image!.withRenderingMode(.alwaysTemplate)
        qrCodeImageView.tintColor = .white
        recentImageView.image = recentImageView.image!.withRenderingMode(.alwaysTemplate)
        recentImageView.tintColor = .white
        
        sendLongPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPress:)))
        sendLongPressGR!.delegate = self
        walletsCollectionView.addGestureRecognizer(sendLongPressGR!)
        
        presenter.sendVC = self
        presenter.viewControllerViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewControllerViewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize(collectionView: activeRequestsCollectionView)
        configureCollectionViewLayoutItemSize(collectionView: walletsCollectionView)
        
        refreshBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewControllerViewWillDisappear()
    }
    
    func registerCells() {
        let walletCollectionCell = UINib.init(nibName: "WalletCollectionViewCell", bundle: nil)
        walletsCollectionView.register(walletCollectionCell, forCellWithReuseIdentifier: "WalletCollectionViewCell")
        let activeRequestCollectionCell = UINib.init(nibName: "ActiveRequestCollectionViewCell", bundle: nil)
        activeRequestsCollectionView.register(activeRequestCollectionCell, forCellWithReuseIdentifier: "ActiveRequestCollectionViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.isHidden = true
        if searchingAnimationView == nil {
            searchingAnimationView = LOTAnimationView(name: "circle_grow")
            searchingAnimationView!.frame = searchingRequestsHolderView.bounds
            searchingRequestsHolderView.autoresizesSubviews = true
            searchingRequestsHolderView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.searchingRequestsHolderView.insertSubview(searchingAnimationView!, at: 0)
            searchingAnimationView!.transform = CGAffineTransform(scaleX: 3.5, y: 3.5)
            
            searchingAnimationView!.loopAnimation = true
            searchingAnimationView!.play()
        }
    }
    
    func refreshBackground() {
        if bluetoothDisabledContentView.isHidden {
            backgroundView.applyOrUpdateGradient(withColours: [
                UIColor(ciColor: CIColor(red: 29.0 / 255.0, green: 176.0 / 255.0, blue: 252.0 / 255.0)),
                UIColor(ciColor: CIColor(red: 21.0 / 255.0, green: 126.0 / 255.0, blue: 252.0 / 255.0))],
                               gradientOrientation: .topRightBottomLeft)
        } else {
            backgroundView.applyOrUpdateGradient(withColours: [
                UIColor(ciColor: CIColor(red: 23.0 / 255.0, green: 30.0 / 255.0, blue: 38.0 / 255.0)),
                UIColor(ciColor: CIColor(red: 67.0 / 255.0, green: 74.0 / 255.0, blue: 78.0 / 255.0))],
                               gradientOrientation: .vertical)
        }
    }
    
    func updateUI() {
        if sendMode != .inSend {
            activeRequestsAmountLabel.text = "\(localize(string: Constants.activeRequestsString)) \(presenter.numberOfActiveRequests())"
            if sendMode == .searching {
                walletsCollectionView.reloadData()
                activeRequestsCollectionView.reloadData()
            }
            
            updateUIForActiveRequestInfo()
            self.foundActiveRequestsHolderView.alpha = 1.0
            
            if presenter.numberOfActiveRequests() > 0 {
                selectedRequestAmountLabel.isHidden = false
                selectedRequestAddressLabel.isHidden = false
                searchingActiveRequestsLabel.isHidden =  true

                
            } else {
                selectedRequestAmountLabel.isHidden = true
                selectedRequestAddressLabel.isHidden = true
                searchingActiveRequestsLabel.isHidden =  false
            }
            
            if searchingAnimationView != nil && !searchingAnimationView!.isAnimationPlaying {
                searchingAnimationView?.play()
            }
            
            if sendMode != .prepareSending {
                if presenter.selectedWalletIndex != nil && presenter.selectedActiveRequestIndex != nil {
                    sendTipView.isHidden = false
                    sendTipLabel.text = localize(string: Constants.sendTipString)
                } else {
                    sendTipView.isHidden = true
                }
            }
        }
    }
    
    func fixUIForX() {
        if screenHeight == heightOfX {
            activeRequestsAmountTopConstraint.constant = activeRequestsAmountTopConstraint.constant + 20
            self.view.layoutIfNeeded()
        }
    }
    
    func updateUIForBluetoothState(_ isEnable : Bool) {
        bluetoothDisabledContentView.isHidden = isEnable
        bluetoothEnabledContentView.isHidden = !isEnable
        activeRequestsAmountLabel.isHidden = !isEnable
        
        refreshBackground()
    }
    
    private func calculateSectionInset(collectionView : UICollectionView) -> CGFloat {
        var result : CGFloat = 0
        
        if collectionView == activeRequestsCollectionView {
            let cellBodyWidth: CGFloat = 170
            result = (activeRequestsCollectionView.frame.width - cellBodyWidth) / 2.0
        } else {
            if sendMode == .searching {
                let cellBodyWidth: CGFloat = 242
                result = (walletsCollectionView.frame.width - cellBodyWidth) / 2
            } else {
                result = 0
            }
        }
        
        return result
    }
    
    private func configureCollectionViewLayoutItemSize(collectionView : UICollectionView) {
        if sendMode == .searching {
            if collectionView == activeRequestsCollectionView {
                let inset: CGFloat = calculateSectionInset(collectionView: collectionView)
                activeRequestsCollectionViewFL.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                
                activeRequestsCollectionViewFL.itemSize = CGSize(width: walletsCollectionViewFL.collectionView!.frame.size.width - inset * 2, height: activeRequestsCollectionViewFL.collectionView!.frame.size.height)
            } else {
                let inset: CGFloat = calculateSectionInset(collectionView: collectionView)
                walletsCollectionViewFL.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                
                walletsCollectionViewFL.itemSize = CGSize(width: walletsCollectionViewFL.collectionView!.frame.size.width - inset * 2, height: walletsCollectionViewFL.collectionView!.frame.size.height)
            }
        }
    }
    
    private func indexOfMajorCell(collectionView : UICollectionView) -> Int {
        if collectionView == walletsCollectionView {
            let itemWidth = walletsCollectionViewFL.itemSize.width
            let proportionalOffset = walletsCollectionView.contentOffset.x / itemWidth
            return Int(round(proportionalOffset))
        } else {
            let itemWidth = activeRequestsCollectionViewFL.itemSize.width
            let proportionalOffset = activeRequestsCollectionView.contentOffset.x / itemWidth
            return Int(round(proportionalOffset))
        }
    }
    
    fileprivate var requestPageSize: CGSize {
        let layout = self.activeRequestsCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        pageSize.width += layout.minimumLineSpacing
        return pageSize
    }
    
    func prepareForSending() {
        if presenter.isSendingAvailable {
            sendMode = .prepareSending
            var navigationButtonsBottomConstant = -navigationButtonsHolderView.frame.size.height
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                let bottomPadding = window!.safeAreaInsets.bottom
                navigationButtonsBottomConstant -= bottomPadding
            }
            
            prepareTxInfo()
            prepareClonesViews()
            bluetoothEnabledContentView.isHidden = true
            
            // Set constraints for hiding active requests amount
            activeRequestsAmountTopConstraint.constant = -60
            
            // Set constraints for hiding navigation buttons
            navigationButtonsHolderBottomConstraint.constant = navigationButtonsBottomConstant
            
            // Set constraints for hiding wallets
            leftWalletsClonesLeadingConstraint.constant = -leftWalletsClonesWidthConstraint.constant
            rightWalletsClonesTrailingConstraint.constant = -rightWalletsClonesWidthConstraint.constant
            
            // Set constraints for hiding requests
            leftActiveRequestsClonesLeadingConstraint.constant = -leftActiveRequestsClonesWidthConstraint.constant
            rightActiveRequestsClonesTrailingConstraint.constant = -rightActiveRequestsClonesWidthConstraint.constant
            self.activeRequestsClonesHolderView.layoutIfNeeded()
            
            UIView.animate(withDuration: ANIMATION_DURATION) {
                self.showTxInfo()
                self.animationHolderView.layoutIfNeeded()
            }
        }
    }
    
    
    func backUIToSearching(_ completion : (() -> Swift.Void)? = nil) {
        // Set constraints for presenting active requests amount
        if screenHeight == heightOfX {
            activeRequestsAmountTopConstraint.constant = 55
        } else {
            activeRequestsAmountTopConstraint.constant = 35
        }
        
        // Set constraints for presenting navigation buttons
        navigationButtonsHolderBottomConstraint.constant = 0
        
        // Set constraints for presenting requests
        leftActiveRequestsClonesLeadingConstraint.constant = 0
        rightActiveRequestsClonesTrailingConstraint.constant = 0
        
        // Set constraints for presenting wallets
        leftWalletsClonesLeadingConstraint.constant = 0
        rightWalletsClonesTrailingConstraint.constant = 0

        
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.hideTxInfo()
            self.animationHolderView.layoutIfNeeded()
        }) { (succeeded) in
            self.bluetoothEnabledContentView.isHidden = false
            self.removeClonesViews()
            self.dismissTxInfo()
            self.sendMode = .searching
            
            if completion != nil {
                completion!()
            }
            self.presenter.cancelPrepareSending()
        }
    }
    
    func send() {
        sendMode = .inSend
        absorbTxInfo()
        presenter.send()
    }
    
    func presentSendingErrorAlert() {
        let alert = UIAlertController(title: localize(string: Constants.transactionErrorString), message: localize(string: Constants.errorSendingTxString), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func updateUIForActiveRequestInfo() {
        if sendMode != .inSend {
            if presenter.numberOfActiveRequests() > 0 {
                
                let selectedRequest = presenter.activeRequestsArr[presenter.selectedActiveRequestIndex!]
                selectedRequestAmountLabel.isHidden = false
                selectedRequestAddressLabel.isHidden = false
                let blockchainType = BlockchainType.create(currencyID: UInt32(selectedRequest.currencyID), netType: 0)
                selectedRequestAmountLabel.text = "\(selectedRequest.sendAmount) \(blockchainType.shortName)"
                selectedRequestAddressLabel.text = selectedRequest.sendAddress
            }
        }
    }
    
    func updateUIWithSendResponse(success : Bool) {
        if sendMode == .inSend {
            if success {
                let doneAnimationView = LOTAnimationView(name: "tx_success_animation")
                doneAnimationView.frame = CGRect(x: (self.activeRequestsCollectionView.center.x - 101), y: self.foundActiveRequestsHolderView.frame.origin.y + self.activeRequestsCollectionView.frame.origin.y - 20, width: 202, height: 202)
                doneAnimationView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                
                self.view.addSubview(doneAnimationView)
                doneAnimationView.play{[unowned self] (finished) in
                    UIView.animate(withDuration: 0.6, animations: {
                        doneAnimationView.transform = CGAffineTransform(scaleX: 10.0, y: 10.0)
                        doneAnimationView.alpha = 0.0
                    }) { (succeeded) in

                        doneAnimationView.removeFromSuperview()
                        self.close()
                        self.backUIToSearching(nil)
                    }
                }
            } else {
                backUIToSearching({[unowned self] in
                    self.presenter.sendAnimationComplete()})

                presentSendingErrorAlert()
            }
        }
    }
    
    func prepareTxInfo() {
        let blockchainType = BlockchainType.create(wallet: presenter.transaction!.choosenWallet!)
        let exchangeCourse = DataManager.shared.makeExchangeFor(blockchainType: blockchainType)
        
        let sumInCrypto = "\(presenter.transaction!.sendAmount!.fixedFraction(digits: 8)) \(blockchainType.shortName)"
        let sumInFiat = "\((presenter.transaction!.sendAmount! * exchangeCourse).fixedFraction(digits: 2)) $"
        
        let txTokenImageSide : CGFloat = 40
        txTokenImageView = UIImageView(frame: CGRect(x: (walletsClonesHolderView.center.x - txTokenImageSide/2), y: (walletsClonesHolderView.frame.origin.y + walletsClonesHolderView.frame.size.height - txTokenImageSide), width: txTokenImageSide, height: txTokenImageSide))
        txTokenImageView!.image = UIImage(named: blockchainType.iconString)
        txTokenImageView!.alpha = 0
        let walletsClonesHolderViewIndex = animationHolderView.subviews.index(of: walletsClonesHolderView)
        animationHolderView.insertSubview(txTokenImageView!, at: walletsClonesHolderViewIndex! - 1)
        
        let txInfoViewWidth : CGFloat = 150
        let txInfoViewHeight : CGFloat = 62
        txInfoView = TxInfoView(frame: CGRect(x: (walletsClonesHolderView.center.x - txInfoViewWidth/2), y: (txTokenImageView!.frame.origin.y - 5 - txInfoViewHeight), width: txInfoViewWidth, height: txInfoViewHeight), sumInCryptoString: sumInCrypto, sumInFiatString: sumInFiat)
        txInfoView!.alpha = 0
        animationHolderView.insertSubview(txInfoView!, at: walletsClonesHolderViewIndex! + 1)
    }
    
    func showTxInfo() {
        self.txTokenImageView!.center.y = self.walletsClonesHolderView.frame.origin.y + 6
        self.txInfoView!.frame.origin.y = self.txTokenImageView!.frame.origin.y - 5 - self.txInfoView!.frame.size.height
        self.txInfoView!.alpha = 1
        self.txTokenImageView!.alpha = 1
    }
    
    func absorbTxInfo() {
        let activeRequestView = activeRequestsClonesHolderView.subviews.filter{ $0.tag == activeRequestCloneViewTag}.first
        if activeRequestView != nil {
            let centerActiveRequestView = activeRequestsClonesHolderView.convert(activeRequestView!.center, to: animationHolderView)
            UIView.animate(withDuration: 0.15, animations: {
                self.selectedRequestAmountCloneLabel!.alpha = 0
                self.selectedRequestAddressCloneLabel!.alpha = 0
                self.txTokenImageView!.frame = CGRect(x: centerActiveRequestView.x, y: centerActiveRequestView.y, width: 0, height: 0)
                self.txInfoView!.frame = CGRect(x: self.txTokenImageView!.center.x, y: (self.txTokenImageView!.frame.origin.y - 5 - self.txInfoView!.frame.size.height), width: 0, height: 0)
                 self.txTokenImageView!.alpha = 0
                self.txInfoView!.alpha = 0
                
            }) { succeeded in
                UIView.animate(withDuration: 0.15, animations: {
                    activeRequestView?.transform = CGAffineTransform(scaleX: 0, y: 0)
                })
            }
        }
    }
    
    func hideTxInfo() {
        txTokenImageView!.center = CGPoint(x: walletsClonesHolderView.center.x, y: (walletsClonesHolderView.frame.origin.y + walletsClonesHolderView.frame.size.height - txTokenImageView!.frame.size.height/2))
        txTokenImageView!.alpha = 0
        
        txInfoView!.frame = CGRect(x: (walletsClonesHolderView.center.x - txInfoView!.frame.size.width/2), y: (txTokenImageView!.frame.origin.y - 5 - txInfoView!.frame.size.height), width: txInfoView!.frame.size.width, height: txInfoView!.frame.size.height)
        txInfoView!.alpha = 0
    }
    
    func dismissTxInfo() {
        txInfoView!.removeFromSuperview()
        txInfoView = nil
        
        txTokenImageView!.removeFromSuperview()
        txTokenImageView = nil
    }

    func prepareClonesViews() {
        selectedRequestAmountCloneLabel = UILabel(frame: selectedRequestAmountLabel.frame)
        selectedRequestAmountCloneLabel!.font = selectedRequestAmountLabel.font
        selectedRequestAmountCloneLabel!.textColor = selectedRequestAmountLabel.textColor
        selectedRequestAmountCloneLabel!.adjustsFontSizeToFitWidth = true
        selectedRequestAmountCloneLabel!.minimumScaleFactor = selectedRequestAmountLabel.minimumScaleFactor
        selectedRequestAmountCloneLabel!.textAlignment = .center
        selectedRequestAmountCloneLabel!.text = selectedRequestAmountLabel.text
        
        selectedRequestAddressCloneLabel = UILabel(frame: selectedRequestAddressLabel.frame)
        selectedRequestAddressCloneLabel!.font = selectedRequestAddressLabel.font
        selectedRequestAddressCloneLabel!.textColor = selectedRequestAddressLabel.textColor
        selectedRequestAddressCloneLabel!.adjustsFontSizeToFitWidth = true
        selectedRequestAddressCloneLabel!.minimumScaleFactor = selectedRequestAddressLabel.minimumScaleFactor
        selectedRequestAddressCloneLabel!.textAlignment = .center
        selectedRequestAddressCloneLabel!.text = selectedRequestAddressLabel.text
        
        activeRequestsClonesHolderView.addSubview(selectedRequestAmountCloneLabel!)
        activeRequestsClonesHolderView.addSubview(selectedRequestAddressCloneLabel!)
        
        prepareWalletsCellsClones()
        prepareActiveRequestsCellsClones()
    }
    
    func removeClonesViews() {
        selectedRequestAmountCloneLabel!.removeFromSuperview()
        selectedRequestAmountCloneLabel = nil
        selectedRequestAddressCloneLabel!.removeFromSuperview()
        selectedRequestAddressCloneLabel = nil
        
        removeWalletsCellsClones()
        removeActiveRequestsCellsClones()
    }
    
    func prepareWalletsCellsClones() {
        walletsClonesHolderView.isHidden = false
        leftWalletsClonesWidthConstraint.constant = walletsCollectionViewFL.sectionInset.left
        rightWalletsClonesWidthConstraint.constant = leftWalletsClonesWidthConstraint.constant
        walletsClonesHolderView.layoutIfNeeded()
        
        let visibleCells = walletsCollectionView.visibleCells as! [WalletCollectionViewCell]
        for cell in visibleCells {
            let cellClone = cloneWalletCell(cell)
            
            let walletIndex = presenter.filteredWalletArray.index(of: cell.wallet!)
            if walletIndex != nil {
                if walletIndex! < presenter.selectedWalletIndex! {
                    cellClone.frame = walletsCollectionView.convert(cell.frame, to: leftWalletsClonesHolderView!)
                    leftWalletsClonesHolderView.addSubview(cellClone)
                } else if walletIndex! > presenter.selectedWalletIndex! {
                    cellClone.frame = walletsCollectionView.convert(cell.frame, to: rightWalletsClonesHolderView!)
                    rightWalletsClonesHolderView.addSubview(cellClone)
                } else {
                    cellClone.frame = walletsCollectionView.convert(cell.frame, to: walletsClonesHolderView!)
                    walletsClonesHolderView.addSubview(cellClone)
                }
            }
        }
        walletsClonesHolderView.layoutIfNeeded()
    }
    
    func prepareActiveRequestsCellsClones() {
        activeRequestsClonesHolderView.isHidden = false
        leftActiveRequestsClonesWidthConstraint.constant = activeRequestsCollectionView.frame.size.width
        rightActiveRequestsClonesWidthConstraint.constant = leftActiveRequestsClonesWidthConstraint.constant
        activeRequestsClonesHolderView.layoutIfNeeded()
        
        let visibleCells = activeRequestsCollectionView.visibleCells as! [ActiveRequestCollectionViewCell]
        for cell in visibleCells {
            let cellClone = cloneActiveRequestCell(cell)
            
            let requestIndex = presenter.indexForActiveRequst(cellClone.request!)
            if requestIndex != nil {
                if requestIndex! < presenter.selectedActiveRequestIndex! {
//                    let cellFrame = activeRequestsCollectionView.convert(cell.frame, to: leftActiveRequestsClonesHolderView!)
//                    cellClone.frame = cellFrame
//                    leftActiveRequestsClonesHolderView.addSubview(cellClone)
                } else if requestIndex! > presenter.selectedActiveRequestIndex! {
//                    let cellFrame = activeRequestsCollectionView.convert(cell.frame, to: rightActiveRequestsClonesHolderView!)
//                    cellClone.frame = cellFrame
//                    rightActiveRequestsClonesHolderView.addSubview(cellClone)
                } else {
                    let cellFrame = activeRequestsCollectionView.convert(cell.frame, to: activeRequestsClonesHolderView!)
                    cellClone.frame = cellFrame
                    cellClone.tag = activeRequestCloneViewTag
                    activeRequestsClonesHolderView.addSubview(cellClone)
                }
            }
        }
        activeRequestsClonesHolderView.layoutIfNeeded()
    }
    
    func removeWalletsCellsClones() {
        for view in walletsClonesHolderView.subviews {
            if view.isKind(of: WalletCollectionViewCell.self) {
                view.removeFromSuperview()
            } else if view == rightWalletsClonesHolderView || view == leftWalletsClonesHolderView {
                for subview in view.subviews {
                    if subview.isKind(of: WalletCollectionViewCell.self) {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func removeActiveRequestsCellsClones() {
        for view in activeRequestsClonesHolderView.subviews {
            if view.isKind(of: ActiveRequestCollectionViewCell.self) {
                view.removeFromSuperview()
            } else if view == rightActiveRequestsClonesHolderView || view == leftActiveRequestsClonesHolderView {
                for subview in view.subviews {
                    if subview.isKind(of: ActiveRequestCollectionViewCell.self) {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }

    func cloneWalletCell(_ cell: WalletCollectionViewCell) -> WalletCollectionViewCell {
        let cellClone = UINib(nibName: "WalletCollectionViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WalletCollectionViewCell
        cellClone.wallet = cell.wallet
        cellClone.fillInCell()


        return cellClone
    }
    
    func cloneActiveRequestCell(_ cell: ActiveRequestCollectionViewCell) -> ActiveRequestCollectionViewCell {
        let cellClone = UINib(nibName: "ActiveRequestCollectionViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ActiveRequestCollectionViewCell
        cellClone.request = cell.request
        cellClone.fillInCell()
        cellClone.alpha = cell.alpha
        
        return cellClone
    }


    @objc func close() {
        guard let nc = self.navigationController else {
            return self.dismiss(animated: false, completion: nil)
        }
        
        nc.popToRootViewController(animated: true)
        if let tbc = self.tabBarController as? CustomTabBarViewController {
            tbc.setSelectIndex(from: 2, to: tbc.previousSelectedIndex)
        }
    }
    
    //MARK: Actions
    @IBAction func qrCodeAction(_ sender: Any) {
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        close()
    }
    
    @IBAction func recentAction(_ sender: Any) {
        
    }
    
    @IBAction func enableBluetoothAction(_ sender: Any) {
        presentGoToBluetoothSettingsAlert()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "qrCamera"?:
            let qrScanerVC = segue.destination as! QrScannerViewController
            qrScanerVC.qrDelegate = presenter
        default:
            break
        }
    }
}

extension SendViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == activeRequestsCollectionView {
            return presenter.numberOfActiveRequests()
        } else {
            return presenter.numberOfWallets()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == activeRequestsCollectionView {
            let cell = activeRequestsCollectionView.dequeueReusableCell(withReuseIdentifier: "ActiveRequestCollectionViewCell", for: indexPath) as! ActiveRequestCollectionViewCell
            
            let request = presenter.activeRequestsArr[indexPath.item]
            cell.request = request
                        
            return cell
        } else {
            let cell = walletsCollectionView.dequeueReusableCell(withReuseIdentifier: "WalletCollectionViewCell", for: indexPath) as! WalletCollectionViewCell
            
            let wallet = presenter.filteredWalletArray[indexPath.item]
            cell.wallet = wallet
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == activeRequestsCollectionView {
            let cell = cell as! ActiveRequestCollectionViewCell
            cell.fillInCell()
        } else {
            let cell = cell as! WalletCollectionViewCell
            cell.fillInCell()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == walletsCollectionView {
            indexOfWalletsCellBeforeDragging = indexOfMajorCell(collectionView: walletsCollectionView)
        } else {
            indexOfActiveRequestsCellBeforeDragging = indexOfMajorCell(collectionView: activeRequestsCollectionView)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let collectionView = scrollView == activeRequestsCollectionView ? activeRequestsCollectionView : walletsCollectionView
        let collectionViewFL = scrollView == activeRequestsCollectionView ? activeRequestsCollectionViewFL : walletsCollectionViewFL
        let indexOfCellBeforeDragging = scrollView == activeRequestsCollectionView ? indexOfActiveRequestsCellBeforeDragging : indexOfWalletsCellBeforeDragging
        let numberOfCells = scrollView == activeRequestsCollectionView ? presenter.numberOfActiveRequests() : presenter.numberOfWallets()
        
        if collectionView == walletsCollectionView {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // Calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell(collectionView: collectionView!)
        
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < numberOfCells && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        var selectedCellIndex = indexOfCellBeforeDragging
        
        
            if didUseSwipeToSkipCell {
                let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
                selectedCellIndex = snapToIndex
                let toValue = collectionViewFL!.itemSize.width * CGFloat(snapToIndex)
                // Damping equal 1 => no oscillations => decay animation:
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                }, completion: nil)
            } else {
                selectedCellIndex = indexOfMajorCell
                let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }

            presenter.selectedWalletIndex = selectedCellIndex
        }
    }
    
    func scrollToWallet(_ index : Int) {
        let indexPath = IndexPath(row: index, section: 0)
        walletsCollectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollToRequest(_ index : Int) {
        let indexPath = IndexPath(row: index, section: 0)
        activeRequestsCollectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == activeRequestsCollectionView {
            let width = self.requestPageSize.width
            let offset = scrollView.contentOffset.x
            presenter.selectedActiveRequestIndex = Int(floor((offset - width / 2) / width) + 1)
        }
    }
}

extension SendViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        var result = false
        if (gestureRecognizer == sendLongPressGR && otherGestureRecognizer == sendSwipeGR) || (gestureRecognizer == sendSwipeGR && otherGestureRecognizer == sendLongPressGR) {
            result = true
        }
        
        return result
    }
    
    @objc func handleLongPress(longPress: UILongPressGestureRecognizer) {
        let location = longPress.location(in: walletsCollectionView)
        switch longPress.state {
        case .began:
            if let indexPath = walletsCollectionView.indexPathForItem(at: location) {
                if indexPath.item == presenter.selectedWalletIndex! {
                    swipePrevLocation = location
                    prepareForSending()
                }
            }
        case .changed:
            if sendMode == .prepareSending {
                let deltaX = location.x - swipePrevLocation!.x
                let deltaY = location.y - swipePrevLocation!.y
                swipePrevLocation = location
                let newTxInfoViewCenter = CGPoint(x: txInfoView!.center.x + deltaX, y: txInfoView!.center.y + deltaY)
                let newTxTokenImageViewCenter = CGPoint(x: txTokenImageView!.center.x + deltaX, y: txTokenImageView!.center.y + deltaY)
                txInfoView!.center = newTxInfoViewCenter
                txTokenImageView!.center = newTxTokenImageViewCenter
                
                let activeRequestView = activeRequestsClonesHolderView.subviews.filter{ $0.tag == activeRequestCloneViewTag}.first as? ActiveRequestCollectionViewCell
                if activeRequestView != nil  {
                    if isReadyForSend() {
                        activeRequestView!.satisfiedImage.isHidden = false
                        activeRequestView!.requestImage.layer.borderWidth = 10
                        let borderColor = #colorLiteral(red: 0.4666666667, green: 0.7647058824, blue: 0.2666666667, alpha: 1).withAlphaComponent(0.8)
                        activeRequestView!.requestImage.layer.borderColor = borderColor.cgColor
                    } else {
                        activeRequestView!.requestImage.layer.borderWidth = 0
                        activeRequestView!.satisfiedImage.isHidden = true
                    }
                }
                
//                if swipePrevLocation!.y - location.y > 5 && timeInterval - swipePrevLocationTimeInterval! < 0.05 {
//                    send()
//                    swipePrevLocation = nil
//                    swipePrevLocationTimeInterval = nil
//                } else {
//                    swipePrevLocation = location
//                    swipePrevLocationTimeInterval = timeInterval
//                }
            }
        case .ended, .failed, .cancelled:
            if sendMode == .prepareSending {
                swipePrevLocation = nil
                
                if longPress.state == .ended {
                    if isReadyForSend() {
                        send()
                    } else {
                        backUIToSearching(nil)
                    }
                } else {
                    backUIToSearching(nil)
                }
            }
            
        default:
            break
        }
    }
    
    func isReadyForSend() -> Bool {
        var result = false
        let activeRequestView = activeRequestsClonesHolderView.subviews.filter{ $0.tag == activeRequestCloneViewTag}.first
        if activeRequestView != nil {
            let frame = activeRequestsClonesHolderView.convert(activeRequestView!.frame, to: animationHolderView)
            if frame.contains(txTokenImageView!.center) {
                result = true
            }
        }
        
        return result
    }
}


extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
