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

@interface PAUIWebViewController ()<UIWebViewDelegate>

@property (nonatomic)UIWebView *webView;

@end

@implementation PAUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutSubViewUI];
}

- (void)layoutSubViewUI{
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark: public method

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

- (void)handleCustomAction:(NSURL *)actionUrl{
    NSLog(@"actionUrl = %@",actionUrl);
}
#pragma mark:- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *URL = request.URL;
    NSString *scheme = [URL scheme];
    
    NSString *rUrl = [[request URL] absoluteString];
    if ([rUrl hasPrefix:@"zplayads:"]) {
        NSArray *v = [rUrl componentsSeparatedByString:@":"];
        if (v.count > 1) {
            [self handleCustomAction:v[1]];
        }
        return NO;
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
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
    }
    return _webView;
}

@end
