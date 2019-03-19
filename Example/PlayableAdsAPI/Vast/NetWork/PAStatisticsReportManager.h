//
//  PAStatisticsReportManager.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/19.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PAStatisticsReportManager : NSObject

+ (instancetype)shareManager;

- (void)sendTrackingUrl:(NSString *)trackingUrl;
- (void)sendTrackers:(NSArray *)trackers;

@end

NS_ASSUME_NONNULL_END
