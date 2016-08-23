# GZDNSResolver

[![CI Status](http://img.shields.io/travis/SamuelZhaoY/iOS-DNSResolver.svg?style=flat)](https://travis-ci.org/SamuelZhaoY/iOS-DNSResolver)
[![Version](https://img.shields.io/cocoapods/v/GZDNSResolver.svg?style=flat)](http://cocoapods.org/pods/GZDNSResolver)
[![License](https://img.shields.io/cocoapods/l/GZDNSResolver.svg?style=flat)](http://cocoapods.org/pods/GZDNSResolver)
[![Platform](https://img.shields.io/cocoapods/p/GZDNSResolver.svg?style=flat)](http://cocoapods.org/pods/GZDNSResolver)

GZDNSResolver is an iOS local client tool which helps user to resolve and cache corresponding IP address for each host name. With the following feature:

- Support IPv4 & IPv6 address resolving
- Support importing host name - IP table mapping via json file. (Refer to project test cases)
- Support exporting host name - IP table mapping to local storable NSData.
- By filtering Country Code, Network condition and IP version, helps user to choose out best possible raw IP address for each host name.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Recover from json

Given the json:
```javascript
{
    "google.com":
    {
        "hostName":"google.com",
        "nodes":[
                 {
                 "locale":"US",
                 "rawIP":"126.0.0.1",
                 "version":"4"
                 },{
                 "locale":"CN",
                 "rawIP":"126.0.2.1",
                 "version":"4"
                 },{
                 "locale":"CN",
                 "rawIP":"126.0.2.1",
                 "version":"4"
                 }
                 ]
    },
    "facebook.com":
    {
        "hostName":"facebook.com",
        "nodes":[
                 {
                 "locale":"US",
                 "rawIP":"2001:db8::1",
                 "version":"4"
                 },{
                 "locale":"CN",
                 "rawIP":"2001:db8:0::2",
                 "version":"4"
                 },{
                 "locale":"CN",
                 "rawIP":"fdda:5cc1:23:4::1f",
                 "version":"4" 
                 }
                 ]
    }
}
```
Init with file url
```objc
// File url can be both refering to lcoal dir or remote file url
[[GZDNSResolver sharedInstance] loadDNSConfigFromURL:fileUrl
                                             onCompletion:^(BOOL isSuccess) {
                                             }];
```

### Manage host - ip mapping

Map a IP address to the host name. One host name can be mapped to multiple IP address
```objc
[[GZDNSResolver sharedInstance] updateDNSMapping:@"10.28.241.16"
                                                 host:@"facebook.com"];
```

Remove the IP address from a host mapping
```objc
[[GZDNSResolver sharedInstance] invalidateIP:@"10.28.241.16"];
```

Invalidate the host and all the relate IP addresses
```objc
[[GZDNSResolver sharedInstance] invalidateDNSOnHost:@"facebook.com"];
```

### IP address resolving

```objc
NSString* ip = [[GZDNSResolver sharedInstance] resolveIPFromURL:[NSURL URLWithString:@"https://facebook.com"]];
```

## Installation

### Cocoapods
GZDNSResolver is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GZDNSResolver"
```

### Carthage

github "SamuelZhaoY/iOS-ToastWidget"



## Author

zy.zhao, zhaoy.samuel@gmail.com

## License

GZDNSResolver is available under the MIT license. See the LICENSE file for more info.
