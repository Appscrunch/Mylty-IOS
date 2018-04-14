//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import LTMorphingLabel

class PinCodeViewController: UIViewController, UITextFieldDelegate, AnalyticsProtocol {

    @IBOutlet weak var pinTF: UITextField!
    @IBOutlet weak var pinTextLbl: LTMorphingLabel!
    @IBOutlet weak var viewWithCircles: UIView!
    @IBOutlet var circleView: [UIView]!
    
    var counter = 0
    
    var firstPass = ""
    
    var isRepeat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinTF.becomeFirstResponder()
        clearAllCircles()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.selectedIndexOfTabBar = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if counter == 5 && string != "" {
            paintCircleAt(position: counter)
            if isRepeat == false {
                self.view.isUserInteractionEnabled = false
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.pinTextLbl.text = "Repeat your PIN-code"
                    self.firstPass = self.pinTF.text! + string
                    self.clearAllCircles()
                    self.counter = 0
                    self.isRepeat = true
                    self.view.isUserInteractionEnabled = true
//                }
                return false
            } else {
                self.view.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.view.isUserInteractionEnabled = true
                    if (self.pinTF.text! + string) == self.firstPass {
                        UserPreferences.shared.writeCipheredPin(pin: "\(self.firstPass)")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        shakeView(viewForShake: self.viewWithCircles)
                        self.clearAllCircles()
                        self.counter = 0
                    }
                }
                return false
            }
        }
        
        if string == "" {
            if counter == 0 {
                return false
            }
            clearCircleAt(position: counter)
            counter -= 1
            return true
        }
        
        paintCircleAt(position: counter)
        counter += 1
        return true
    }
    
    //    sendAnalyticsEvent(screenName: screenBlockSettings, eventName: pinSetuped)    // send when pin settuped
    
    func paintCircleAt(position: Int) {
        let circle = circleView[position]
        circle.backgroundColor = #colorLiteral(red: 0.01176470588, green: 0.4769998789, blue: 0.9994105697, alpha: 1)
        circle.layer.borderWidth = 0
    }
    
    func clearCircleAt(position: Int) {
        let circleForClear = circleView[position - 1]
        circleForClear.layer.borderWidth = 2
        circleForClear.layer.borderColor = #colorLiteral(red: 0.7646385431, green: 0.8155806661, blue: 0.8860673904, alpha: 1)
        circleForClear.backgroundColor = .clear
    }
    
    func clearAllCircles() {
        for (index, _/*circle*/) in self.circleView.enumerated() {
            self.clearCircleAt(position: index + 1)
        }
        self.pinTF.text = ""
    }
    
    
//    func shakeView() {
//        let animation = CABasicAnimation(keyPath: "position")
//        animation.duration = 0.07
//        animation.repeatCount = 4
//        animation.autoreverses = true
//        animation.fromValue = NSValue(cgPoint: CGPoint(x: viewWithCircles.center.x - 10, y: viewWithCircles.center.y))
//        animation.toValue = NSValue(cgPoint: CGPoint(x: viewWithCircles.center.x + 10, y: viewWithCircles.center.y))
//
//        self.viewWithCircles.layer.add(animation, forKey: "position")
//    }
    
}
