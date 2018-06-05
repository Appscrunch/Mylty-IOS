//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = SeedPhraseWordPresenter

class SeedPhraseWordPresenter: NSObject {
    var mainVC : SeedPhraseWordViewController?
    
    var countOfTaps = -1
    var mnemonicPhraseArray = [String]() {
        didSet {
            if mnemonicPhraseArray.count > 0 && DataManager.shared.realmManager.account?.seedPhrase != ""/*&& mainVC?.isNeedToBackup == nil*/ {
                let mnemonicString = mnemonicPhraseArray.joined(separator: " ")
                DataManager.shared.realmManager.writeSeedPhrase(mnemonicString, completion: { (error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        print("seed phrase wrote down")
                    }
                })
            }
        }
    }
    
    func getSeedFromAcc() {
//        mnemonicPhraseArray = DataManager.shared.getMnenonicArray()
        DataManager.shared.getAccount { (acc, err) in
            if acc!.seedPhrase != nil && acc!.seedPhrase != "" {
                self.mnemonicPhraseArray = (acc?.seedPhrase.components(separatedBy: " "))!
            } else {
                self.mnemonicPhraseArray = (acc?.backupSeedPhrase.components(separatedBy: " "))!
            }
        }
    }
    
    func presentNextTripleOrContinue() {
        if self.countOfTaps == 3 {
            self.mainVC?.nextWordBtn.setTitle(localize(string: Constants.continueString), for: .normal)
        }
        
        if self.countOfTaps == 0 {
            self.mainVC?.blocksImage.image = #imageLiteral(resourceName: "02")
        } else if self.countOfTaps == 1 {
            self.mainVC?.blocksImage.image = #imageLiteral(resourceName: "03")
        } else if self.countOfTaps == 2 {
            self.mainVC?.blocksImage.image = #imageLiteral(resourceName: "04")
        } else
            if self.countOfTaps == 3 {
                self.mainVC?.nextWordBtn.setTitle(localize(string: Constants.continueString), for: .normal)
                self.mainVC?.blocksImage.image = #imageLiteral(resourceName: "05")
        }
        
        //getNextWords
        if self.countOfTaps < 4 {
            self.countOfTaps += 1
            
            self.mainVC?.topWordLbl.text = mnemonicPhraseArray[3 * countOfTaps]
            self.mainVC?.mediumWordLbl.text = mnemonicPhraseArray[3 * countOfTaps + 1]
            self.mainVC?.bottomWord.text = mnemonicPhraseArray[3 * countOfTaps + 2]
        }  else {
            if self.mainVC!.whereFrom != nil && self.mainVC!.isNeedToBackup == nil {
                self.mainVC!.navigationController?.popToViewController(self.mainVC!.whereFrom!, animated: true)
                return
            }
            self.mainVC?.performSegue(withIdentifier: "backupSeedPhraseVC", sender: UIButton.self)
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Seed"
    }
}
