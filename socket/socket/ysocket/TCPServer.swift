//
//  TCPServer.swift
//  socket
//
//  Created by  lifirewolf on 15/8/22.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import Foundation
 class TCPServer: Socket{
    
    var delegate: TCPServerDelegate?
    
    var clients = [TCPClient]()
    
    let queue = dispatch_queue_create("fw.socket.tcpClientQueue", DISPATCH_QUEUE_CONCURRENT)
    
    func start() {
        
        var fd:Int32 = c_ytcpsocket_listen(self.addr, Int32(self.port))
        
        var isWorking = false
        if fd > 0 {
            self.fd = fd
            isWorking = true
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [weak self] in
                while self != nil {
                    
                    var buff: [Int8] = [Int8](count: 16, repeatedValue: 0x0)
                    var port:Int32 = 0
                    var clientfd: Int32 = c_ytcpsocket_accept(self!.fd!, &buff, &port)
                    
                    if clientfd > 0 {
                        
                        var addr = ""
                        if let tmp = String(CString: buff, encoding: NSUTF8StringEncoding) {
                            addr = tmp
                        }
                        
                        var tcpClient: TCPClient = TCPClient(addr: addr, port: Int(port))
                        tcpClient.fd = clientfd
                        
                        
                        self?.entertain(tcpClient)
                    }
                }
            }
        }
        
        self.delegate?.server(self, serverIsWorking: isWorking)
        
    }
    
    private func entertain(client: TCPClient) {
        
        self.clients.append(client)
        self.delegate?.server(self, connectedClient: client)
        
        dispatch_async(self.queue) { [weak self] in
            while self != nil {
                //读取数据
                if let d = client.read(1024*10) {
                    let data = NSData(bytes: d, length: d.count)
                    
                    self?.delegate?.server(self!, client: client, receivedData: data)
                }
                
            }
            
        }
    }
    
    func send(msg: String) {
        for client in self.clients {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let rst = client.send(str: msg)
            }
        }
    }
    
}

protocol TCPServerDelegate {
    func server(server: TCPServer, serverIsWorking isWorking: Bool)
    func server(server: TCPServer, connectedClient client: TCPClient)
    func server(server: TCPServer, client: TCPClient, receivedData data: NSData)
}


