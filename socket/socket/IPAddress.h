//
//  IPAddress.h
//  socket
//
//  Created by  lifirewolf on 15/8/21.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

#ifndef __socket__IPAddress__
#define __socket__IPAddress__

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#import <Foundation/Foundation.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface IPAddress : NSObject{
    
}

- (NSString *)getIPAddress:(BOOL)preferIPv4;

- (NSDictionary *)getIPAddresses;

@end

#endif
