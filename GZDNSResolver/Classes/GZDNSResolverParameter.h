//
//  GZDNSResolverParameter.h
//  Pods
//
//  Created by zhaoy on 21/8/16.
//
//

#import <Foundation/Foundation.h>
#import "GZDNSPolicy.h"

@interface GZDNSMappingNode : NSObject

@property (nonatomic, strong) NSString* locale;         // region
@property (nonatomic, strong) NSString* rawIP;          // raw IP address
@property (nonatomic, assign) int requestFailedCount;   // accumulated request failed count
@property (nonatomic, assign) GZDNS_IP_Version version;// current ip version of the mapping node

// Builder method from json
+ (GZDNSMappingNode*)buildFromJSON:(NSDictionary*)jsonSource;

+ (NSDictionary*)toJSON:(GZDNSMappingNode*)node;

@end

@interface GZDNSMappingDomain : NSObject

@property (nonatomic, strong) NSString* hostName;       // host name
@property (nonatomic, strong) NSMutableArray* nodes;           // All ip nodes

// Builder method from json
+ (GZDNSMappingDomain*)buildFromJSON:(NSDictionary*)jsonSource;

+ (NSDictionary*)toJSON:(GZDNSMappingDomain*)domain;

@end