# Objective C NSHash

> NSHash adds hashing methods to NSString and NSData.

[![Build Status](https://travis-ci.org/jerolimov/NSHash.svg)](https://travis-ci.org/jerolimov/NSHash)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/NSHash.svg)](https://img.shields.io/cocoapods/v/NSHash.svg)
[![Supported Platforms](https://img.shields.io/cocoapods/p/NSHash.svg?style=flat)](http://cocoadocs.org/docsets/NSHash)

## How to use it

Copy the NSHash class into your project or add this line to your [Podfile](http://cocoapods.org/):

```ruby
pod 'NSHash', '~> 1.0.2'
```

## Quick API overview

Import the the category class you need:

```objectivec
#import <NSHash/NSString+NSHash.h>
#import <NSHash/NSData+NSHash.h>
```

After that you can call `MD5`, `SHA1` and `SHA256` on any `NSString`:

```objectivec
NSString* string = @"NSHash";
NSLog(@"MD5:    %@", [string MD5]);
NSLog(@"SHA1:   %@", [string SHA1]);
NSLog(@"SHA256: %@", [string SHA256]);
```

This will return a new `NSString` with a hex code transformed version of the hash:

```objectivec
MD5:    ccbe85c2011c5fe3da7d760849c4f99e
SHA1:   f5b17712c5d31ab49654b0baadf699561958d750
SHA256: 84423607efac17079369134460239541285d5ff40594f9b8b16f567500162d2e
```

Or call `MD5`, `SHA1` and `SHA256` on any `NSData`:

```objectivec
NSData* data = [@"NSHash" dataUsingEncoding:NSUTF8StringEncoding];
NSLog(@"MD5:    %@", [data MD5]);
NSLog(@"SHA1:   %@", [data SHA1]);
NSLog(@"SHA256: %@", [data SHA256]);
```

Which will return the `NSData` with the hash as bytes without the hex transformation:

```objectivec
MD5:    <ccbe85c2 011c5fe3 da7d7608 49c4f99e>
SHA1:   <f5b17712 c5d31ab4 9654b0ba adf69956 1958d750>
SHA256: <84423607 efac1707 93691344 60239541 285d5ff4 0594f9b8 b16f5675 00162d2e>
```
