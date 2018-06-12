//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

private typealias TableViewDataSource = CreateWalletViewController
private typealias TableViewDelegate = CreateWalletViewController
private typealias TextFieldDelegate = CreateWalletViewController
private typealias ChooseBlockchainDelegate = CreateWalletViewController
private typealias LocalizeDelegate = CreateWalletViewController

class CreateWalletViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintContinueBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var createBtn: ZFRippleButton!
    
    var presenter = CreateWalletPresenter()
//    let progressHUD = ProgressHUD(text: "Creating Wallet...")
    let loader = PreloaderView(frame: HUDFrame, text: "Creating Wallet...", image: #imageLiteral(resourceName: "walletHuge"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        self.hideKeyboardWhenTappedAround()
        self.tableView.tableFooterView = nil
        loader.show(customTitle: Constants.creatingWalletString)
        self.view.addSubview(loader)
        loader.hide()
        self.presenter.mainVC = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        sendAnalyticsEvent(screenName: screenCreateWallet, eventName: screenCreateWallet)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        (self.tabBarController as! CustomTabBarViewController).menuButton.isHidden = true
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createAction(_ sender: Any) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CreateWalletNameTableViewCell
        if let text = cell.walletNameTF.text {
            if text.trimmingCharacters(in: .whitespaces).count == 0 {
                presentAlert(with: localize(string: Constants.walletNameAlertString))
                
                return
            }
        } else {
            presentAlert(with: localize(string: Constants.walletNameAlertString))
            
            return
        }
        
        loader.show(customTitle: localize(string: Constants.creatingWalletString))
        presenter.createNewWallet { (dict) in
            print(dict!)
        }
        sendAnalyticsEvent(screenName: screenCreateWallet, eventName: createWalletTap)
    }
    
    func openNewlyCreatedWallet() {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        var walletVC = UIViewController()
        
        switch presenter.createdWallet.blockchainType.blockchain {
        case BLOCKCHAIN_BITCOIN:
            let vc = storyboard.instantiateViewController(withIdentifier: "WalletMainID") as! BTCWalletViewController
            vc.presenter.wallet = presenter.createdWallet
            vc.presenter.account = presenter.account
            
            walletVC = vc
        case BLOCKCHAIN_ETHEREUM:
            let vc = storyboard.instantiateViewController(withIdentifier: "EthWalletID") as! EthWalletViewController
            vc.presenter.wallet = presenter.createdWallet
            vc.presenter.account = presenter.account
            
            walletVC = vc
        default:
            return
        }
        
        navigationController?.pushViewController(walletVC, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.createBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                   UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                     gradientOrientation: .horizontal)
    }
    
    func goToCurrency() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let currencyVC = storyboard.instantiateViewController(withIdentifier: "currencyVC")
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
    func goToChains() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chainsVC = storyboard.instantiateViewController(withIdentifier: "chainsVC") as! BlockchainsViewController
        
        chainsVC.presenter.selectedBlockchain = presenter.selectedBlockchainType
        chainsVC.delegate = self
        
        self.navigationController?.pushViewController(chainsVC, animated: true)
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let inset : UIEdgeInsets = UIEdgeInsetsMake(64, 0, keyboardSize.height, 0)
            self.constraintContinueBtnBottom.constant = inset.bottom
            if screenHeight == heightOfX {
                self.constraintContinueBtnBottom.constant = inset.bottom - 35
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        //            if self.view.frame.origin.y != 0{
        //                self.view.frame.origin.y += keyboardSize.height
        //            }
        self.constraintContinueBtnBottom.constant = 0
        //        }
    }
}

extension ChooseBlockchainDelegate: ChooseBlockchainProtocol {
    func setBlockchain(blockchain: BlockchainType) {
        presenter.selectedBlockchainType = blockchain
        updateBlockchainCell(blockchainCell: nil)    }
}

extension TableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == [0,0] {
            let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "cell1") as! CreateWalletNameTableViewCell
            cell1.walletNameTF.becomeFirstResponder()
            
            return cell1
        } else if indexPath == [0,1] {
            let blockchainCell = self.tableView.dequeueReusableCell(withIdentifier: "cell2") as! CreateWalletBlockchainTableViewCell
            updateBlockchainCell(blockchainCell: blockchainCell)
            
            return blockchainCell
        } else {//if indexPath == [0,2] {
            let cell4 = self.tableView.dequeueReusableCell(withIdentifier: "cell4")
            
            return cell4!
        }
    }
    
    fileprivate func updateBlockchainCell(blockchainCell: CreateWalletBlockchainTableViewCell?) {
        let cell2 = blockchainCell == nil ? self.tableView.dequeueReusableCell(withIdentifier: "cell2") as! CreateWalletBlockchainTableViewCell : blockchainCell!
        cell2.blockchainLabel.text = presenter.selectedBlockchainType.fullName + " ∙ " + presenter.selectedBlockchainType.shortName
        
        if presenter.selectedBlockchainType.isMainnet == false {
            cell2.blockchainLabel.text! += "  Testnet"
        }
        
        if blockchainCell == nil {
            tableView.reloadRows(at: [[0, 1]], with: .none)
        }
    }
}

extension TableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            sendAnalyticsEvent(screenName: screenCreateWallet, eventName: chainIdTap)
            self.goToChains()
        } else if indexPath.row == 2 {
            sendAnalyticsEvent(screenName: screenCreateWallet, eventName: fiatIdTap)
            self.goToCurrency()
        }
    }
}

extension TextFieldDelegate: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.count)! + string.count < maxNameLength {
            return true
        } else {
            return false
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
    }
}
