//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class HUDView: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    let spiner      = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let imageView   = UIImageView()
    let label       = UILabel()
    let blurEffect  = UIBlurEffect(style: UIBlurEffectStyle.light)
    let vibrancyView: UIVisualEffectView
    
    init(text: String, image: UIImage?) {
        self.text = text
        self.image = image
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.image = nil
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(imageView)
        contentView.addSubview(spiner)
        contentView.addSubview(label)
        spiner.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview?.className == PreloaderView.className {
            self.frame = CGRect(x: 0, y: 0, width: 145, height: 120)
            self.layer.cornerRadius = 15.0
            self.layer.masksToBounds = true
            
            vibrancyView.frame = self.bounds
            
            let spinerSize: CGFloat = 40
            spiner.frame = CGRect(x: 52, y: 35 , width: spinerSize, height: spinerSize)
            
            imageView.frame = CGRect(x: 52, y: 30, width: 40, height: 40)
            imageView.image = image
            
            label.text = text
            label.textAlignment = .center
            label.frame = CGRect(x: 10, y: 80, width: 125, height: 20)
            label.font = UIFont(name: "AvenirNext-Medium", size: 16)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
    
}
