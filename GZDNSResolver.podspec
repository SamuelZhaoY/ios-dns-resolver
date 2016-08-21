
Pod::Spec.new do |s|
  s.name             = 'GZDNSResolver'
  s.version          = '0.1.0'
  s.summary          = 'Host name resolving utility for iOS'

  s.description      = <<-DESC
    This project provides a set of utility classes which helps to resolve host name to corresponding ip addresses.
    At the same time, a IP to host cache table is also provided. With the help of this utility, network request can save up host name resolving time for each network request.

    - DNS resolving
    - Host name to raw IP caching
    - Support both IPv6 & IPv4

                       DESC

  s.homepage         = 'https://github.com/SamuelZhaoY/iOS-DNSResolver'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zy.zhao' => 'zhaoy.samuel@gmail.com' }
  s.source           = { :git => 'https://github.com/SamuelZhaoY/iOS-DNSResolver.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'GZDNSResolver/Classes/*'
  s.public_header_files = 'GZDNSResolver/Classes/GZDNSResolver.h'

end
