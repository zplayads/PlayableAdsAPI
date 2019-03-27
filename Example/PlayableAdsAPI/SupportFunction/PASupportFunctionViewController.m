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
@property (weak, nonatomic) IBOutlet UIButton *requestBtn;

@end

@implementation PASupportFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefault];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateButtonTitle];
}

- (void)updateButtonTitle{
    if ([self isSupportHtml]) {
        [self.requestBtn setTitle:@"Load Html" forState:UIControlStateNormal];
    }else{
        [self.requestBtn setTitle:@"Request Json" forState:UIControlStateNormal];
    }
}

- (void)setupDefault{
    
    NSString *dataPath = nil;
    switch (self.functionType) {
        case kSupportFunctionType_01:
            self.title = @"Supprt Function = 1";
            dataPath = [[NSBundle mainBundle] pathForResource:@"supportFunction1" ofType:@"json"];
            break;
        case kSupportFunctionType_02:
            self.title = @"Supprt Function = 2";
             dataPath = [[NSBundle mainBundle] pathForResource:@"supportFunction2" ofType:@"json"];
            break;
            
        default:
            break;
    }
    
    if (dataPath.length == 0) {
        return;
    }
    
    NSString *defaultText = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:dataPath] encoding:NSUTF8StringEncoding error:nil];
    self.requestTextView.text = defaultText;
}

- (NSString *)removeSpaceOrLine:(NSString *)text{
    // 去除首尾空格和换行
    NSString *tempText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    tempText = [tempText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return tempText;
}

- (NSDictionary *)handleRequestParams{
    
    NSString *requestText = [self removeSpaceOrLine:self.requestTextView.text];
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

- (BOOL)isSupportHtml{
    
    return  ([PASettingsManager sharedManager].isLoadHTMLorURL_01 && self.functionType == kSupportFunctionType_01) || ([PASettingsManager sharedManager].isLoadHTMLorURL_02 && self.functionType == kSupportFunctionType_02);
}

#pragma mark: IBAction

- (IBAction)requestAPIAction:(UIButton *)sender {
    [self hideKeyBoard];
    
    if ([self isSupportHtml]) {
        [self showResultLog:[NSString stringWithFormat:@"load html with Supprt Function = %zd .",self.functionType]];
        NSString *htmlString = [self removeSpaceOrLine:self.requestTextView.text];
        if (htmlString.length == 0) {
            [self showResultLog:@"htmlString is nil !!!"];
            return;
        }
        PAAdsModel *model = [[PAAdsModel alloc] init];
        model.support_function = self.functionType;
        model.playable_ads_html = htmlString;
        [self loadHtml:model isReplace:YES];
        return;
    }
    
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
        [weakSelf loadHtml:model isReplace:NO];
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
    
   
    if (([PASettingsManager sharedManager].isPreRender_01 && self.functionType == kSupportFunctionType_01)) {
        
        [self.renderVc.view removeFromSuperview];
        self.renderVc.view.hidden = NO;
    }
    if (([PASettingsManager sharedManager].isPreRender_02 && self.functionType == kSupportFunctionType_02)) {
        [self.renderVc.view removeFromSuperview];
        self.renderVc.view.hidden = NO;
    }
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
- (void)loadHtml:(PAAdsModel *)adModel isReplace:(BOOL)isReplace{
    [self showResultLog:@"load html..."];
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
    
    if ([adModel.playable_ads_html hasPrefix:@"http://"] || [adModel.playable_ads_html hasPrefix:@"https://"]) {  // load html url
        [renderVc setLoadUrl:adModel.playable_ads_html];
    }else{
        [renderVc loadHTMLString:adModel.playable_ads_html isReplace:isReplace];
    }
    
    // 预加载
    if (([PASettingsManager sharedManager].isPreRender_01 && self.functionType == kSupportFunctionType_01)) {
        
        self.renderVc.view.hidden = YES;
        [self.view addSubview:self.renderVc.view];
        return;
    }
    if (([PASettingsManager sharedManager].isPreRender_02 && self.functionType == kSupportFunctionType_02)) {
        self.renderVc.view.hidden = YES;
        [self.view addSubview:self.renderVc.view];
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
