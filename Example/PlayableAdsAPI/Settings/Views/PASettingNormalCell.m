//
//  PASettingNormalCell.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PASettingNormalCell.h"
#import "PASettingItem.h"
#import "PASettingsManager.h"

@interface PASettingNormalCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;
@property (nonatomic) PASettingItem  *currentItem;

@end

@implementation PASettingNormalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSettingItem:(PASettingItem *)item{
    self.titleLab.text = item.title;
    self.switchControl.on = item.isOn;
    self.currentItem = item;
    
}
- (IBAction)handleSwitch:(UISwitch *)sender {
    
    switch (self.currentItem.valueIdentify) {
        case SettingValueIdentify_TestModel_Overall:
            [PASettingsManager sharedManager].isTestModel_Overall = sender.on;
            break;
        case SettingValueIdentify_UIWebView_Overall:
            [PASettingsManager sharedManager].isUIWebView_Overall = sender.on;
            break;
        case SettingValueIdentify_SupportMraid_01:
            [PASettingsManager sharedManager].isSupportMraid_01 = sender.on;
            break;
        case SettingValueIdentify_SupportATag_01:
            [PASettingsManager sharedManager].isSupportATag_01 = sender.on;
            break;
        case SettingValueIdentify_PreRender_01:
            [PASettingsManager sharedManager].isPreRender_01 = sender.on;
            break;
        case SettingValueIdentify_PreRender_02:
            [PASettingsManager sharedManager].isPreRender_02 = sender.on;
            break;
            
        default:
            break;
    }
}


@end
