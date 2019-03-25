//
//  PASupportFunctionViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PASupportFunctionViewController.h"
#import "PARenderViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIView+Toast.h"

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

- (NSDictionary *)handleRequestParams{
    NSString *requestText = self.requestTextView.text;
    // 去除首尾空格和换行
    requestText = [requestText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    requestText = [requestText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (requestText.length == 0) {
        [self showResultLog:@"request params is nil !!!"];
        return nil;
    }
    NSData *objectData = [requestText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    if (error || !parameters) {
        [self showResultLog:@"Request parameter is not a standard json string"];
        return nil;
    }
    
    if ([parameters[@"support_function"] intValue] != self.functionType) {
        [self showResultLog:@"Request support_function is error"];
        
        return nil;
    }
    
    return parameters;
    
}

#pragma mark: IBAction

- (IBAction)requestAPIAction:(UIButton *)sender {
    
    NSString *requestLog = [NSString stringWithFormat:@"request Supprt Function = %zd .",self.functionType];
    
    [self showResultLog:requestLog];
    
    NSDictionary *param =  [self handleRequestParams];
    
    if (!param) {
        
        return;
    }
    
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[PANetworkManager sharedManager] requestAPIDataSpport:param  success:^(PAAPIModel * _Nonnull apiModel) {
        [SVProgressHUD dismiss];
        if (apiModel.ads.count == 0) {
            [weakSelf showResultLog:@"load fail..."];
            return ;
        }
        PAAdsModel *model = apiModel.ads[0];
        model.support_function = weakSelf.functionType;
        
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [weakSelf showResultLog:@"load fail..."];
        });
    }];
    
}
- (IBAction)PresentHtmlAction:(UIButton *)sender {
    NSString *presentLog = [NSString stringWithFormat:@"present Supprt Function = %zd .",self.functionType];
    
    [self showResultLog:presentLog];
}

#pragma mark: private
- (void)showResultLog:(NSString *)logText{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.resultTextView.layoutManager.allowsNonContiguousLayout = NO;
        NSString *oldLog = weakSelf.resultTextView.text;
        NSString *text = [NSString stringWithFormat:@"%@\n%@", oldLog, logText];
        if (oldLog.length == 0) {
            text = [NSString stringWithFormat:@"%@", logText];
        }
        [weakSelf.resultTextView scrollRangeToVisible:NSMakeRange(text.length, 1)];
        weakSelf.resultTextView.text = text;
    });
}

@end
