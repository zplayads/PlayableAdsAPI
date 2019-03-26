//
//  PASettingsViewController.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAHeaderFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface PASettingsViewController : UIViewController

@property (nonatomic , assign) SettingType settingType;
@property (nonatomic) NSString  *customTitle;

@end

NS_ASSUME_NONNULL_END
