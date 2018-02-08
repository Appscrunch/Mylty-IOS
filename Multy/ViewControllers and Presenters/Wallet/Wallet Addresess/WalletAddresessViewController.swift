//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class WalletAddresessViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLbl: UILabel!
    
    let presenter = WalletAddresessPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.addressesVC = self
        self.registerCell()
        
        self.tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateExchange), name: NSNotification.Name("exchageUpdated"), object: nil)
    }
    
    func registerCell() {
        let addressCell = UINib(nibName: "WalletAddressTableViewCell", bundle: nil)
        self.tableView.register(addressCell, forCellReuseIdentifier: "addressCell")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func updateExchange() {
        let cells = self.tableView.visibleCells
        for cell in cells {
            let addressCell = cell as! WalletAddressTableViewCell
            addressCell.updateExchange()
        }
    }
    
}

extension WalletAddresessViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfAddress()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addressCell = self.tableView.dequeueReusableCell(withIdentifier: "addressCell") as! WalletAddressTableViewCell
        addressCell.wallet = self.presenter.wallet
        addressCell.fillInCell(index: indexPath.row)
        
        return addressCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (64.0 / 375.0) * screenWidth
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        let adressVC = storyboard.instantiateViewController(withIdentifier: "walletAdressVC") as! AddressViewController
        adressVC.modalPresentationStyle = .overCurrentContext
        adressVC.addressIndex = indexPath.row
        adressVC.wallet = self.presenter.wallet
        //        self.mainVC.present
        self.present(adressVC, animated: true, completion: nil)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
