//
//  GZDNSResolver.h
//  Pods
//
//  Created by zhaoy on 21/8/16.
//
//

#import <Foundation/Foundation.h>

@class GZDNSPolicy;
@interface GZDNSResolver : NSObject

/**
 * Singleton
 */
+ (instancetype)sharedInstance;

#pragma mark - initialize & config

/**
 * Load dns configuration from url.
 * url can be either local or a remote address
 */
- (void)loadDNSConfigFromURL:(NSURL*)url
                onCompletion:(void (^)(BOOL isSuccess))callback;

/**
 *  Config the current dns policy
 */
- (void)updateDNSPolicy:(GZDNSPolicy*)policy;

#pragma mark - dns management

/**
 *  Update DNS mapping node of url, will resolve ip protocol automaticallly
 */
- (void)updateDNSMapping:(NSString*)ip
                    host:(NSString*)host;


/**
 *  Resolve host and provide essential cache
 *
 *  @param host host name
 */
- (void)resolveHostAndCache:(NSString*)host;


/**
 *  Invalidate dns mapping by the given ip
 */
- (void)invalidateIP:(NSString*)ip;

/**
 *  Invalidate dns mapping of a specified hostName
 */
- (void)invalidateDNSOnHost:(NSString*)host;

/**
 *  Reset the current dns mapping
 */
- (void)resetDNSMapping;

#pragma mark - dns resolve

/**
 * Resolve an ip address from originated url, if no ip found for the corresponding url, return the host name of the url object
 */
- (NSString*)resolveIPFromURL:(NSURL*)originalURL;

@end
