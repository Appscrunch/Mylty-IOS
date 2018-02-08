//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class WalletChoooseViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let presenter = WalletChooosePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.presenter.walletChoooseVC = self
//        self.presenter.createWallets()
        self.presenter.getWallets()
    }
    
    func registerCell() {
        let walletCell = UINib(nibName: "WalletTableViewCell", bundle: nil)
        self.tableView.register(walletCell, forCellReuseIdentifier: "walletCell")
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendDetailsVC" {
            let detailsVC = segue.destination as! SendDetailsViewController
            detailsVC.presenter.choosenWallet = self.presenter.walletsArr[self.presenter.selectedIndex!]
            detailsVC.presenter.addressToStr = self.presenter.addressToStr
            detailsVC.presenter.amountFromQr = self.presenter.amountFromQr
        }
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
}

extension WalletChoooseViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfWallets()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let walletCell = self.tableView.dequeueReusableCell(withIdentifier: "walletCell") as! WalletTableViewCell
        walletCell.arrowImage.image = nil
        walletCell.wallet = self.presenter.walletsArr[indexPath.row]
        walletCell.fillInCell()
        
        return walletCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.amountFromQr != nil {
            if presenter.walletsArr[indexPath.row].sumInCrypto < presenter.amountFromQr! {
                presenter.presentAlert()
                
                return
            }
        }
        
        self.presenter.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "sendDetailsVC", sender: Any.self)
    }
    
    func updateUI() {
        self.tableView.reloadData()
    }
}
