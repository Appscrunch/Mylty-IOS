//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class PreloaderView: UIView {
    
    var hud: HUDView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init (frame: CGRect, text: String, image: UIImage?) {
        self.init(frame: frame)
        setupUI(text: text, image: image)
    }
    
    func setupUI(text: String, image: UIImage?) {
//        self.text = text
        self.backgroundColor = .white
        self.layer.cornerRadius = 15.0
        self.setShadow(with: #colorLiteral(red: 0.1490196078, green: 0.2980392157, blue: 0.4156862745, alpha: 0.3))
        self.hide()
        
        self.hud = HUDView(text: text, image: image)
        self.addSubview(hud!)
    }
    
    func show(customTitle: String?) {
        self.hud?.text = customTitle
        self.isHidden = false
        superview?.isUserInteractionEnabled = false
    }
    
    func hide() {
        self.isHidden = true
        superview?.isUserInteractionEnabled = true
    }
    
}
