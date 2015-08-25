//
//  TCPClientViewController.swift
//  socket
//
//  Created by  lifirewolf on 15/8/22.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

class TCPClientViewController: UIViewController {
    
    @IBOutlet weak var serverIP: UITextField!
    
    @IBOutlet weak var serverPort: UITextField!
    
    @IBOutlet weak var sendedMsg: UITextField!
    
    @IBOutlet weak var receivedMsg: UILabel!
    
    override func viewDidLoad() {
        self.receivedMsg.text = nil
        
        self.serverIP.delegate = self
        self.serverPort.delegate = self
        self.sendedMsg.delegate = self
    }
    
    var client: TCPClient!
    
    @IBAction func conn(sender: UIButton) {
        if self.client != nil {
            self.client.close()
        }
        self.client = TCPClient(addr: self.serverIP.text!, port: self.serverPort.text.toInt()!)
        self.client.delegate = self
        
        self.client.connectServer(timeout: 10)
        
    }
    
    @IBAction func send(sender: UIButton) {
        let rst = self.client.send(str: self.sendedMsg.text!)
        
        println("send data: \(rst)")
    }
    
    func alert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

extension TCPClientViewController: TCPClientDelegate {
    func client(client: TCPClient, connectSververState state: ClientState) {
        print(state)
        alert("Alert", msg: "connect to server: \(state)")
    }
    
    func client(client: TCPClient, receivedData data: NSData) {
        if let msg = NSString(data: data, encoding: NSUTF8StringEncoding) {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.receivedMsg.text = "\(self!.serverIP.text!):\(msg)"
            }
        }
    }
}

extension TCPClientViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

