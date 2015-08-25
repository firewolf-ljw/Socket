//
//  TCPClient.swift
//  socket
//
//  Created by  lifirewolf on 15/8/22.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import Foundation

class TCPClient: Socket {
    
    /*
    * read data with expect length
    */
    func read(expectlen:Int) -> [UInt8]? {
        if let fd:Int32 = self.fd {
            var buff: [UInt8] = [UInt8](count:expectlen,repeatedValue:0x0)
            var readLen: Int32 = c_ytcpsocket_pull(fd, &buff, Int32(expectlen))
            if readLen <= 0 {
                return nil
            }
            var rs = buff[0...Int(readLen-1)]
            var data: [UInt8] = Array(rs)
            return data
        }
        return nil
    }
    
    var delegate: TCPClientDelegate?
    
    func connectServer(timeout t:Int) {
        
        var rs:Int32 = c_ytcpsocket_connect(self.addr, Int32(self.port),Int32(t))
        
        var state: ClientState
        if rs > 0 {
            self.fd = rs
            state = ClientState.Connected
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [weak self] in
                while self != nil {
                    //读取数据
                    if let d = self!.read(1024*10) {
                        let data = NSData(bytes: d, length: d.count)
                        self?.delegate?.client(self!, receivedData: data)
                    }
                }
            }
            
        } else {
            switch rs {
            case -1:
                state = ClientState.Failed
            case -2:
                state = ClientState.Closed
            case -3:
                state = ClientState.TimeOut
            default:
                state = ClientState.Unknowed
            }
        }
        
        self.delegate?.client(self, connectSververState: state)
        
    }
    
    func send(data d:[UInt8]) -> Bool {
        var flag: Bool = false
        
        if let fd:Int32 = self.fd {
            var sendsize:Int32 = c_ytcpsocket_send(fd, d, Int32(d.count))
            if Int(sendsize) == d.count {
                flag = true
            }
        }
        return flag
    }
    
    func send(str s:String) -> Bool {
        var flag: Bool = false
        
        if let fd:Int32 = self.fd {
            var sendsize:Int32 = c_ytcpsocket_send(fd, s, Int32(strlen(s)))
            if sendsize == Int32(strlen(s)) {
                flag = true
            }
        }
        
        return flag
    }

    func send(data d:NSData) -> Bool {
        var flag: Bool = false
        
        if let fd:Int32 = self.fd {
            var buff:[UInt8] = [UInt8](count:d.length,repeatedValue:0x0)
            d.getBytes(&buff, length: d.length)
            var sendsize:Int32 = c_ytcpsocket_send(fd, buff, Int32(d.length))
            if sendsize == Int32(d.length){
                flag = true
            }
        }
        
        return flag
    }
    
}

protocol TCPClientDelegate {
    func client(client: TCPClient, connectSververState state: ClientState)
    func client(client: TCPClient, receivedData data: NSData)
}

enum ClientState: Int {
    
    case Failed = -1
    case Closed = -2
    case TimeOut = -3
    case Unknowed = 0
    case Connected = 1
}




