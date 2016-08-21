//
//  GZDNSPolicy.h
//  Pods
//
//  Created by zhaoy on 21/8/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GZDNSResolveStrategy)
{
    checkDefault    = 0,        // Check nothing
    checkLocale     = 1 << 0,   // The strategy should contain locale check
    checkIPV        = 1 << 1,   // The strategy should contain ipv check
    checkSuccessRate= 1 << 2,   // The strategy should review the past failure count of the ip addresses, if ping fails, should give up
};

typedef NS_ENUM(NSUInteger, GZDNS_IP_Version)
{
    unset = 0,  // unclarified
    ipv_4 = 4,  // ipv4
    ipv_6 = 6,  // ipv6
};

@interface GZDNSPolicy : NSObject

// Current country locale
@property NSString* countryCode;

// IP selected ip version
@property GZDNS_IP_Version dominatingIPProtocol;

// DNS resolve strategy
@property GZDNSResolveStrategy dnsResolveStrategy;

@end

