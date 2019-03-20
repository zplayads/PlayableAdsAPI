//
//  PALoadHtmlOrUrlViewController.m
//  PlayableAdsAPI_Example
//
//  Created by 王泽永 on 2019/3/12.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PALoadHtmlOrUrlViewController.h"
#import "PARenderViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface PALoadHtmlOrUrlViewController () <PARenderVcDelegate>
@property (weak, nonatomic) IBOutlet UITextView *htmlTextView;
@property (weak, nonatomic) IBOutlet UISwitch *supportFunction1;
@property (nonatomic) PARenderViewController *detailVc;
@property (nonatomic) AFHTTPSessionManager *manager;
@end

@implementation PALoadHtmlOrUrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)backToMainView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)loadHtmlOrUrl:(id)sender {
    [self.htmlTextView resignFirstResponder];
    NSString *text =  [NSString stringWithFormat:@"%@",self.htmlTextView.text];
    if (text.length == 0) {
        return;
    }
    self.detailVc = [[PARenderViewController alloc] init];
    self.detailVc.delegate = self;
    self.detailVc.isSupportMraid = self.isSupportMraid;
    self.detailVc.isUseUIWebView = self.isUseUIWebView;
    self.detailVc.isPreRender = self.isPreRender;
    if (self.supportFunction1.on) {
        self.detailVc.adModel.support_function = 1;
    } else {
        self.detailVc.adModel.support_function = 2;
    }
    if (self.isPreRender) {
        self.detailVc.view.hidden = YES;
        [self.view addSubview:self.detailVc.view];
    }
    PAAdsModel *model = [[PAAdsModel alloc] init];
    model.support_function = 3;
    self.detailVc.adModel = model;
    if (![text hasPrefix:@"http://"] && ![text hasPrefix:@"https://"]) {
        [self.detailVc loadHTMLString:text isReplace:YES];
    }else{
        __weak __typeof(self)weakSelf = self;
        [self requestHtml:text complete:^(NSString *html) {
           [weakSelf.detailVc loadHTMLString:html isReplace:YES];
        }];
    }
}

- (IBAction)presentAd:(id)sender {
    if (!self.detailVc) {
        return;
    }
    if (self.isPreRender) {
        self.detailVc.view.hidden = NO;
    } else {
        [self presentViewController:self.detailVc animated:YES completion:nil];
    }
}

#pragma mark - PARenderVcDelegate
- (void)PARenderVcDidClosed{
    self.detailVc.delegate = nil;
    self.detailVc = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)requestHtml:(NSString *)url complete:(void (^)(NSString *html))complete {
    self.manager = [AFHTTPSessionManager manager];
    self.manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    self.manager.requestSerializer.timeoutInterval = 15;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        complete([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete(nil);
    }];
}
@end
