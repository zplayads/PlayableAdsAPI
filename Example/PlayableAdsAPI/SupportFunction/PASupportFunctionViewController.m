//
//  PASupportFunctionViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PASupportFunctionViewController.h"

@interface PASupportFunctionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *requestTextView;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation PASupportFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTitle];
    
}

- (void)setupTitle{
    switch (self.functionType) {
        case kSupportFunctionType_01:
            self.title = @"Supprt Function = 1";
            break;
        case kSupportFunctionType_02:
            self.title = @"Supprt Function = 2";
            break;
            
        default:
            break;
    }
}

@end
