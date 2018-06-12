//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import Branch
import Lottie

enum ReceivingOption {
    case qrCode
    case wireless
}

private typealias LocalizeDelegate = ReceiveAllDetailsViewController

class ReceiveAllDetailsViewController: UIViewController, AnalyticsProtocol, CancelProtocol, AddressTransferProtocol {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var requestSumBtn: UIButton! // hide title when sum was requested
    @IBOutlet weak var sumValueLbl: UILabel!
    @IBOutlet weak var cryptoNameLbl: UILabel!
    @IBOutlet weak var fiatSumLbl: UILabel!
    @IBOutlet weak var fiatNameLbl: UILabel!
    @IBOutlet weak var viewForShadow: UIView!
    
    @IBOutlet weak var walletNameLbl: UILabel!
    @IBOutlet weak var walletCryptoSumBtn: UIButton! //set title with sum here
    @IBOutlet weak var walletFiatSumLbl: UILabel!
    @IBOutlet weak var walletCryptoSumLbl: UILabel!
    @IBOutlet weak var qrCodeTabSelectedView: UIView!
    @IBOutlet weak var qrCodeTabImageView: UIImageView!
    @IBOutlet weak var wirelessTabImageView: UIImageView!
    @IBOutlet weak var wirelessTabSelectedView: UIView!
    @IBOutlet weak var receiveViaLbl: UILabel!
    @IBOutlet weak var qrHolderView: UIView!
    @IBOutlet weak var invoiceHolderView: UIView!
    @IBOutlet weak var invoiceImage: UIImageView!
    @IBOutlet weak var requestSummLbl: UILabel!
    @IBOutlet weak var requestSummImageView: UIImageView!
    @IBOutlet weak var walletTokenImageView: UIImageView!
    
    @IBOutlet weak var wirelessButton: UIButton!
    @IBOutlet weak var hidedWalletView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hidedImage: UIImageView!
    @IBOutlet weak var hidedSumLabel: UILabel!
    @IBOutlet weak var hidedAddressLabel: UILabel!
    @IBOutlet weak var bluetoothDisabledContentView: UIView!
    @IBOutlet weak var searchingAnimationHolder: UIView!
    @IBOutlet weak var hidedWalletBackgroundView: UIView!
    
    var searchingAnimationView : LOTAnimationView?
    
    let presenter = ReceiveAllDetailsPresenter()
    
    var qrcodeImage: CIImage!
    var stringIdOfProduct: String?
    
    var option = ReceivingOption.qrCode {
        didSet {
            if option != oldValue {
                self.presenter.didChangeReceivingOption()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        self.presenter.receiveAllDetailsVC = self
        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)")
        self.viewForShadow.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5))
        self.requestSummImageView.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5))
        self.walletTokenImageView.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5))
        self.wirelessButton.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5))
        self.presenter.viewControllerViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkValuesAndSetupUI()
        self.updateUIWithWallet()
        self.makeQRCode()
        self.ipadFix()
        self.presenter.viewControllerViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.viewControllerViewWillDisappear()
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshBackground()
    }
    
    func refreshBackground() {
        if bluetoothDisabledContentView.isHidden {
            hidedWalletBackgroundView.applyOrUpdateGradient(withColours: [
                UIColor(ciColor: CIColor(red: 29.0 / 255.0, green: 176.0 / 255.0, blue: 252.0 / 255.0)),
                UIColor(ciColor: CIColor(red: 21.0 / 255.0, green: 126.0 / 255.0, blue: 252.0 / 255.0))],
                                                    gradientOrientation: .topRightBottomLeft)
        } else {
            hidedWalletBackgroundView.applyOrUpdateGradient(withColours: [
                UIColor(ciColor: CIColor(red: 23.0 / 255.0, green: 30.0 / 255.0, blue: 38.0 / 255.0)),
                UIColor(ciColor: CIColor(red: 67.0 / 255.0, green: 74.0 / 255.0, blue: 78.0 / 255.0))],
                                                            gradientOrientation: .vertical)
        }
    }
    
    func presentDidReceivePaymentAlert(address : String, amount : String) {
        let storyboard = UIStoryboard(name: "Send", bundle: nil)
        let sendOKVc = storyboard.instantiateViewController(withIdentifier: "SuccessSendVC") as! SendingAnimationViewController
        sendOKVc.presenter.fundsReceived(amount, address)
        
        self.navigationController?.pushViewController(sendOKVc, animated: true)
    }
    
    func updateUIForBluetoothState(_ isEnable : Bool) {
        if option == .wireless {
            bluetoothDisabledContentView.isHidden = isEnable
            refreshBackground()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.presenter.cancelViewController()
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: closeTap)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: closeTap)
    }
    
    @IBAction func qrTapAction(_ sender: Any) {
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: qrTap)
    }
    
    @IBAction func requestSumAction(_ sender: Any) {
        self.performSegue(withIdentifier: "receiveAmount", sender: UIButton.self)
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: requestSumTap)
    }
    
    @IBAction func addressAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        let allAddressVC = storyboard.instantiateViewController(withIdentifier: "walletAddresses") as! WalletAddresessViewController
        allAddressVC.addressTransferDelegate = self
        allAddressVC.presenter.wallet = self.presenter.wallet
        allAddressVC.whereFrom = self
        self.navigationController?.pushViewController(allAddressVC, animated: true)
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: addressTap)
    }

