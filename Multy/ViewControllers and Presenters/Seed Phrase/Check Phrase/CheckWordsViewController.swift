//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

class CheckWordsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var wordTF: UITextField!
    @IBOutlet weak var wordCounterLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nextWordOrContinue: ZFRippleButton!
    
    @IBOutlet weak var bricksView: UIView!

    @IBOutlet weak var constraintBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var constraintAfterTopLabel: NSLayoutConstraint!
    @IBOutlet weak var constraintAfterBricks: NSLayoutConstraint!
    
    let progressHUD = ProgressHUD(text: "Restoring Wallets...")
    
    var currentWordNumber = 1
    var isRestore = false
    var isNeedToClean = false
    
    let presenter = CheckWordsPresenter()
    
    //checking word
    var wordArray = [String]()
    var isWordFinded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(progressHUD)
        progressHUD.hide()
        
        if screenWidth < 325 {
            constraintTop.constant = 10
            constraintAfterTopLabel.constant = 10
            constraintAfterBricks.constant = 10
            wordTF.font?.withSize(50.0)
        }
        
        bricksView.addSubview(BricksView(with: bricksView.bounds, and: 0))
        
        self.presenter.checkWordsVC = self
        self.presenter.getSeedPhrase()
        
        self.wordTF.delegate = self
        self.wordTF.text = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyboard(_:)), name: Notification.Name("hideKeyboard"), object: nil)
        (self.tabBarController as! CustomTabBarViewController).menuButton.isHidden = true
        self.tabBarController?.tabBar.frame = CGRect.zero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.nextWordOrContinue.applyGradient(
            withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                          UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
            gradientOrientation: .horizontal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.wordTF.becomeFirstResponder()
        if self.isRestore {
            self.titleLbl.text = "Restore Multy"
        }
        if self.isNeedToClean {
            self.currentWordNumber = 1
            self.wordCounterLbl.text = "\(self.currentWordNumber) from 15"
            self.view.isUserInteractionEnabled = true
            self.presenter.phraseArr.removeAll()
            bricksView.subviews.forEach({ $0.removeFromSuperview() })
            bricksView.addSubview(BricksView(with: bricksView.bounds, and: 0))
        }
    }
    
    @objc func hideKeyboard(_ notification : Notification) {
//        self.wordTF.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    @IBAction func nextWordAndContinueAction(_ sender: Any) {
        if self.presenter.phraseArr.count == 15 {
            self.presenter.auth(seedString: self.presenter.phraseArr.joined(separator: " "))
            
            return
        }
        
        if self.wordTF.text == nil {
            return
        }
        
        if self.wordTF.text!.count < 3 {
            return
        }
        
//        if !DataManager.shared.isWordCorrect(word: self.wordTF.text!) {
//            presentAlert()
//            
//            return
//        }
        
        //there are too many word
        if wordArray.count != 1 && !isWordFinded {
            return
        }
        
        if !self.wordTF.text!.isEmpty {
            self.presenter.phraseArr.append(wordArray.first!)
            self.wordTF.text = ""
            self.nextWordOrContinue.setTitle("Next Word", for: .normal)
        } else {
            return
        }
        
        bricksView.subviews.forEach({ $0.removeFromSuperview() })
        bricksView.addSubview(BricksView(with: bricksView.bounds, and: currentWordNumber))
        
        if self.currentWordNumber == 15 {
            self.nextWordOrContinue.setTitle("Continue", for: .normal)
        }
        
        if self.currentWordNumber < 15 {
            self.currentWordNumber += 1
            self.wordCounterLbl.text = "\(self.currentWordNumber) from 15"
        } else {
            if self.isRestore {
                self.presenter.auth(seedString: self.presenter.phraseArr.joined(separator: " "))
                
                return
            }
            let isPhraseCorrect = presenter.isSeedPhraseCorrect()
            
            if isPhraseCorrect {
                self.performSegue(withIdentifier: "greatVC", sender: UIButton.self)
            } else {
                self.performSegue(withIdentifier: "wrongVC", sender: UIButton.self)
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let inset : UIEdgeInsets = UIEdgeInsetsMake(64, 0, keyboardSize.height, 0)
            if self.isRestore {
                if screenHeight == 812 {
                    self.constraintBtnBottom.constant = inset.bottom - 35
                } else {
                    self.constraintBtnBottom.constant = inset.bottom// - 50
                }
            } else {
                if screenHeight == 812 {
                    self.constraintBtnBottom.constant = inset.bottom - 35
                } else {
                    self.constraintBtnBottom.constant = inset.bottom
                }
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        let alert = UIAlertController(title: "Cancel", message: "Are you really want to cancel?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.presenter.phraseArr.count == 15 {
            return false
        }
//        if string == "" {
//            return true
//        }
        let inverseSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
        
        let components = string.components(separatedBy: inverseSet as CharacterSet)
        
        let filtered = components.joined(separator: "")
        
        if !filtered.isEmpty {
            return false
        }
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if DataManager.shared.findPrefixes(prefix: textAfterUpdate).count == 0 {
            return false
        } else {
            wordArray = DataManager.shared.findPrefixes(prefix: textAfterUpdate)
            isWordFinded = wordArray.contains(textAfterUpdate)
        }
        
        if wordArray.count == 1 {
            self.nextWordOrContinue.setTitle(wordArray.first!, for: .normal)
        } else {
            if isWordFinded {
                self.nextWordOrContinue.setTitle(textAfterUpdate + " or " + textAfterUpdate + "..." , for: .normal)
            } else {
                self.nextWordOrContinue.setTitle(textAfterUpdate + "..." , for: .normal)
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "greatVC" {
            let greatVC = segue.destination as! BackupFinishViewController
            greatVC.seedString = self.presenter.phraseArr.joined(separator: " ")
        } else if segue.identifier == "wrongVC" {
            let wrongVC = segue.destination as! WrongSeedPhraseViewController
            wrongVC.presenter.prevVC = self
        }
    }
    
    func presentAlert() {
        let message = "You entered wrong word!"
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        
        let rootViewController: UIViewController = UIApplication.shared.windows.last!.rootViewController!
        rootViewController.present(alert, animated: true, completion: nil)
    }
}

