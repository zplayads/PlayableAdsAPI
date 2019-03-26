//
//  PASupportFunctionViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PASupportFunctionViewController.h"
#import "PAWKWebViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIView+Toast.h"
#import "PANetworkManager.h"
#import "PASettingsViewController.h"
#import "PASettingsManager.h"
#import "PAUnifiedRenderWebView.h"
#import "PAUIWebViewController.h"

@interface PASupportFunctionViewController ()<PARenderVcDelegate>

@property (weak, nonatomic) IBOutlet UITextView *requestTextView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (nonatomic) UIViewController<PAUnifiedRenderWebView>  *renderVc;

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
    [self hideKeyBoard];
    
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
        [weakSelf loadHtml:model];
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [weakSelf showResultLog:@"load fail..."];
        });
    }];
    
}
- (IBAction)PresentHtmlAction:(UIButton *)sender {
    
    [self hideKeyBoard];
    
    if (!self.renderVc) {
        [self showResultLog:@"render vc is nil "];
        return;
    }
    
     NSString *presentLog = [NSString stringWithFormat:@"present Supprt Function = %zd .",self.functionType];
    [self showResultLog:presentLog];
    
   
     [self presentViewController:self.renderVc animated:YES completion:nil];
}

//prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SettingsId"]) {
        PASettingsViewController *settingVc= segue.destinationViewController;
        settingVc.customTitle = @"Independent Settings";
        
        if (self.functionType == kSupportFunctionType_01) {
            settingVc.settingType = kSettingType_Function01;
        }
        if (self.functionType == kSupportFunctionType_02) {
            settingVc.settingType = kSettingType_Function02;
        }
        
    }
}

#pragma mark: render
- (void)loadHtml:(PAAdsModel *)adModel {
    [self showResultLog:@"load html with response html"];
    UIViewController<PAUnifiedRenderWebView> *renderVc = nil;
    if ([PASettingsManager sharedManager].isUIWebView_Overall) {
        renderVc = [[PAUIWebViewController alloc] init];
    }else{
        renderVc = [[PAWKWebViewController alloc] init];
    }
    [renderVc setDelegate:self];
    [renderVc setAdModel:adModel];
    [renderVc setFunctionType:self.functionType];
   
    self.renderVc = renderVc;
    if (![adModel.playable_ads_html hasPrefix:@"http://"] && ![adModel.playable_ads_html hasPrefix:@"https://"]) {
        [renderVc loadHTMLString:adModel.playable_ads_html isReplace:NO];
    }else{
        [renderVc setLoadUrl:adModel.playable_ads_html];
    }
    
    // 预加载
    if (([PASettingsManager sharedManager].isPreRender_01 && self.functionType == kSupportFunctionType_01)) {
        return;
    }
    if (([PASettingsManager sharedManager].isPreRender_02 && self.functionType == kSupportFunctionType_02)) {
        return;
    }
    
    [self PresentHtmlAction:nil];
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

- (void)hideKeyBoard{
    [self.requestTextView resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideKeyBoard];
}

#pragma mark: UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self hideKeyBoard];
        return NO;
    }
    return YES;
}
#pragma mark: PARenderVcDelegate
- (void)PARenderVcDidClosed{
    [self.renderVc setDelegate:nil];
    self.renderVc = nil;
    [self showResultLog:@"close ad... "];
}

@end
