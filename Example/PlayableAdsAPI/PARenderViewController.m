//
//  PARenderViewController.m
//  PlayableAdsAPI_Example
//
//  Created by 王泽永 on 2019/3/12.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PARenderViewController.h"
#import <WebKit/WebKit.h>
#import "ZplayAppStore.h"
#import "NSString+YumiURLEncodedString.h"

@interface PARenderViewController () <WKScriptMessageHandler, WKNavigationDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) WKWebView *wkAdRender;
@property (nonatomic) UIWebView *uiAdRender;
@property (nonatomic) ZplayAppStore  *appStore;

@end

@implementation PARenderViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSNumber *itunesId = [NSNumber numberWithInt:1167885749];
    self.appStore =  [[ZplayAppStore alloc]
                      initWithItunesID:itunesId
                      itunesLink:@"https://itunes.apple.com/cn/app/"
                      @"%E5%B0%8F%E7%8B%90%E7%8B%B8-%E5%BE%8B%E5%8A%A8%E8%B7%B3%E8%B7%83/id1167885749"];
    // add tap
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewTapped:)];
    tap.numberOfTapsRequired = 5;
    tap.delegate = self;
    if (self.isUseUIWebView) {
        [self.view addSubview:self.uiAdRender];
        [self.uiAdRender addGestureRecognizer:tap];
    } else {
        [self.view addSubview:self.wkAdRender];
        [self.wkAdRender addGestureRecognizer:tap];
    }
}

- (void)clickViewTapped:(UITapGestureRecognizer *)grconizer {
    [self dismissAd];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)setLoadUrl:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (self.isUseUIWebView) {
        [self.uiAdRender loadRequest:request];
    } else {
        [self.wkAdRender loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)htmlStr isReplace:(BOOL)isReplace{
    if (htmlStr.length == 0) {
        return;
    }
    if (isReplace) {
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\r" withString:@""];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    }
    if (self.isUseUIWebView) {
        [self.uiAdRender loadHTMLString:htmlStr baseURL:nil];
    } else {
        [self.wkAdRender loadHTMLString:htmlStr baseURL:nil];
    }
}

- (void)openAppstore:(NSURL *)openUrl{
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:openUrl options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:openUrl];
    }
}

#pragma mark: JS call back
- (void)handlePlayablePageMessage:(NSString *)msg {
    if ([msg isEqualToString:@"user_did_tap_install"]) {
        NSURL  *openUrl = [NSURL URLWithString:self.adModel.target_url];
        // 2的时候只支持user_did_tap_install
        if (self.adModel.support_function == 2) {
            [self openAppstore:openUrl];
        }
    } else if ([msg isEqualToString:@"close_playable_ads"]) {
        [self dismissAd];
    }
}

- (void)dismissAd {
    if (self.isPreRender) {
        [self.wkAdRender removeFromSuperview];
        [self.wkAdRender.configuration.userContentController removeScriptMessageHandlerForName:@"zplayads"];
        self.view.hidden = YES;
        self.wkAdRender = nil;
        self.uiAdRender = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.wkAdRender removeFromSuperview];
            [self.wkAdRender.configuration.userContentController removeScriptMessageHandlerForName:@"zplayads"];
            self.wkAdRender = nil;
            self.uiAdRender = nil;
        }];
    }
    [self.delegate PARenderVcDidClosed];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"zplayads"]) {
        [self handlePlayablePageMessage:message.body];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}
- (void)webView:(WKWebView *)webView
didFailNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error {
}
- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error {
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *rUrl = [navigationAction.request.URL absoluteString];
    if ([rUrl hasPrefix:@"zplayads:"]) {
        NSArray *v = [rUrl componentsSeparatedByString:@":"];
        if (v.count > 1) {
            [self handlePlayablePageMessage:v[1]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([rUrl hasPrefix:@"https://"] || [rUrl hasPrefix:@"http://"]) {
        NSURL *openUrl = [NSURL URLWithString:rUrl];
        if (self.adModel.support_function == 1 || self.adModel.support_function == 3) {
            [self openAppstore:openUrl];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([rUrl hasPrefix:@"mraid://open"]){
        NSArray *arr = [rUrl componentsSeparatedByString:@"="];
        NSString *str = [arr.lastObject stringByRemovingPercentEncoding];
        [self openAppstore:[NSURL URLWithString:str]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if ([rUrl hasPrefix:@"mraid://"]){
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (WKWebView *)wkAdRender {
    if (!_wkAdRender) {
        NSString *mraidJs = nil;
        if (self.isSupportMraid) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"mraid" ofType:@"js"];
            NSData *data= [[NSData alloc] initWithContentsOfFile:path];
            mraidJs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        WKUserScript *script = [[WKUserScript alloc] initWithSource:mraidJs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config.userContentController addUserScript:script];
        [config.userContentController addScriptMessageHandler:self name:@"zplayads"];
        config.allowsInlineMediaPlayback = YES;

        CGRect frame =
        CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _wkAdRender = [[WKWebView alloc] initWithFrame:frame configuration:config];
        _wkAdRender.scrollView.bounces = NO;
        _wkAdRender.navigationDelegate = self;
        _wkAdRender.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if (@available(iOS 11.0, *)) {
            [_wkAdRender.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }
    return _wkAdRender;
}

- (UIWebView *)uiAdRender {
    if (!_uiAdRender) {
        
    }
    return _uiAdRender;
}

@end
