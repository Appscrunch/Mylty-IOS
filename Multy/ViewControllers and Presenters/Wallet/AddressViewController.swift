//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import Branch

class AddressViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var copiedView: UIView!
    
    @IBOutlet weak var firstConstraint: NSLayoutConstraint!
    @IBOutlet weak var seondConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthConstraint: NSLayoutConstraint!
    
    var wallet: UserWalletRLM? {
        didSet {
            if wallet != nil {
                qrBlockchainString = BlockchainType.create(wallet: wallet!).qrBlockchainString
            }
        }
    }
    var addressIndex: Int?
    var qrBlockchainString = String()
    var qrcodeImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.presentedVC = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.makeQRCode()
        self.addressLbl.text = makeStringWithAddress()
    }
    
    override func viewDidLayoutSubviews() {
        self.copiedView.frame.origin.y = screenHeight + 40
        if screenHeight == heightOfiPad {
            firstConstraint.constant = firstConstraint.constant/2
//            seondConstraint.constant = seondConstraint.constant/2
//            thirdConstraint.constant = thirdConstraint.constant/2
        }
    }
    
    func makeStringWithAddress() -> String {
        if addressIndex == nil {
            return wallet!.address
        } else {
            return wallet!.addresses[addressIndex!].address
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func copyToClipboardAction(_ sender: Any) {
        UIPasteboard.general.string = makeStringWithAddress()
        UIView.animate(withDuration: 0.5, animations: {
            self.copiedView.frame.origin.y = screenHeight - 40
        }) { (isEnd) in
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.hideView), userInfo: nil, repeats: false)
        }
        
    }
    
    @objc func hideView() {
        UIView.animate(withDuration: 1, animations: {
            self.copiedView.frame.origin.y = screenHeight + 40
        })
    }
    
    func presentActivtyVC(objectToShare: String) {
        let objectsToShare = [objectToShare] as [String]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        activityVC.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            } else {
                if let appName = activityType?.rawValue {
                    self.sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(self.wallet!.chain)", eventName: "\(shareToAppWithChainTap)\(self.wallet!.chain)_\(appName)")
                }
            }
        }
        activityVC.setPresentedShareDialogToDelegate()
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func makeSharedString(urlString: String) -> String {
        var chainName = ""
        if wallet!.blockchainType.isMainnet {
            chainName = wallet!.blockchainType.shortName
        } else {
            chainName = "\(wallet!.blockchainType.shortName) TESTNET"
        }
        return "My \(chainName) Address: \(self.makeStringWithAddress())\n\nURL for open in app it\n\n\(urlString)"
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let branch = Branch.getInstance()
        branch?.getShortURL(withParams: self.branchDict() as! [String : Any], andChannel: "Create option \"Multy\"", andFeature: "sharing", andCallback: { (url, err) in
            self.presentActivtyVC(objectToShare: self.makeSharedString(urlString: url!))
        })
        sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(wallet!.chain)", eventName: "\(shareWithChainTap)\(wallet!.chain)")
    }
    
    func branchDict() -> NSDictionary {
        //check for blockchain
        //if bitcoin - address: "\(chainName):\(presenter.walletAddress)"
        let dict: NSDictionary = ["$og_title" : "Multy",
                                  "address"   : "\(qrBlockchainString):\(makeStringWithAddress())",
                                  "amount"    : 0.0]

        return dict
    }
  
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeStringForQRWithSumAndAdress(cryptoName: String) -> String { // cryptoName = bitcoin
        return "\(cryptoName):\(makeStringWithAddress())?amount:0"
    }
    
    func makeQRCode() {
        let data = self.makeStringForQRWithSumAndAdress(cryptoName: qrBlockchainString).data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter?.outputImage
        displayQRCodeImage()
    }
    
    func makeQrWithSum() {
        let walletData = self.makeStringForQRWithSumAndAdress(cryptoName: qrBlockchainString).data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(walletData, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter?.outputImage
        displayQRCodeImage()
    }
    
    func displayQRCodeImage() {
        let scaleX = qrImg.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrImg.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrImg.image = self.convert(cmage: transformedImage)
    }
    
    func convert(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
