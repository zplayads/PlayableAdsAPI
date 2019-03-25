//
//  PAHeaderFile.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kSupportFunctionType_01 = 1,
    kSupportFunctionType_02,
} SupportFunctionType;

typedef enum : NSUInteger {
    kSettingType_Overall = 1,
    kSettingType_Function01,
    kSettingType_Function02,
    kSettingType_Vast
} SettingType;

typedef enum : NSUInteger {
    SettingValueIdentify_TestModel_Overall = 1,
    SettingValueIdentify_UIWebView_Overall,
    SettingValueIdentify_SupportMraid_01,
    SettingValueIdentify_SupportATag_01,
    SettingValueIdentify_PreRender_01,
    SettingValueIdentify_PreRender_02
} SettingValueIdentify;
