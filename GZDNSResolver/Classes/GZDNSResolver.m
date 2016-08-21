//
//  GZDNSResolver.m
//  Pods
//
//  Created by zhaoy on 21/8/16.
//
//

#import "GZDNSResolver.h"
#import "GZDNSResolverParameter.h"
#import "GZDNSPolicy.h"
#include <arpa/inet.h>

@interface GZDNSResolver()

// DNS cache table: host name : GZDNSMappingDomain
@property (nonatomic, strong) NSMutableDictionary* dnsCacheTable;

@property (nonatomic, strong) GZDNSPolicy* policy;

@end

@implementation GZDNSResolver

+ (instancetype)sharedInstance
{
    static GZDNSResolver* resolver;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resolver = [GZDNSResolver new];
        resolver.dnsCacheTable = [NSMutableDictionary new];
    });
    
    return resolver;
}

#pragma mark - initialize & config

/**
 * Load dns configuration from url.
 * url can be either local or a remote address
 */
- (void)loadDNSConfigFromURL:(NSURL*)url
                onCompletion:(void (^)(BOOL isSuccess))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self.dnsCacheTable) {
            
            [_dnsCacheTable removeAllObjects];
            
            NSData *configData = [NSData dataWithContentsOfURL:url];
            if (configData) {
                
                NSError* error = nil;
                NSDictionary* rawDict = [NSJSONSerialization
                                         JSONObjectWithData:configData
                                         options:kNilOptions
                                         error:&error];
                
                if (!rawDict || error) {
                    if (callback) {
                        callback(NO);
                    }
                } else {
                    for (NSString* hostName in [rawDict allKeys]) {
                        
                        GZDNSMappingDomain* domain = [GZDNSMappingDomain buildFromJSON:[rawDict objectForKey:hostName]];
                        if (domain && hostName) {
                            [_dnsCacheTable setObject:domain
                                               forKey:hostName];
                        }
                    }
                    
                    if (callback) {
                        callback(YES);
                    }
                }
                
            } else {
                if (callback) {
                    callback(NO);
                }
            }
        }
    });
}

/**
 *  Config the current dns policy
 */
- (void)updateDNSPolicy:(GZDNSPolicy*)policy
{
    self.policy = policy;
}

#pragma mark - dns management

/**
 *  Update DNS mapping node of url
 */
- (void)updateDNSMapping:(NSString*)ip
                    host:(NSString*)host
{
    
    if (!host.length) {
        return;
    }
    
    const char *utf8 = [ip UTF8String];
    GZDNS_IP_Version version = unset;
    
    // Check valid IPv4.
    struct in_addr dst;
    int success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    if (success != 1) {
        // Check valid IPv6.
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
        
        if (success) {
            version = ipv_6;
        }
    } else  {
        version = ipv_4;
    }
    
    GZDNSMappingNode* node = [GZDNSMappingNode new];
    node.rawIP = ip;
    node.version = version;
    node.requestFailedCount = 0;
    
    @synchronized (_dnsCacheTable) {
        GZDNSMappingDomain* domain = _dnsCacheTable[host];
        if (!_dnsCacheTable[host]) {
            domain = [GZDNSMappingDomain new];
            domain.hostName = host;
            domain.nodes = [NSMutableArray new];
            [_dnsCacheTable setObject:domain forKey:host];
        }
        
        BOOL needUpdate = YES;
        for (GZDNSMappingNode* existingNode in domain.nodes) {
            if ([node.rawIP isEqualToString:existingNode.rawIP]) {
                needUpdate = NO;
                break;
            }
        }
        
        if (needUpdate) {
            [domain.nodes addObject:node];
        }
    }
}

/**
 *  Invalidate dns mapping by the given ip
 */
- (void)invalidateIP:(NSString*)ip
{
    for (GZDNSMappingDomain* domain in [_dnsCacheTable allValues]) {
        NSMutableArray* tempNodes = [domain.nodes mutableCopy];
        for (GZDNSMappingNode* node in tempNodes) {
            if ([node.rawIP isEqualToString:ip]) {
                @synchronized (_dnsCacheTable) {
                    [domain.nodes removeObject:node];
                }
            }
        }
    }
}

/**
 *  Invalidate dns mapping of a specified hostName
 */
- (void)invalidateDNSOnHost:(NSString*)host
{
    NSMutableArray* tempDomains = [[_dnsCacheTable allValues] mutableCopy];
    for (GZDNSMappingDomain* domain in tempDomains) {
        if ([domain.hostName isEqualToString:host]) {
            @synchronized (_dnsCacheTable) {
                [_dnsCacheTable removeObjectForKey:host];
            }
        }
    }
}

/**
 *  Reset dns mapping
 */
- (void)resetDNSMapping
{
    @synchronized (_dnsCacheTable) {
        [_dnsCacheTable removeAllObjects];
    }
}

#pragma mark - dns resolve

- (NSString*)resolveIPFromURL:(NSURL*)originalURL
{
    // Input check
    if (!originalURL.host) {
        return originalURL.host;
    }
    
    // Based on DNS strategy filter out corresponding IP
    NSMutableArray* candidateIPs = [NSMutableArray new];
    GZDNSMappingDomain* domain = _dnsCacheTable[originalURL.host];
    if (!domain) {
        return originalURL.host;
    }
    
    candidateIPs = [domain.nodes mutableCopy];
    
    // Filter by locale information
    if (self.policy.dnsResolveStrategy & checkLocale) {
        NSLocale *currentLocale = [NSLocale currentLocale];
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        
        for (GZDNSMappingNode* node in domain.nodes) {
            if (![node.locale isEqualToString:countryCode]) {
                [candidateIPs removeObject:node];
            }
        }
    }
    
    // Filter by IPV information
    if (self.policy.dnsResolveStrategy & checkIPV) {
        
        for (GZDNSMappingNode* node in domain.nodes) {
            if (node.version != self.policy.dominatingIPProtocol) {
                [candidateIPs removeObject:node];
            }
        }
    }
    
    // Empty remaining check
    if (!candidateIPs.count) {
        return originalURL.host;
    }
    
    // Filter by failureCount information
    if (self.policy.dnsResolveStrategy & checkSuccessRate) {
        [candidateIPs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [@(((GZDNSMappingNode*)obj1).requestFailedCount) compare:@(((GZDNSMappingNode*)obj2).requestFailedCount)];
        }];
    }
    
    // Make random pick from array
    return ((GZDNSMappingNode*)[candidateIPs firstObject]).rawIP;
}

@end
