//
//  PAUIWebViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/21.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PAUIWebViewController.h"
#import <Masonry/Masonry.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "PASettingsManager.h"
#import "UIViewController+PACloseView.h"
#import "UIView+Toast.h"

@interface PAUIWebViewController ()<UIWebViewDelegate>

@property (nonatomic)UIWebView *webView;
@property (nonatomic , assign) SupportFunctionType functionType;
@property (nonatomic) PAAdsModel *adModel;
@property (nonatomic) id<PARenderVcDelegate> delegate;

@end

@implementation PAUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutSubViewUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self isSupportPreRender]) {
        [self viewableEvent];
    }
}

- (void)layoutSubViewUI{
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self showCloseView];
}

- (BOOL)isSupportMraid{
    if ([PASettingsManager sharedManager].isSupportMraid_01 && self.functionType == kSupportFunctionType_01) {
        return YES;
    }
    if ([PASettingsManager sharedManager].isSupportMraid_02 && self.functionType == kSupportFunctionType_02) {
        return YES;
    }
    return NO;
}

- (BOOL)isSupportPreRender{
    if ([PASettingsManager sharedManager].isPreRender_01 && self.functionType == kSupportFunctionType_01) {
        return YES;
    }
    if ([PASettingsManager sharedManager].isPreRender_02 && self.functionType == kSupportFunctionType_02) {
        return YES;
    }
    return NO;
}

#pragma mark: public method
- (void)setAdModel:(PAAdsModel *)adModel{
    _adModel = adModel;
}
- (void)setFunctionType:(SupportFunctionType)functionType{
    _functionType = functionType;
}
- (void)setDelegate:(id<PARenderVcDelegate> _Nullable)delegate{
    _delegate = delegate;
}
- (void)setLoadUrl:(NSString *)urlString{
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}
- (void)loadHTMLString:(NSString *)htmlStr isReplace:(BOOL)isReplace{
    
    if (isReplace) {
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\r" withString:@""];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    }
    
    [self.webView loadHTMLString:htmlStr baseURL:nil];
}

- (void)handleCustomAction:(NSString *)msg{
    [self.view makeToast:msg duration:2.0 position:CSToastPositionCenter];
    NSLog(@"actionUrl = %@",msg);
    if ([msg isEqualToString:@"user_did_tap_install"]) {
        NSURL  *openUrl = [NSURL URLWithString:self.adModel.target_url];
        [self openAppstore:openUrl];
    } else if ([msg isEqualToString:@"close_playable_ads"]) {
        [self dismissAd];
    }
}
- (void)openAppstore:(NSURL *)openUrl{
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:openUrl options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:openUrl];
    }
}
- (void)dismissAd {
    [self dismissViewControllerAnimated:YES completion:^{
        self.webView.delegate = nil;
        self.webView = nil;
    }];
    [self.delegate PARenderVcDidClosed];
}

#pragma mark:- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    NSString *rUrl = [[request URL] absoluteString];
    if ([rUrl hasPrefix:@"zplayads:"]) {
        NSArray *v = [rUrl componentsSeparatedByString:@":"];
        if (v.count > 1) {
            [self handleCustomAction:v[1]];
        }
        return NO;
    }else if ([rUrl hasPrefix:@"https://"] || [rUrl hasPrefix:@"http://"]) {
       
        if (!([PASettingsManager sharedManager].isSupportATag_01 && self.functionType == kSupportFunctionType_01)) {
            return YES;
        }
        // 只有 01 并且支持 A 标签才会执行
        NSURL *openUrl = [NSURL URLWithString:rUrl];
        [self openAppstore:openUrl];
        return NO;
    }if ([rUrl hasPrefix:@"mraid://open"]){
        if (![self isSupportMraid]){
            return YES;
        }
        // 只有 01 并且支持 Mraida才会执行
        NSArray *arr = [rUrl componentsSeparatedByString:@"="];
        NSString *str = [arr.lastObject stringByRemovingPercentEncoding];
        [self openAppstore:[NSURL URLWithString:str]];
        return NO;
    }if ([rUrl hasPrefix:@"mraid://close"]){
        
        if (![self isSupportMraid]){
            return YES;
        }
        // 只有 01 并且支持 Mraida才会执行
        [self dismissAd];
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (![self isSupportMraid]){
        return;
    }
    // send  mraid action
    [self changeState:@"default"];
    [self interstitialEvent];
    [self readyEvent];
    // not pre render
    if (![self isSupportPreRender]) {
        [self viewableEvent];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.mediaPlaybackRequiresUserAction = NO;
        _webView.allowsInlineMediaPlayback = YES;
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor blackColor];
        //mraid
        if ([self isSupportMraid]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"mraid" ofType:@"js"];
            NSData *data= [[NSData alloc] initWithContentsOfFile:path];
            NSString *mraidJs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [_webView stringByEvaluatingJavaScriptFromString:mraidJs];
        }
        
    }
    return _webView;
}

#pragma mark: mraid event
- (void)changeState:(NSString *)state {
    NSString *javaScriptString = [NSString stringWithFormat:@"mraid.fireStateChangeEvent('%@');",state];
    [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
}

- (void)readyEvent {
    NSString *javaScriptString = @"mraid.fireReadyEvent()";
    [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
}

- (void)viewableEvent {
    NSString *javaScriptString = @"mraid.fireViewableChangeEvent(true);";
    [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
}
- (void)interstitialEvent{
    NSString *javaScriptString = @"mraid.setPlacementType('interstitial');";
   [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
}
@end