/*
    @IBAction func wirelessScanAction(_ sender: Any) {
        self.openDonat(productID: "io.multy.wirelessScan50")
        stringIdOfProduct = "io.multy.wirelessScan5"
//        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: wirelessScanTap)
        
        logAnalytics(code: donationForWirelessScanFUNC)
    }
 */
    
    @IBAction func addressBookAction(_ sender: Any) {
        self.openDonat(productID: "io.multy.addingContacts50")
        stringIdOfProduct = "io.multy.addingContacts5"
//        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: addressBookTap)
        logAnalytics(code: donationForContactSC)
    }
 
    func branchDict() -> NSDictionary {
        //check for blockchain
        //if bitcoin - address: "\(chainName):\(presenter.walletAddress)"
        let dict: NSDictionary = ["$og_title" : "Multy",
                                  "address"   : "\(presenter.qrBlockchainString):\(presenter.walletAddress)",
                                  "amount"    : presenter.cryptoSum ?? "0.0"]
        
        return dict
    }
    
    func cancelAction() {
//        presentDonationVCorAlert()
        self.makePurchaseFor(productId: stringIdOfProduct!)
    }
    
    @IBAction func enableBluetoothAction(_ sender: Any) {
        presentGoToBluetoothSettingsAlert()
    }
    
    func donate50(idOfProduct: String) {
        self.makePurchaseFor(productId: idOfProduct)
    }
    
    func presentNoInternet() {
        
    }
    
    func openDonat(productID: String) {
        unowned let weakSelf =  self
        self.presentDonationAlertVC(from: weakSelf, with: productID)
    }
    
    func logAnalytics(code: Int) {
        sendDonationAlertScreenPresentedAnalytics(code: code)
    }
    
    @IBAction func moreOptionsAction(_ sender: Any) {
        let branch = Branch.getInstance()
        branch?.getShortURL(withParams: branchDict() as! [String : Any], andChannel: "Create option \"Multy\"", andFeature: "sharing", andCallback: { (url, err) in
            let objectsToShare = [url] as! [String]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            activityVC.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    return
                } else {
                    if let appName = activityType?.rawValue {
                        self.sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(self.presenter.wallet!.chain)", eventName: "\(shareToAppWithChainTap)\(self.presenter.wallet!.chain)_\(appName)")
                    }
                }
            }
            activityVC.setPresentedShareDialogToDelegate()
            self.present(activityVC, animated: true, completion: nil)
        })
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: moreOptionsTap)
    }
    
    @IBAction func chooseAnotherWalletAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Receive", bundle: nil)
        let walletsVC = storyboard.instantiateViewController(withIdentifier: "ReceiveStart") as! ReceiveStartViewController
        walletsVC.presenter.isNeedToPop = true
        walletsVC.sendWalletDelegate = self.presenter
        self.navigationController?.pushViewController(walletsVC, animated: true)
        sendAnalyticsEvent(screenName: "\(screenReceiveSummaryWithChain)\(presenter.wallet!.chain)", eventName: changeWalletTap)
    }
 
    func updateUIWithWallet() {
        self.walletNameLbl.text = self.presenter.wallet?.name
        
        //FIXME: BLOCKCHAIN
        let blockchain = BlockchainType.create(wallet: presenter.wallet!)

//        self.walletCryptoSumBtn.setTitle("\((self.presenter.wallet?.sumInCryptoString) ?? "") \(blockchain.shortName /*self.presenter.wallet?.cryptoName ?? ""*/)", for: .normal)
        //FIXME:  Check this
        self.walletCryptoSumLbl.text = "\(self.presenter.wallet!.sumInCryptoString) \(blockchain.shortName /*self.presenter.wallet?.cryptoName ?? ""*/)"

        let sum = presenter.wallet!.sumInFiat.fixedFraction(digits: 2)
        self.walletFiatSumLbl.text = "\(sum) \(self.presenter.wallet?.fiatSymbol ?? "")"
        self.walletTokenImageView.image = UIImage(named: blockchain.iconString)
        if presenter.walletAddress == "" {
            self.presenter.walletAddress = (self.presenter.wallet?.address)!
        }
        self.addressLbl.text = self.presenter.walletAddress
        
        if sumValueLbl.isHidden == false {
            setupUIWithAmounts()
        }
    }
    
    func makeStringForQRWithSumAndAdress(cryptoName: String) -> String { // cryptoName = bitcoin
        return cryptoName + ":" + presenter.walletAddress + "?amount=" + (presenter.cryptoSum ?? "0.0")
    }
   
    @IBAction func receiveViaQRCodeAction(_ sender: Any) {
        self.option = .qrCode
    }
    
    @IBAction func receiveViaWirelessScanAction(_ sender: Any) {
        if presenter.cryptoSum == nil  {
            shakeView(viewForShake: requestSumBtn)
        } else {
            switch option {
            case .wireless:
                option = .qrCode
                changeVisibility(isHidden: true)
                wirelessButton.setTitle(localize(string: Constants.magicalReceiveString), for: .normal)
                
            case .qrCode:
                option = .wireless
                changeVisibility(isHidden: false)
                wirelessButton.setTitle(localize(string: Constants.cancelString), for: .normal)
            }
        }
    }
    
    func changeVisibility(isHidden: Bool) {
        if presenter.wirelessRequestImageName != nil {
            self.hidedImage.image = UIImage(named: presenter.wirelessRequestImageName!)
        }
        
        if !isHidden {
            hidedSumLabel.text = "\(sumValueLbl.text!) \(cryptoNameLbl.text!) / \(fiatSumLbl.text!) \(fiatNameLbl.text!)"
            hidedAddressLabel.text = presenter.walletAddress
        }
        
        updateSearchingAnimation()
        
        scrollView.isHidden = !isHidden
        hidedWalletView.isHidden = isHidden
    }
    
    func updateSearchingAnimation() {
        if option == .wireless {
            if searchingAnimationView == nil {
                searchingAnimationView = LOTAnimationView(name: "circle_grow")
                searchingAnimationView!.frame = searchingAnimationHolder.bounds
                searchingAnimationHolder.insertSubview(searchingAnimationView!, at: 0)
                searchingAnimationView!.transform = CGAffineTransform(scaleX: screenHeight/screenWidth, y: 1)
                searchingAnimationView!.loopAnimation = true
                searchingAnimationView!.play()
            } else {
                searchingAnimationView!.play()
            }
        } else {
            searchingAnimationView?.stop()
        }
    }
    
