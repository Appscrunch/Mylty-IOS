//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

private typealias LocalizeDelegate = EthSendDetailsViewController

class EthSendDetailsViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nextBtn: ZFRippleButton!
    
    @IBOutlet weak var topButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBtnConstraint: NSLayoutConstraint!
    
    let presenter = EthSendDetailsPresenter()
    
    var isCustom = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.swipeToBack()
        self.presenter.sendDetailsVC = self
        self.registerCells()
        self.presenter.makeCryptoName()
        
        presenter.requestFee()
        
        presenter.getData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.nextBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                 UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                   gradientOrientation: .horizontal)
        
        let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TransactionFeeTableViewCell
        firstCell.setCornersForFirstCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if screenHeight == heightOfX {
            bottomBtnConstraint.constant = 0
            topButtonConstraint.constant = 70
        } else if screenHeight == heightOfPlus {
            topButtonConstraint.constant = 58
        }
        
        if self.presenter.selectedIndexOfSpeed == nil {
            self.tableView.selectRow(at: [0,2], animated: false, scrollPosition: .none)
            self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: [0,2])
        }
    }
    
    func registerCells() {
        let transactionCell = UINib(nibName: "TransactionFeeTableViewCell", bundle: nil)
        self.tableView.register(transactionCell, forCellReuseIdentifier: "transactionCell")
        
        let customFeeCell = UINib(nibName: "CustomTrasanctionFeeTableViewCell", bundle: nil)
        self.tableView.register(customFeeCell, forCellReuseIdentifier: "customFeeCell")
    }
    
    @IBAction func backAction(_ sender: Any) {
        presenter.transactionDTO.transaction!.transactionRLM = nil
        presenter.transactionDTO.transaction!.customFee = nil
        
        self.navigationController?.popViewController(animated: true)
        sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: closeTap)
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        self.view.endEditing(true)
        
        if self.presenter.selectedIndexOfSpeed != nil {
            self.presenter.createTransaction(index: self.presenter.selectedIndexOfSpeed!)
            self.presenter.checkMaxAvailable()
        } else {
            let alert = UIAlertController(title: localize(string: Constants.pleaseChooseGasPriceString), message: localize(string: Constants.youCanUsePredefinedValueString), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func presentWarning(message: String) {
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendEthVC" {
            let sendAmountVC = segue.destination as! SendAmountEthViewController
            
            presenter.transactionDTO.transaction!.transactionRLM = presenter.transactionObj
            presenter.transactionDTO.transaction!.customGAS = presenter.customGas
            
            sendAmountVC.presenter.transactionDTO = presenter.transactionDTO
        }
    }
}

extension EthSendDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 5 {
            let transactionCell = self.tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionFeeTableViewCell
            transactionCell.feeRate = self.presenter.feeRate
            transactionCell.blockchainType = self.presenter.transactionDTO.blockchainType
            transactionCell.makeCellBy(indexPath: indexPath)
            
            return transactionCell
        } else {
            let customFeeCell = self.tableView.dequeueReusableCell(withIdentifier: "customFeeCell") as! CustomTrasanctionFeeTableViewCell
            customFeeCell.blockchainType = presenter.transactionDTO.blockchainType
            customFeeCell.value = presenter.cusomtGasPrice ?? 0
            customFeeCell.setupUI()
            
            return customFeeCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: veryFastTap)
        case 1:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: fastTap)
        case 2:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: mediumTap)
        case 3:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: slowTap)
        case 4:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: verySlowTap)
        case 5:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: customTap)
        default : break
        }
        
        if indexPath.row != 5 {
//            if self.isCustom {
//                let customCell = self.tableView.cellForRow(at: [0,5]) as! CustomTrasanctionFeeTableViewCell
//                customCell.reloadUI()
//            }
//            var cells = self.tableView.visibleCells
//            cells.removeLast()
//            let trueCells = cells as! [TransactionFeeTableViewCell]
//            if trueCells[indexPath.row].checkMarkImage.isHidden == false {
//                trueCells[indexPath.row].checkMarkImage.isHidden = true
//                self.presenter.selectedIndexOfSpeed = nil
//
//                return
//            }
//            for cell in trueCells {
//                cell.checkMarkImage.isHidden = true
//            }
//            trueCells[indexPath.row].checkMarkImage.isHidden = false
            presenter.selectedIndexOfSpeed = indexPath.row
            presenter.updateCellsVisibility()
        } else {
            isCustom = true
            
            let storyboard = UIStoryboard(name: "Send", bundle: nil)
            let customVC = storyboard.instantiateViewController(withIdentifier: "customVC") as! CustomFeeViewController
            customVC.presenter.blockchainType = presenter.transactionDTO.choosenWallet!.blockchainType
            customVC.previousSelected = presenter.selectedIndexOfSpeed
            customVC.delegate = presenter
            customVC.rate = Int(presenter.cusomtGasPrice ?? 1)
            customVC.previousSelected = presenter.selectedIndexOfSpeed
            presenter.selectedIndexOfSpeed = indexPath.row
            
            navigationController?.pushViewController(customVC, animated: true)
            
//            var cells = self.tableView.visibleCells
//            cells.removeLast()
//            let trueCells = cells as! [TransactionFeeTableViewCell]
//            for cell in trueCells {
//                cell.checkMarkImage.isHidden = true
//            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
