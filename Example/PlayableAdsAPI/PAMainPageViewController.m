//
//  PAMainPageViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PAMainPageViewController.h"
#import "PASupportFunctionViewController.h"
#import "PASettingsViewController.h"

@interface PAMainPageViewController ()

@end

@implementation PAMainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Function01"]) {
        PASupportFunctionViewController *functionVc = segue.destinationViewController;
        functionVc.functionType = kSupportFunctionType_01;
        
    } else if ([segue.identifier isEqualToString:@"Function02"]) {
        PASupportFunctionViewController *functionVc = segue.destinationViewController;
        functionVc.functionType = kSupportFunctionType_02;
    
    }else if ([segue.identifier isEqualToString:@"SettingsOverall"]) {
        PASettingsViewController *settingsVc = segue.destinationViewController;
        settingsVc.settingType = kSettingType_Overall;
        settingsVc.customTitle = @"Overall Settings";
    }
   
}

@end
