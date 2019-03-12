//
//  NSString+YumiURLEncodedString.m
//  Pods
//
//  Created by 甲丁乙_ on 2017/5/24.
//
//

#import "NSString+YumiURLEncodedString.h"

@implementation NSString (YMURLEncodedString)

- (NSString *)YumiURLEncodedString {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
    return result;
}

@end
