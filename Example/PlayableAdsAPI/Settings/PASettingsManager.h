//
//  PASettingsManager.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PASettingsManager : NSObject

// overall
@property (nonatomic,assign) BOOL  isTestModel_Overall;
@property (nonatomic,assign) BOOL  isUIWebView_Overall;
//function 01
@property (nonatomic,assign) BOOL  isSupportMraid_01;
@property (nonatomic,assign) BOOL  isSupportATag_01;
@property (nonatomic,assign) BOOL  isPreRender_01;
@property (nonatomic ,assign) BOOL isLoadHTMLorURL_01;

// function 02
@property (nonatomic,assign) BOOL  isPreRender_02;
@property (nonatomic ,assign) BOOL isLoadHTMLorURL_02;
@property (nonatomic,assign) BOOL isSupportMraid_02;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
