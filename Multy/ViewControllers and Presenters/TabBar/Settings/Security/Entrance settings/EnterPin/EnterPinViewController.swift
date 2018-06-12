//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class EnterPinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet var numberButtons: [UIButton]!
    @IBOutlet var circleView: [UIView]!
    @IBOutlet weak var viewWithCircles: UIView!
    @IBOutlet weak var pinTF: UITextField!
    
    weak var cancelDelegate: CancelProtocol?
    
    var counter = 0
    
    var passFromPref = ""
    
    var whereFrom: UIViewController?
    
    var isNeedToPresentBiometric = true
    
    let touchMe = TouchIDAuth()
    
    var wrongCounter = 0
    
    var wrongAttempts = 0
    
    //Alert + timer
//    var counterOfTimer:Int = 0
    var timer: Timer?
    var defTime = 60
    
    var wrongPinVC: WrongPinViewController?
    var blockDate: Date? // start blocking
    var blockDuration: Int? // blocking during
    
    var blockedScreenDuration : Int {
        get {
            return Int(Date().timeIntervalSince(blockDate!))
        }
    }
    
    var isBlockScreenOn: Bool {
        get {
            return blockedScreenDuration < blockDuration!
        }
    }
    
    var countdownSeconds: Int {
        get {
            return blockDuration! - blockedScreenDuration
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
        self.clearAllCircles()
        self.getPass()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.enterPinVc = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseApp), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeApp), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarOnPreviousVC = self.whereFrom?.tabBarController as? CustomTabBarViewController {
            tabBarOnPreviousVC.changeViewVisibility(isHidden: true)
            tabBarOnPreviousVC.isLocked = true
        }
        
        self.checkAttempts { (isTimerPresent) in
            if !isTimerPresent {
                self.checkForBiometic()
            }
        }
    }
    
    func checkForBiometic() {
        UserPreferences.shared.getAndDecryptBiometric(completion: { (isBiometricOn, err) in
            if isBiometricOn != nil && !isBiometricOn! {
                return
            }
            if self.isNeedToPresentBiometric {
                self.biometricAuth()
            }
        })
    }
    
    func setupButtons() {
        for btn in self.numberButtons {
            btn.layer.cornerRadius = btn.frame.width/2
        }
        
        if self.whereFrom!.className == "SettingsViewController" {
            self.cancelBtn.isHidden = false
        }
        
        cancelBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelBtn.titleLabel?.minimumScaleFactor = 0.5
        cancelBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func tapAction(_ sender: Any) {
        let tappedBtn = sender as! UIButton
        self.pinTF.text?.append(tappedBtn.titleLabel!.text!)
        paintCircleAt(position: counter)
        if counter < 5 {
            counter += 1
        } else {
            self.view.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.view.isUserInteractionEnabled = true
                if self.pinTF.text! == self.passFromPref {
                    self.cancelDelegate?.presentNoInternet()
                    self.successDismiss()
                } else {
                    shakeView(viewForShake: self.viewWithCircles)
//                    self.writeWrongAttempt()
                    self.clearAllCircles()
                    self.counter = 0
                }
            }
        }
    }
    
    @IBAction func removeLastAction(_ sender: Any) {
        if counter == 0 {
            return
        }
        self.pinTF.text?.removeLast()
        clearCircleAt(position: counter)
        counter -= 1
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.successDismiss()
    }
    
    func clearAllCircles() {
        for (index, _/*circle*/) in self.circleView.enumerated() {
            self.clearCircleAt(position: index + 1)
        }
        self.pinTF.text = ""
    }
    
    func paintCircleAt(position: Int) {
        let circle = circleView[position]
        circle.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        circle.layer.borderWidth = 0
    }
    
    func clearCircleAt(position: Int) {
        let circleForClear = circleView[position - 1]
        circleForClear.layer.borderWidth = 2
        circleForClear.layer.borderColor = #colorLiteral(red: 0.9999478459, green: 1, blue: 0.9998740554, alpha: 1)
        circleForClear.backgroundColor = .clear
    }
    
    func hideCancel() {
        if self.cancelBtn != nil {
            self.cancelBtn.isHidden = true
        }
    }
    
    func getPass() {
        UserPreferences.shared.getAndDecryptPin { (pin, err) in
            if pin != nil {
                self.passFromPref = pin!
            }
        }
    }
    
    func biometricAuth() {
        self.touchMe.authenticateUser { (message) in
            if let _ = message {
                self.tabBarController?.tabBar.isUserInteractionEnabled = false
            } else {
                self.cancelDelegate?.presentNoInternet()
                self.successDismiss()
                
                NotificationCenter.default.post(name: Notification.Name("showKeyboard"), object: nil)
                NotificationCenter.default.post(name: Notification.Name("canDisablePin"), object: nil)
            }
        }
    }
    
    func successDismiss() {
        if let tabBarOnPreviousVC = self.whereFrom?.tabBarController as? CustomTabBarViewController {
            tabBarOnPreviousVC.isLocked = false
        }
        UserPreferences.shared.writeChipheredBlockSeconds(seconds: 0)
        self.dismiss(animated: true, completion: nil)
        self.whereFrom?.viewWillAppear(true)
    }
    
    
    func checkAttempts(completion: @escaping (_ presentTimer: Bool) -> ()) {
        UserPreferences.shared.getAndDecryptBlockSeconds { [unowned self] (seconds, err) in
            if seconds != nil && seconds != 0 {
                self.blockDuration = seconds
                UserPreferences.shared.getAndDecryptStartBlockTime { (blockDate, err) in
                    if blockDate != nil {
                        self.blockDate = blockDate
                        if self.isBlockScreenOn {
                            self.showAlert()
                            completion(true)
                        } else {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func writeWrongAttempt() {
        self.wrongCounter += 1
        if self.wrongCounter % UserPreferences.shared.getAndDecryptMaxEnterPinTries() == 0 {
            UserPreferences.shared.getAndDecryptBlockSeconds { (seconds, err) in
                if seconds != nil && seconds != 0 && self.defTime == 60 {
                    self.defTime = seconds! * 2
                }
                self.blockDuration = seconds
                UserPreferences.shared.writeChipheredBlockSeconds(seconds: self.defTime)
                UserPreferences.shared.writeStartBlockTime(time: Date())
                self.checkAttempts(completion: { (isTimerPresent) in
                    //callback is needed for viewWillAppear
                })
                self.defTime *= 2
            }
        }
    }
    
    
    //Alert + timer
    func showAlert() {
        self.checkBlockTime { [unowned self] (answer) in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let wrongVC = storyBoard.instantiateViewController(withIdentifier: "wrongPinVC") as! WrongPinViewController
            wrongVC.setPresentedVcToDelegate()
            wrongVC.timeString = self.makeTimeString()
            self.wrongPinVC = wrongVC
            self.present(wrongVC, animated: true)
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.decrease), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    @objc func decrease() {
        if isBlockScreenOn {
            self.wrongPinVC?.timeLbl?.text = makeTimeString()
        } else {
            self.wrongPinVC?.dismiss(animated: true, completion: {
                self.checkForBiometic()
            })
            timer?.invalidate()
        }
    }
    
    func makeTimeString() -> String {
        var minutes: Int
        var seconds: Int
        
        let counterOfTimer = countdownSeconds
        
        if (countdownSeconds >= 0) {
            print(counterOfTimer)  // Correct value in console
            minutes = (counterOfTimer % 3600) / 60
            seconds = (counterOfTimer % 3600) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
        return "00:00"
    }
    
    
    @objc func pauseApp() {
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    @objc func resumeApp() {
//        self.checkBlockTime { (answer) in
//        }
    }
    
    func checkBlockTime(completion: @escaping(_ answer: Int?) -> ()) {
        UserPreferences.shared.getAndDecryptStartBlockTime { [unowned self] (blockDate, err) in
            if blockDate == nil {
                return
            }
            
            self.blockDate = blockDate
            if self.isBlockScreenOn {
                completion(1)
            } else {
                completion(0)
            }
        }
    }
}