// MARK: QRCode Activity
    func makeQRCode() {
        let data = self.makeStringForQRWithSumAndAdress(cryptoName: presenter.qrBlockchainString).data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter?.outputImage
        displayQRCodeImage()
    }
    
    func makeQrWithSum() {
        let walletData = self.makeStringForQRWithSumAndAdress(cryptoName: presenter.qrBlockchainString).data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(walletData, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter?.outputImage
        displayQRCodeImage()
    }
    
    func displayQRCodeImage() {
        let scaleX = qrImage.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrImage.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrImage.image = self.convert(cmage: transformedImage)
    }
    
    func convert(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        
        return image
    }
    //
    
    func setupUIWithAmounts() {
        self.requestSumBtn.titleLabel?.isHidden = true
        self.requestSummImageView.isHidden = false
        self.requestSummLbl.isHidden = false
        
        sumValueLbl.isHidden = false
        cryptoNameLbl.isHidden = false
        fiatSumLbl.isHidden = false
        fiatNameLbl.isHidden = false
        
        sumValueLbl.text = presenter.cryptoSum
        
        let blockchainType = BlockchainType.create(wallet: presenter.wallet!)
        cryptoNameLbl.text = blockchainType.shortName
        
        fiatSumLbl.text = presenter.cryptoSum?.fiatValueString(for: blockchainType)
        fiatNameLbl.text = presenter.fiatName
        
        makeQrWithSum()
    }
    
    func checkValuesAndSetupUI() {
        if self.presenter.cryptoSum != nil {
            self.requestSumBtn.titleLabel?.isHidden = true
            self.requestSumBtn.setTitleColor(.white, for: .selected)
            self.requestSumBtn.setTitleColor(.white, for: .normal)
        }
    }
    
    func transfer(newAddress: String) {
        presenter.walletAddress = newAddress
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "receiveAmount" {
            let destVC = segue.destination as! ReceiveAmountViewController
            destVC.delegate = self.presenter
            destVC.blockchainType = BlockchainType.create(wallet: presenter.wallet!)
            destVC.presenter.wallet = self.presenter.wallet
            
            if self.presenter.cryptoSum != nil {
                destVC.sumInCryptoString = self.presenter.cryptoSum!
                destVC.cryptoName = self.presenter.cryptoName!
                destVC.fiatName = self.presenter.fiatName!
                destVC.sumInFiatString = self.presenter.fiatSum!
            }
        }
    }
    
    func ipadFix() {
        if screenHeight == heightOfiPad {
            self.sumValueLbl.font = sumValueLbl.font.withSize(30)
            self.cryptoNameLbl.font = cryptoNameLbl.font.withSize(30)
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Receives"
    }
}
