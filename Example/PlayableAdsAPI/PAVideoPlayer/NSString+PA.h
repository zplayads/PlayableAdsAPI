//
//  NSString+MD5.h
//  PlayableAdsAPI
//
//  Created by Michael Tang on 2019/3/20.
//

#import <Foundation/Foundation.h>

@interface NSString (PA)

- (NSString *)stringToMD5;
+ (NSString *)calculateTimeWithTimeFormatter:(long long)timeSecond;

@end
