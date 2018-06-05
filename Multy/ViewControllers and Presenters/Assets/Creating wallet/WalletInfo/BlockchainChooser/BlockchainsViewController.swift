//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import StoreKit
import SwiftyStoreKit

private typealias AnalyticsDelegate = BlockchainsViewController
private typealias CancelDelegate = BlockchainsViewController
private typealias TableViewDelegate = BlockchainsViewController
private typealias TableViewDataSource = BlockchainsViewController
private typealias LocalizeDelegate = BlockchainsViewController

class BlockchainsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let presenter = BlockchainsPresenter()
    
    var stringInAppId = ""
    var stringInAppIdBig = ""
    
    weak var delegate: ChooseBlockchainProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.presenter.mainVC = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.presenter.createChains()
    }
    
    func registerCell() {
        let blockchainCell = UINib.init(nibName: "BlockchainCellTableViewCell", bundle: nil)
        self.tableView.register(blockchainCell, forCellReuseIdentifier: "blockchainCell")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CancelDelegate: CancelProtocol {
    func cancelAction() {
        self.makePurchaseFor(productId: self.stringInAppId)
    }
    
    func presentNoInternet() {
        
    }
}

extension AnalyticsDelegate: AnalyticsProtocol {
    func logAnalytics(indexPath: IndexPath) {
        var eventCode = donationForBTCLighting // see AnalyticsConstants
        
        switch indexPath.row {
        case 0:
            break
        default:
            eventCode += 1 + indexPath.row // since omitted ETH
        }
        
        sendDonationAlertScreenPresentedAnalytics(code: eventCode)
    }
}

extension TableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.frame = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 46.0)
        header.backgroundColor = #colorLiteral(red: 0.9764457345, green: 0.9803969264, blue: 0.9998489022, alpha: 1)
        let label = UILabel()
        label.frame = CGRect(x: 20.0, y: 20.0, width: 150, height: 22)
        label.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
        
        if section == 0 {
            label.textColor = #colorLiteral(red: 0.5294117647, green: 0.631372549, blue: 0.7725490196, alpha: 1)
            label.text = localize(string: Constants.availableString)
        } else {
            label.textColor = #colorLiteral(red: 0.9215686275, green: 0.08235294118, blue: 0.231372549, alpha: 1)
            label.text = localize(string: Constants.workInProgressString)
        }
        
        header.addSubview(label)
        return header
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            self.makeStingIdForInApp(indexPath: indexPath)
            unowned let weakSelf =  self
            self.presentDonationAlertVC(from: weakSelf, with: stringInAppIdBig)
            logAnalytics(indexPath: indexPath)
        } else {
            let currencyObj = presenter.availableBlockchainArray[indexPath.row]
            delegate?.setBlockchain(blockchain: currencyObj.currencyBlockchain)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func makeStingIdForInApp(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: stringInAppId = "io.multy.addingEthereum5"
        case 1: stringInAppId = "io.multy.addingSteemit5"
        case 2: stringInAppId = "io.multy.addingBCH5"
        case 3: stringInAppId = "io.multy.addingLitecoin5"
        case 4: stringInAppId = "io.multy.addingDash5"
        case 5: stringInAppId = "io.multy.addingEthereumClassic5"
        default: break
        }
    }
    
    func makeStingIdForBigInApp(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: stringInAppIdBig = "io.multy.addingEthereum50"
        case 1: stringInAppIdBig = "io.multy.addingSteemit50"
        case 2: stringInAppIdBig = "io.multy.addingBCH50"
        case 3: stringInAppIdBig = "io.multy.addingLitecoin50"
        case 4: stringInAppIdBig = "io.multy.addingDash50"
        case 5: stringInAppIdBig = "io.multy.addingEthereumClassic50"
        default: break
        }
    }
}

extension TableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return presenter.availableBlockchainArray.count
        } else {
            return presenter.donateBlockchainArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chainCell = self.tableView.dequeueReusableCell(withIdentifier: "blockchainCell") as! BlockchainCellTableViewCell
        if indexPath.section == 0 {
            let currencyObj = presenter.availableBlockchainArray[indexPath.row]
            chainCell.fillFromArr(curObj: currencyObj)
            chainCell.updateIconsVisibility(isAvailable: true, isChecked: currencyObj.currencyBlockchain == presenter.selectedBlockchain)
        } else {
            chainCell.fillFromArr(curObj: presenter.donateBlockchainArray[indexPath.row])
            chainCell.updateIconsVisibility(isAvailable: false, isChecked: false)
        }
        
        return chainCell
    }
}

extension LocalizeDelegate: Localizable {    
    var tableName: String {
        return "CurrencyChooser"
    }
}
