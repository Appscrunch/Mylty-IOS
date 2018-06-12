//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import Alamofire

class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix("\(apiUrl)api/v1/") {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}

class ApiManager: NSObject, RequestRetrier {
    static let shared = ApiManager()
    var requestManager = Alamofire.SessionManager.default
    var token = String() {
        didSet {
            self.requestManager.adapter = AccessTokenAdapter(accessToken: token)
        }
    }
    var userID = String()
    var pushToken = String()
    
    
    override init() {
        super.init()
        
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 10 // seconds
//        configuration.timeoutIntervalForResource = 10
        
//        requestManager = Alamofire.SessionManager(configuration: configuration)
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            "api.multy.io": .pinCertificates(
//                certificates: ServerTrustPolicy.certificates(),
//                validateCertificateChain: true,
//                validateHost: true
//            ),
            shortURL : .disableEvaluation
            ]
        
        requestManager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        
        requestManager.retrier = self
        requestManager.adapter = AccessTokenAdapter(accessToken: token)
    }
    
//    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
//        if let urlString = urlRequest.url?.absoluteString {
//            if urlString.hasPrefix("\(apiUrl)server/config") || false {
//
//            }
//        }
//    }
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        print("\n\n\n\n\n\nretrier: \(request.request?.urlRequest?.url?.absoluteString)\n\n\n\n\n\n")
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            
            if userID.isEmpty {
                DispatchQueue.main.async {
                    DataManager.shared.getAccount { (acc, err) in
                        if acc != nil {
                            self.userID = acc!.userID
                        }
                        completion(false, 0.0)
                    }
                }
            }
            
            var params : Parameters = [ : ]
            
            params["userID"] = userID
            params["deviceID"] = "iOS \(UIDevice.current.name)"
            params["deviceType"] = 1
            params["pushToken"] = pushToken
            params["appVersion"] = ((infoPlist["CFBundleShortVersionString"] as! String) + " " + (infoPlist["CFBundleVersion"] as! String))
            
            self.auth(with: params, completion: { (dict, error) in
                completion(true, 0.2) // retry after 0.2 second
            })
        } else {
            completion(false, 0.0) // don't retry
        }
    }
    
    func getServerConfig(completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        requestManager.request("\(apiUrl)server/config", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion(response.result.value as? NSDictionary, nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func auth(with parameters: Parameters, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        requestManager.request("\(apiUrl)auth", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).debugLog().responseJSON { [weak self] (response: DataResponse<Any>) in
            
            print("----------------------AUTH")
            
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    if let token = (response.result.value as! NSDictionary)["token"] as? String {
                        DataManager.shared.updateToken(token)
                        self!.token = token
                    }
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func getAssets(completion: @escaping (_ holdings: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
            
        ]
        
        requestManager.request("\(apiUrl)api/v1/wallets", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func getTransactionInfo(transactionString: String, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        //MARK: USD
        requestManager.request("\(apiUrl)api/v1/gettransactioninfo/\(transactionString)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func addWallet(_ walletDict: Parameters, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        requestManager.request("\(apiUrl)api/v1/wallet", method: .post, parameters: walletDict, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                
                print("api/v1/wallet: \(response.result.value)")
                if response.result.value != nil {
                    if ((response.result.value! as! NSDictionary) ["code"] != nil) {
                        completion(NSDictionary(), nil)
                    } else {
                        completion(nil, nil)
                    }
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func deleteWallet(currencyID: NSNumber, networkID: NSNumber, walletIndex: NSNumber, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        let header: HTTPHeaders = [
            "Authorization" : "Bearer \(self.token)"
        ]
        requestManager.request("\(apiUrl)api/v1/wallet/\(currencyID)/\(networkID)/\(walletIndex)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    print(response.result.value)
                    completion(response.result.value as? NSDictionary, nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func addAddress(_ walletDict: Parameters, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        requestManager.request("\(apiUrl)api/v1/address", method: .post, parameters: walletDict, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func getFeeRate(currencyID: UInt32, networkID: UInt32, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        //MARK: USD
        requestManager.request("\(apiUrl)api/v1/transaction/feerate/\(currencyID)/\(networkID)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func getWalletsVerbose(completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        DataManager.shared.getAccount(completion: { (acc, err) in
            if acc != nil {
                self.token = acc!.token
            }
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        self.requestManager.request("\(apiUrl)api/v1/wallets/verbose", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
        })
    }
    
    func getOneWalletVerbose(walletID: NSNumber, blockchain: BlockchainType, completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        //MARK: add chain ID
        requestManager.request("\(apiUrl)api/v1/wallet/\(walletID)/verbose/\(blockchain.blockchain.rawValue)/\(blockchain.net_type)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func sendRawTransaction(walletID: NSNumber, transactionParameters: Parameters, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        //MARK: TESTNET - send currency is 1
        requestManager.request("\(apiUrl)api/v1/transaction/send/\(walletID)", method: .post, parameters: transactionParameters, encoding: JSONEncoding.default, headers: header).validate().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func sendHDTransaction(transactionParameters: Parameters, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        requestManager.request("\(apiUrl)api/v1/transaction/send", method: .post, parameters: transactionParameters, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                } 
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
            
        }
    }

    
    func getWalletOutputs(currencyID: UInt32, address: String, completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        let header: HTTPHeaders = [
            "Authorization" : "Bearer \(self.token)"
        ]
        
        requestManager.request("\(apiUrl)api/v1/outputs/spendable/\(currencyID)/\(address)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func getTransactionHistory(currencyID: NSNumber, networkID: NSNumber, walletID: NSNumber, completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        let header: HTTPHeaders = [
            "Authorization" : "Bearer \(self.token)"
        ]
        
        requestManager.request("\(apiUrl)api/v1/wallets/transactions/\(currencyID)/\(networkID)/\(walletID)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    func changeWalletName(currencyID: NSNumber, chainType: NSNumber, walletID: NSNumber, newName: String, completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(self.token)"
        ]
        
        let params = [
            "walletname"    : newName,
            "currencyID"    : currencyID.intValue,
            "walletIndex"   : walletID.intValue,
            "networkID"     : chainType.intValue
            ] as [String : Any]
        
        requestManager.request("\(apiUrl)api/v1/wallet/name", method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
    
    //MARK: add chain ID
    func getAddressBalance(currencyID: NSNumber, address: String, completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        let header: HTTPHeaders = [
            "Authorization" : "Bearer \(self.token)"
        ]
        
        requestManager.request("\(apiUrl)api/v1/address/balance/\(currencyID)/\(address)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion((response.result.value as! NSDictionary), nil)
                }
            case .failure(_):
                completion(nil, response.result.error)
                break
            }
        }
    }
}

