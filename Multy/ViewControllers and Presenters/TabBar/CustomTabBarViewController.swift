

///Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RevealingSplashView
import RAMAnimatedTabBarController

let tabbarSelectedBackground = UIColor(redInt: 3, greenInt: 127, blueInt: 255, alpha: 1.0)

class CustomTabBarViewController: RAMAnimatedTabBarController, UITabBarControllerDelegate {
    
    let presenter = CustomTabBarPresenter()
    // MARK: - View lifecycle
    let menuButton = UIButton()
    var previousSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.tabBarVC = self
        
        setupMiddleButton()
        
        self.loadSplashScreen()
    }
    
    func loadSplashScreen() {
        let logoWidth = 201 as CGFloat
        let logoHeight = 121 as CGFloat
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo")!,
                                                      iconInitialSize: CGSize(width: logoWidth, height: logoHeight),
                                                      backgroundColor: tabbarSelectedBackground)
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        //Starts animation
        revealingSplashView.startAnimation(){
        }
    }
    
    // MARK: - Setups
    
    func setupMiddleButton() {
        self.menuButton.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        var menuButtonFrame = menuButton.frame
        if screenHeight == 812 {   // iphone x height
            menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - 30
        } else {
            menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height
        }
        menuButtonFrame.origin.x = view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        
        view.addSubview(menuButton)
        
        menuButton.setImage(#imageLiteral(resourceName: "fastOperationBtn"), for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @objc private func menuButtonAction(sender: UIButton) {
        previousSelectedIndex = selectedIndex
        setSelectIndex(from: selectedIndex, to: 2)
        changeViewVisibility(isHidden: true)
        selectedIndex = 2
    }
    
    func changeViewVisibility(isHidden: Bool) {
        self.animationTabBarHidden(isHidden)
        menuButton.isHidden = isHidden
    }
}
