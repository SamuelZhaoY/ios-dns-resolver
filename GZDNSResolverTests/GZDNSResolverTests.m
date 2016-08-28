//
//  GZDNSResolverTests.m
//  GZDNSResolverTests
//
//  Created by zhaoy on 23/8/16.
//  Copyright © 2016 com.gz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GZDNSResolver.h"

@interface GZDNSResolverTests : XCTestCase

@end

@implementation GZDNSResolverTests

- (void)setUp {
    [super setUp];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    NSString* localConfigFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"LocalConfig" ofType:@"json"];
    NSURL* fileUrl = [NSURL fileURLWithPath:localConfigFilePath];
    
    [[GZDNSResolver sharedInstance] loadDNSConfigFromURL:fileUrl
                                             onCompletion:^(BOOL isSuccess) {
                                                 XCTAssert(isSuccess, @"initialization failure");
                                                 dispatch_semaphore_signal(sem);
                                             }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLocalInitialization
{
    // Local initialization
    XCTestExpectation *expectation = [self expectationWithDescription:@"test dns inialize done"];
    
    
    NSString* localConfigFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"LocalConfig" ofType:@"json"];
    NSURL* fileUrl = [NSURL fileURLWithPath:localConfigFilePath];
    
    [[GZDNSResolver sharedInstance] loadDNSConfigFromURL:fileUrl
                                             onCompletion:^(BOOL isSuccess) {
                                                 XCTAssert(isSuccess, @"initialization failure");
                                                 [expectation fulfill];
                                             }];
    
    [self waitForExpectationsWithTimeout:20
                                 handler:nil];
}

- (void)testRemoteConfigLoading
{
    // Remote intialization
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test dns inialize done"];
    
    NSURL* fileUrl = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/13757032/LocalConfig.json"];
    
    [[GZDNSResolver sharedInstance] loadDNSConfigFromURL:fileUrl
                                             onCompletion:^(BOOL isSuccess) {
                                                 XCTAssert(isSuccess, @"initialization failure");
                                                 [expectation fulfill];
                                             }];
    
    [self waitForExpectationsWithTimeout:20
                                 handler:nil];
    
}


- (void)testDynamicHostNameResolving
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"test dns resolve done"];
    
    // Resolve host name asynchronously
    [[GZDNSResolver sharedInstance] resolveHostAndCache:@"google.com" withCompletionCall:^(BOOL isSuccess) {
        NSString* ip = [[GZDNSResolver sharedInstance] resolveIPFromURL:[NSURL URLWithString:@"https://google.com"]];
        NSLog(@"resolve raw ip address for google: %@",ip);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4000
                                 handler:nil];
}

- (void)testUpdateDNSMapping
{
    // Set dns mapping & validate the dns resolving
    [[GZDNSResolver sharedInstance] updateDNSMapping:@"10.28.241.16"
                                                 host:@"alipay.com"];
    
    // Resolving
    NSString* ip = [[GZDNSResolver sharedInstance] resolveIPFromURL:[NSURL URLWithString:@"https://alipay.com"]];
    XCTAssert([ip isEqualToString:@"10.28.241.16"]);
}

- (void)testDNSInvalidateWithIP
{
    // Test dns invalidate with ip
    // Set dns mapping & validate the dns resolving
    [[GZDNSResolver sharedInstance] updateDNSMapping:@"10.28.241.16"
                                                 host:@"alipay.com"];
    
    // Set dns mapping & validate the dns resolving
    [[GZDNSResolver sharedInstance] updateDNSMapping:@"10.28.241.13"
                                                 host:@"alipay.com"];
    
    [[GZDNSResolver sharedInstance] invalidateIP:@"10.28.241.16"];
    
    NSString* ip = [[GZDNSResolver sharedInstance] resolveIPFromURL:[NSURL URLWithString:@"https://alipay.com"]];
    XCTAssert(![ip isEqualToString:@"10.28.241.16"]);
}

- (void)testDNSInvalidateDNSHost
{
    // Test dns invalidate with host
    [[GZDNSResolver sharedInstance] updateDNSMapping:@"10.28.241.16"
                                                 host:@"alipay.com"];
    
    [[GZDNSResolver sharedInstance] invalidateDNSOnHost:@"alipay.com"];
    
    NSString* ip = [[GZDNSResolver sharedInstance] resolveIPFromURL:[NSURL URLWithString:@"https://alipay.com"]];
    XCTAssert([ip isEqualToString:@"alipay.com"]);
}
@end
