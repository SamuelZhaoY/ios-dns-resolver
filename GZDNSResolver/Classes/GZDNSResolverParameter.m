//
//  GZDNSResolverParameter.m
//  Pods
//
//  Created by zhaoy on 21/8/16.
//
//

#import "GZDNSResolverParameter.h"

@implementation GZDNSMappingNode

+ (GZDNSMappingNode*)buildFromJSON:(NSDictionary*)jsonSource
{
    if (!jsonSource[@"rawIP"]) {
        return nil;
    }
    
    GZDNSMappingNode* node = [GZDNSMappingNode new];
    node.locale = jsonSource[@"locale"];
    node.rawIP  = jsonSource[@"rawIP"];
    node.version = [jsonSource[@"version"] integerValue];
    return node;
}

+ (NSDictionary*)toJSON:(GZDNSMappingNode*)node
{
    NSMutableDictionary* jsonSource = [NSMutableDictionary new];
    if (!node) {
        return nil;
    }
    
    if (!node.rawIP.length) {
        return nil;
    }
    
    if (node.rawIP) {
        [jsonSource setObject:node.rawIP
                       forKey:@"rawIP"];
    }
    
    if (node.locale) {
        [jsonSource setObject:node.locale
                       forKey:@"locale"];
    }
    
    if (node.version) {
        [jsonSource setObject:[NSString stringWithFormat:@"%lu",(unsigned long)node.version]
                       forKey:@"version"];
    }
    
    return [jsonSource copy];
}

@end

@implementation GZDNSMappingDomain

+ (GZDNSMappingDomain*)buildFromJSON:(NSDictionary*)jsonSource
{
    if (!jsonSource[@"hostName"]) {
        return nil;
    }
    
    // Update host name
    GZDNSMappingDomain* domain = [GZDNSMappingDomain new];
    domain.hostName = jsonSource[@"hostName"];
    domain.nodes = [NSMutableArray new];
    
    if (jsonSource[@"nodes"] && [jsonSource[@"nodes"] isKindOfClass:[NSArray class]]) {
        // Check about nodes
        for (NSDictionary* sourceDictionary in jsonSource[@"nodes"]) {
            GZDNSMappingNode* node = [GZDNSMappingNode buildFromJSON:sourceDictionary];
            if (node) {
                [domain.nodes addObject:node];
            }
        }
    }
    
    return domain;
}

+ (NSDictionary*)toJSON:(GZDNSMappingDomain*)domain
{
    
    if (!domain.hostName) {
        return nil;
    }
    
    NSMutableDictionary* mutableDictionary = [NSMutableDictionary new];
    
    if (domain.hostName) {
        [mutableDictionary setObject:domain.hostName
                              forKey:@"hostName"];
    }
    
    if (domain.nodes) {
        NSMutableArray* nodes = [NSMutableArray new];
        for (GZDNSMappingNode* node in domain.nodes) {
            NSDictionary* nodeJson = [GZDNSMappingNode toJSON:node];
            if (nodeJson) {
                [nodes addObject:nodeJson];
            }
        }
        
        [mutableDictionary setObject:nodes
                              forKey:@"nodes"];
    }
    
    return mutableDictionary;
}

@end
