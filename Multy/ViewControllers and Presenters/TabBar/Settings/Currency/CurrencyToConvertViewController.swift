//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = CurrencyToConvertViewController

class CurrencyToConvertViewController: UIViewController, CancelProtocol, AnalyticsProtocol {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        self.registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func registerCell() {
        let currencyCell = UINib.init(nibName: "CurrencyTableViewCell", bundle: nil)
        self.tableView.register(currencyCell, forCellReuseIdentifier: "currencyCell")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelAction() {
//        presentDonationVCorAlert()
        self.makePurchaseFor(productId: "io.multy.estimationCurrencies5")
    }
    
    func donate50(idOfProduct: String) {
        self.makePurchaseFor(productId: idOfProduct)
    }
    
    func presentNoInternet() {

    }
}

extension CurrencyToConvertViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currencyCell = self.tableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyTableViewCell
        if indexPath.section == 1 {
            currencyCell.createCurrency()
            currencyCell.makeNotAvailable()
            currencyCell.fillFromArr(index: indexPath.row)
        }
        return currencyCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            unowned let weakSelf =  self
            self.presentDonationAlertVC(from: weakSelf, with: "io.multy.estimationCurrencie50")
            logAnalytics(indexPath: indexPath)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func logAnalytics(indexPath: IndexPath) {
        //FIXME: add switch if here will be changing //see BlockchainsViewController
        let eventCode = donationForEUR + indexPath.row
        sendDonationAlertScreenPresentedAnalytics(code: eventCode)
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "CurrencyChooser"
    }
}
