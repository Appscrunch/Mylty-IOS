//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import SocketIO
import AVFoundation

class Socket: NSObject {
    static let shared = Socket()
    var manager : SocketManager
    var socket : SocketIOClient
    
    //do exp timeout
    
    override init() {
        //dev:  6680
        //prod: 7780
        manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(false), .compress, .forceWebsockets(true), .reconnectAttempts(3), .forcePolling(false), .secure(false)])
        socket = manager.defaultSocket
    }
    
    func start() {
        if self.manager.status == .connected {
            return
        }
        DataManager.shared.getAccount { (account, error) in
            guard account != nil else {
                return
            }
            
            let header = ["userID": account!.userID,
                "deviceType": "\(account!.deviceType)",
                "jwtToken": account!.token]
            
            self.manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(false), .compress, .forceWebsockets(true), .reconnectAttempts(3), .forcePolling(false), .extraHeaders(header), .secure(false)])
            self.socket = self.manager.defaultSocket
            
            
            //        let socket = manager.defaultSocket
            
            self.socket.on(clientEvent: .connect) {data, ack in
                print("socket connected")
                self.getExchangeReq()
            }
            
//            self.socket.on(clientEvent: .disconnect) {data, ack in
//                print("socket disconnected")
//            }
            
            self.socket.on("exchangeAll") {data, ack in
//                print("-----exchangeAll: \(data)")
            }
            //"exchangeUpdate"
            self.socket.on("exchangeGdax") {data, ack in
//                print("-----exchangeUpdate: \(data)")
                if !(data is NSNull) {
                    //MARK: uncomment
                    DataManager.shared.currencyExchange.update(exchangeDict: data[0] as! NSDictionary)
                    
//                    let course = ((data[0] as! NSDictionary)["btc_usd"] as! NSNumber).doubleValue
//                    if course > 0 {
//                        exchangeCourse = course
//                    }
                }//"BTCtoUSD"
            }
            
            self.socket.on("TransactionUpdate") { data, ack in
                print("-----TransactionUpdate: \(data)")
                if data.first != nil {
                    let msg = data.first! as! [AnyHashable : Any]
                    NotificationCenter.default.post(name: NSNotification.Name("transactionUpdated"), object: nil, userInfo: msg)
                }
//                NotificationCenter.default.post(name: NSNotification.Name("transactionUpdated"), object: nil)
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            self.socket.on("btcTransactionUpdate") { data, ack in
                print("-----BTCTransactionUpdate: \(data)")
//                if data.first != nil {
//                    let msg = data.first! as! [AnyHashable : Any]
//                    NotificationCenter.default.post(name: NSNotification.Name("transactionUpdated"), object: nil, userInfo: msg)
//                }
                
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            self.socket.on("currentAmount") {data, ack in
                guard let cur = data[0] as? Double else { return }
                
                self.socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                    self.socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
            
            
            self.socket.connect()
        }
    }
    
    func restart() {
        stop()
        start()
    }
    
    func stop() {
        if self.socket.status == .connected{
            self.socket.disconnect()
        }
    }
    
    func getExchangeReq() {
        let abc = NSDictionary(dictionary: ["From": "USD",
                                            "To": "BTC"]).socketRepresentation()
        
        socket.emitWithAck("/getExchangeReq", abc).timingOut(after: 0) { (data) in
//            print("\n\n\n\n\n\n\n")
//            print(data)
//            print("\n\n\n\n\n\n\n")
        }
    }
    
    func becomeReceiver(receiverID : String, userCode : String, currencyID : Int, networkID : Int, address : String, amount : String) {
        print("becomeReceiver: userCode = \(userCode)\nreceiverID = \(receiverID)\ncurrencyID = \(currencyID)\nnetworkID = \(networkID)\naddress = \(address)\namount = \(amount)")
        socket.emitWithAck("event:receiver:on", with: [["userid" : receiverID, "usercode" : userCode, "currencyid" : currencyID, "networkid" : networkID, "address" : address,"amount" : amount ]]).timingOut(after: 1) { data in
            print(data)
        }
    }
    
    func stopReceive() {
        print("stopReceive")
        
        socket.emitWithAck("receiver:stop", with: []).timingOut(after: 1) { data in
            print(data)
        }
    }
    
    func becomeSender(nearIDs : [String]) {
        print("becomeSender: \(nearIDs)")
        self.socket.on("event:new:receiver") { (data, ack) in
            print(data)
            if data.first != nil {

            }
        }

        socket.emitWithAck("event:sender:check", with: [["ids" : nearIDs]]).timingOut(after: 1) { data in
            print(data)

            if data.first != nil {
                if let _ = data.first! as? String {
                    print("Error case")

                    return
                }

                let requestsData = data.first! as! [Dictionary<String, AnyObject>]

                var newRequests = [PaymentRequest]()
                for requestData in requestsData {
                    let dataDict = requestData
                    
                    let userID = dataDict["userid"] as! String
                    let userCode = dataDict["usercode"] as! String
                    let currencyID = dataDict["currencyid"] as! Int
                    let networkID = dataDict["networkid"] as! Int
                    let address = dataDict["address"] as! String
                    let amount = dataDict["amount"] as! String
                    let blockchain = Blockchain.init(rawValue: UInt32(currencyID))

                    let paymentRequest = PaymentRequest(sendAddress: address, userCode : userCode, currencyID: currencyID, sendAmount: BigInt(amount).cryptoValueString(for: blockchain), networkID: networkID, userID : userID)

                    newRequests.append(paymentRequest)
                    print(dataDict)
                }
                
                let userInfo = ["paymentRequests" : newRequests]
                NotificationCenter.default.post(name: NSNotification.Name("newReceiver"), object: nil, userInfo: userInfo)
            }
            
            
            
//            var newRequests = [PaymentRequest]()
//            for ID in nearIDs {
//                let paymentRequest = PaymentRequest(sendAddress: "asdkfhkergnkqejqiroghjdifgboi", userCode : ID, currencyID: 0, sendAmount: "187.99", networkID: 0, userID: "125781230491")
//                newRequests.append(paymentRequest)
//            }
//
//            let userInfo = ["paymentRequests" : newRequests]
//            NotificationCenter.default.post(name: NSNotification.Name("newReceiver"), object: nil, userInfo: userInfo)
        }
    }
    
    func stopSend() {
        print("stopSend")
        
        socket.emitWithAck("sender:stop", with: []).timingOut(after: 1) { data in
            print(data)
        }
    }
    
//    func txSend(params : [String: Any]) {
//        print("txSend : \(params)")
//
//        socket.emitWithAck("event:sendraw", with: [params]).timingOut(after: 1) { data in
//            print(data)
//
//            if let response = data.first! as? String {
//                var isSuccess = false
//                if response.hasPrefix("success") {
//                    isSuccess = true
//                }
//                let userInfo = ["data" : isSuccess]
//                NotificationCenter.default.post(name: NSNotification.Name("sendResponse"), object: nil, userInfo: userInfo)
//            }
//        }
//    }
}



