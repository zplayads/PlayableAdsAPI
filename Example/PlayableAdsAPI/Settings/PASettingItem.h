//
//  PASettingItem.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAHeaderFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface PASettingItem : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic , assign) BOOL isOn;
@property (nonatomic , assign) SettingValueIdentify valueIdentify;

@end

NS_ASSUME_NONNULL_END
