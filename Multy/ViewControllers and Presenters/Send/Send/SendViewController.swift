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
    @IBOutlet weak var transactionHolderView: UIView!
    @IBOutlet weak var transactionSumInFiatLbl: UILabel!
    @IBOutlet weak var transactionSumInCryptoLbl: UILabel!
    @IBOutlet weak var transactionHolderViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationButtonsHolderBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationButtonsHolderView: UIView!
    @IBOutlet weak var transactionTokenImageView: UIImageView!
    @IBOutlet weak var transactionInfoView: UIView!
    @IBOutlet weak var transactionInfoViewBottomConstraint: NSLayoutConstraint!
    
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
    
    var searchingAnimationView : LOTAnimationView?
    var sendLongPressGR : UILongPressGestureRecognizer?
    var sendSwipeGR : UISwipeGestureRecognizer?
    
    let presenter = SendPresenter()
    
    private var indexOfWalletsCellBeforeDragging = 0
    private var indexOfActiveRequestsCellBeforeDragging = 0
    
    var swipePrevLocationTimeInterval : TimeInterval?
    var swipePrevLocation : CGPoint?
    
    var sendMode = SendMode.searching
    let ANIMATION_DURATION = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.sendVC = self
        
        registerCells()
        if presenter.numberOfWallets() == 0 {
            presenter.getWallets()
        }
        
        
        walletsCollectionViewFL.minimumLineSpacing = 0
        activeRequestsCollectionViewFL.spacingMode = .fixed(spacing: 0)
        
        qrCodeImageView.image = qrCodeImageView.image!.withRenderingMode(.alwaysTemplate)
        qrCodeImageView.tintColor = .white
        recentImageView.image = recentImageView.image!.withRenderingMode(.alwaysTemplate)
        recentImageView.tintColor = .white
        
        presenter.viewControllerViewDidLoad()
        
        sendLongPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPress:)))
        sendLongPressGR!.delegate = self
        walletsCollectionView.addGestureRecognizer(sendLongPressGR!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize(collectionView: activeRequestsCollectionView)
        configureCollectionViewLayoutItemSize(collectionView: walletsCollectionView)
    }
    
    func registerCells() {
        let walletCollectionCell = UINib.init(nibName: "WalletCollectionViewCell", bundle: nil)
        walletsCollectionView.register(walletCollectionCell, forCellWithReuseIdentifier: "WalletCollectionViewCell")
        let activeRequestCollectionCell = UINib.init(nibName: "ActiveRequestCollectionViewCell", bundle: nil)
        activeRequestsCollectionView.register(activeRequestCollectionCell, forCellWithReuseIdentifier: "ActiveRequestCollectionViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if searchingAnimationView == nil {
            searchingAnimationView = LOTAnimationView(name: "circle_grow")
            searchingAnimationView!.frame = searchingRequestsHolderView.bounds
            searchingRequestsHolderView.autoresizesSubviews = true
            searchingRequestsHolderView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.searchingRequestsHolderView.insertSubview(searchingAnimationView!, at: 0)
            searchingAnimationView!.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            searchingAnimationView!.loopAnimation = true
            searchingAnimationView!.play()
        }
    }
    
    func updateUI() {
        activeRequestsAmountLabel.text = "Active Requests \(presenter.numberOfActiveRequests())"
        if sendMode == .searching {
            walletsCollectionView.reloadData()
            activeRequestsCollectionView.reloadData()
        }
        
        if presenter.numberOfActiveRequests() > 0 {
            searchingRequestsHolderView.isHidden = true
            foundActiveRequestsHolderView.isHidden = false
            
            let selectedRequest = presenter.activeRequestsArr[presenter.selectedActiveRequestIndex!]
            let blockchainType = BlockchainType.create(currencyID: selectedRequest.currencyID.uint32Value, netType: 0)
            selectedRequestAmountLabel.text = "\(selectedRequest.sendAmount.fixedFraction(digits: 8)) \(blockchainType.shortName)"
            selectedRequestAddressLabel.text = selectedRequest.sendAddress
        } else {
            searchingRequestsHolderView.isHidden = false
            foundActiveRequestsHolderView.isHidden = true
        }
    }
    
    func updateUIForBluetoothState(_ isEnable : Bool) {
        bluetoothDisabledContentView.isHidden = isEnable
        bluetoothEnabledContentView.isHidden = !isEnable
    }
    
    func fillTransaction() {
        let blockchainType = BlockchainType.create(wallet: presenter.transaction!.choosenWallet!)
        transactionSumInCryptoLbl.text = "\(presenter.transaction!.sendAmount!.fixedFraction(digits: 8)) \(blockchainType.shortName)"
        transactionSumInFiatLbl.text = "\((presenter.transaction!.sendAmount! * 8200.0).fixedFraction(digits: 0)) $" //TODO: set true sum
        transactionTokenImageView.image = UIImage(named: blockchainType.iconString)
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
            navigationButtonsHolderBottomConstraint.constant = navigationButtonsBottomConstant
            transactionHolderViewBottomConstraint.constant = self.view.bounds.size.height - walletsCollectionView.frame.origin.y - 6 - 20
            transactionHolderView.alpha = 0.0
            transactionHolderView.isHidden = false
            
            hideNotSelectedWallets()
            hideNotSelectedRequests()
            UIView.animate(withDuration: ANIMATION_DURATION) {
                self.transactionHolderView.alpha = 1.0
                self.animationHolderView.layoutIfNeeded()
            }
        }
    }
    
    func cancelSending() {
        sendMode = .searching
        navigationButtonsHolderBottomConstraint.constant = 0
        transactionHolderViewBottomConstraint.constant = self.view.bounds.size.height - walletsCollectionView.frame.origin.y - walletsCollectionView.frame.size.height
        
        showNotSelectedWallets()
        showNotSelectedRequests()
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.animationHolderView.layoutIfNeeded()
            self.transactionHolderView.alpha = 0.0
        }) { (succeeded) in
            if succeeded {
                self.transactionHolderView.isHidden = true
            }
        }
    }
    
    func send() {
        sendMode = .inSend
        transactionHolderViewBottomConstraint.constant = self.view.bounds.size.height - walletsCollectionView.frame.origin.y - walletsCollectionView.frame.size.height
        transactionInfoViewBottomConstraint.constant = animationHolderView.frame.size.height - activeRequestsCollectionView.frame.origin.y - activeRequestsCollectionView.center.y - transactionInfoView.frame.size.height/2 - transactionTokenImageView.frame.size.height - transactionHolderViewBottomConstraint.constant
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.animationHolderView.layoutIfNeeded()
            self.transactionInfoView.alpha = 0
            self.transactionTokenImageView.alpha = 0
        }) { (succeeded) in
            if succeeded {
                UIView.animate(withDuration: self.ANIMATION_DURATION, animations: {
                    self.activeRequestsCollectionView.alpha = 0
                })
                let doneAnimationView = LOTAnimationView(name: "Check Mark Success Data")
                doneAnimationView.frame = CGRect(x: (self.activeRequestsCollectionView.center.x - 101), y: self.activeRequestsCollectionView.frame.origin.y - 20, width: 202, height: 202)
                self.foundActiveRequestsHolderView.addSubview(doneAnimationView)
                doneAnimationView.play{ (finished) in
                    self.transactionHolderView.isHidden = true
                    self.transactionInfoViewBottomConstraint.constant = 5
                    self.transactionInfoView.alpha = 1
                    self.transactionTokenImageView.alpha = 1
                    
                    self.sendMode = .searching
                    self.navigationButtonsHolderBottomConstraint.constant = 0
                    self.transactionHolderViewBottomConstraint.constant = self.view.bounds.size.height - self.walletsCollectionView.frame.origin.y - self.walletsCollectionView.frame.size.height
                    
                    
                    self.showNotSelectedWallets()
                    self.showNotSelectedRequests()
                    UIView.animate(withDuration: self.ANIMATION_DURATION, animations: {
                        self.animationHolderView.layoutIfNeeded()
                        self.transactionHolderView.alpha = 0.0
                        self.activeRequestsCollectionView.alpha = 1
                    }) { (succeeded) in
                        if succeeded {
                            self.transactionHolderView.isHidden = true
                        }
                    }
                    doneAnimationView.removeFromSuperview()
                }
            }
        }
    }
    
    func hideNotSelectedWallets() {
        prepareWalletsCellsClones()
        walletsCollectionView.isHidden = true
        leftWalletsClonesLeadingConstraint.constant = -leftWalletsClonesWidthConstraint.constant
        rightWalletsClonesTrailingConstraint.constant = -rightWalletsClonesWidthConstraint.constant
        UIView.animate(withDuration: ANIMATION_DURATION) {
            self.walletsClonesHolderView.layoutIfNeeded()
        }
    }
    
    func showNotSelectedWallets() {
        leftWalletsClonesLeadingConstraint.constant = 0
        rightWalletsClonesTrailingConstraint.constant = 0
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.walletsClonesHolderView.layoutIfNeeded()
        }) { (succeeded) in
            if succeeded {
                self.walletsCollectionView.isHidden = false
                self.removeWalletsCellsClones()
            }
        }
    }
    
    func hideNotSelectedRequests() {
        prepareActiveRequestsCellsClones()
        activeRequestsCollectionView.isHidden = true
        leftActiveRequestsClonesLeadingConstraint.constant = -leftActiveRequestsClonesWidthConstraint.constant
        rightActiveRequestsClonesTrailingConstraint.constant = -rightActiveRequestsClonesWidthConstraint.constant
        
        UIView.animate(withDuration: ANIMATION_DURATION) {
            self.activeRequestsClonesHolderView.layoutIfNeeded()
        }
    }
    
    func showNotSelectedRequests() {
        leftActiveRequestsClonesLeadingConstraint.constant = 0
        rightActiveRequestsClonesTrailingConstraint.constant = 0
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.activeRequestsClonesHolderView.layoutIfNeeded()
        }) { (succeeded) in
            if succeeded {
                self.activeRequestsCollectionView.isHidden = false
                self.removeActiveRequestsCellsClones()
            }
        }
    }

    func prepareWalletsCellsClones() {
        walletsClonesHolderView.isHidden = false
        leftWalletsClonesWidthConstraint.constant = walletsCollectionViewFL.sectionInset.left
        rightWalletsClonesWidthConstraint.constant = leftWalletsClonesWidthConstraint.constant
        walletsClonesHolderView.layoutIfNeeded()
        
        let visibleCells = walletsCollectionView.visibleCells as! [WalletCollectionViewCell]
        for cell in visibleCells {
            let cellClone = cloneWalletCell(cell)
            
            let walletIndex = presenter.walletsArr.index(of: cell.wallet!)
            if walletIndex != nil {
                let cellFrameOriginPoint = walletsCollectionView.convert(cellClone.frame.origin, to: self.view)
                if walletIndex! < presenter.selectedWalletIndex! {
                    cellClone.frame = CGRect(x: cellFrameOriginPoint.x, y: cellClone.frame.origin.y, width: cellClone.frame.size.width, height: cellClone.frame.size.height)
                    leftWalletsClonesHolderView.addSubview(cellClone)
                } else if walletIndex! > presenter.selectedWalletIndex! {
                    cellClone.frame = CGRect(x: 0, y: cellClone.frame.origin.y, width: cellClone.frame.size.width, height: cellClone.frame.size.height)
                    rightWalletsClonesHolderView.addSubview(cellClone)
                } else {
                    cellClone.frame = CGRect(x: cellFrameOriginPoint.x, y: cellClone.frame.origin.y, width: cellClone.frame.size.width, height: cellClone.frame.size.height)
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
            
            let requestIndex = presenter.activeRequestsArr.index(of: cellClone.request!)
            if requestIndex != nil {
                if requestIndex! < presenter.selectedActiveRequestIndex! {
                    let cellFrame = activeRequestsCollectionView.convert(cell.frame, to: leftActiveRequestsClonesHolderView!)
                    cellClone.frame = cellFrame
                    leftActiveRequestsClonesHolderView.addSubview(cellClone)
                } else if requestIndex! > presenter.selectedActiveRequestIndex! {
                    let cellFrame = activeRequestsCollectionView.convert(cell.frame, to: rightActiveRequestsClonesHolderView!)
                    cellClone.frame = cellFrame
                    rightActiveRequestsClonesHolderView.addSubview(cellClone)
                } else {
                    let cellFrame = activeRequestsCollectionView.convert(cell.frame, to: activeRequestsClonesHolderView!)
                    cellClone.frame = cellFrame
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
        let cellIndexPath = walletsCollectionView.indexPath(for: cell)
        let cellClone = walletsCollectionView.dequeueReusableCell(withReuseIdentifier: "WalletCollectionViewCell", for: cellIndexPath!) as! WalletCollectionViewCell
        cellClone.wallet = cell.wallet
        cellClone.fillInCell()

        return cellClone
    }
    
    func cloneActiveRequestCell(_ cell: ActiveRequestCollectionViewCell) -> ActiveRequestCollectionViewCell {
        let cellIndexPath = activeRequestsCollectionView.indexPath(for: cell)
        let cellClone = activeRequestsCollectionView.dequeueReusableCell(withReuseIdentifier: "ActiveRequestCollectionViewCell", for: cellIndexPath!) as! ActiveRequestCollectionViewCell
        cellClone.request = cell.request
        cellClone.fillInCell()
        
        return cellClone
    }
    
    //MARK: Actions
    @IBAction func qrCodeAction(_ sender: Any) {
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func recentAction(_ sender: Any) {
        
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
            
            let wallet = presenter.walletsArr[indexPath.item]
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
        let timeInterval = Date().timeIntervalSince1970
        switch longPress.state {
        case .began:
            if let indexPath = walletsCollectionView.indexPathForItem(at: location) {
                if indexPath.item == presenter.selectedWalletIndex! {
                    swipePrevLocationTimeInterval = timeInterval
                    swipePrevLocation = location
                    prepareForSending()
                }
            }
        case .changed:
            if sendMode == .prepareSending {
                if swipePrevLocation!.y - location.y > 5 && timeInterval - swipePrevLocationTimeInterval! < 0.05 {
                    send()
                    swipePrevLocation = nil
                    swipePrevLocationTimeInterval = nil
                } else {
                    swipePrevLocation = location
                    swipePrevLocationTimeInterval = timeInterval
                }
            }
        case .ended, .failed, .cancelled:
            if sendMode == .prepareSending {
                swipePrevLocation = nil
                swipePrevLocationTimeInterval = nil
                cancelSending()
            }
            
        default:
            break
        }
    }
}
