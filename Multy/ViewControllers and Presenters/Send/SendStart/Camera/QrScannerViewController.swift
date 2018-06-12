//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import AVFoundation

private typealias LocalizeDelegate = QrScannerViewController

class QrScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIGestureRecognizerDelegate, AnalyticsProtocol {

    let presenter = QrScannerPresenter()
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    weak var qrDelegate: QrDataProtocol?
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr,
                              AVMetadataObject.ObjectType.interleaved2of5,
                              AVMetadataObject.ObjectType.itf14,
                              AVMetadataObject.ObjectType.dataMatrix
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.qrScannerVC = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        sendAnalyticsEvent(screenName: screenQR, eventName: screenQR)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.sendAnalyticsEvent(screenName: screenQR, eventName: scanGotPermossion)
            self.camera()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.sendAnalyticsEvent(screenName: screenQR, eventName: scanGotPermossion)
                    self.camera()
                } else {
                    self.sendAnalyticsEvent(screenName: screenQR, eventName: scanDeniedPermission)
                    self.alertForGetNewPermission()
                }
            })
        }
    }
    
    func camera() {
        let captureDevice = AVCaptureDevice.devices(for: AVMediaType.video)
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice[0])
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            DispatchQueue.main.async {
                self.videoPreviewLayer?.frame = self.view.layer.bounds
                self.view.layer.addSublayer(self.videoPreviewLayer!)
                self.addCancelBtn()
            }
            
            // Start video capture.
            captureSession?.startRunning()
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func alertForGetNewPermission() {
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: localize(string: Constants.goToSettingsString), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if UIApplication.shared.canOpenURL(settingsUrl!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: { (success) in
                        self.cancel()
                    })
                } else {
                    UIApplication.shared.openURL(settingsUrl!)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func failed() {
        let ac = UIAlertController(title: localize(string: Constants.scanningNotSupportedString), message: localize(string: Constants.deviceNotSupportingString), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        
        if let metatdataObject = metadataObjects.first {
            guard let readableObject = metatdataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
            
            if self.presenter.isFast {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
            self.qrDelegate?.qrData(string: stringValue)
        }
        
        
    }
    
    func found(code: String) {
        print(code)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addCancelBtn() {
        let btn = UIButton()
        btn.titleLabel?.textAlignment = .left
        btn.setTitle(localize(string: Constants.cancelString), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = UIFont(name: "Avenir-Next", size: 16)
        btn.frame = CGRect(x: 20, y: 40, width: 140, height: 25)
        btn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    
    @objc func cancel() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
