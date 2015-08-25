//
//  XSocket.swift
//  socket
//
//  Created by  lifirewolf on 15/8/22.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import Foundation

@asmname("ytcpsocket_connect") func c_ytcpsocket_connect(host:UnsafePointer<Int8>,port:Int32,timeout:Int32) -> Int32
@asmname("ytcpsocket_close") func c_ytcpsocket_close(fd:Int32) -> Int32
@asmname("ytcpsocket_send") func c_ytcpsocket_send(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32) -> Int32
@asmname("ytcpsocket_pull") func c_ytcpsocket_pull(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32) -> Int32
@asmname("ytcpsocket_listen") func c_ytcpsocket_listen(addr:UnsafePointer<Int8>,port:Int32)->Int32
@asmname("ytcpsocket_accept") func c_ytcpsocket_accept(onsocketfd:Int32,ip:UnsafePointer<Int8>,port:UnsafePointer<Int32>) -> Int32

class Socket {
    var addr: String
    var port: Int
    var fd: Int32?
    
    init(addr a:String,port p:Int){
        self.addr = a
        self.port = p
    }
    
    deinit {
        self.close()
    }
    
    func close() {
        if let fd:Int32 = self.fd {
            let rst = c_ytcpsocket_close(fd)
            self.fd = nil
        }
    }
    
}