//
//  PAViewController.m
//  PlayableAdsAPI
//
//  Created by wzy2010416033@163.com on 03/12/2019.
//  Copyright (c) 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PAViewController.h"
#import "PANetworkManager.h"
#import "PARenderViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIView+Toast.h"

@interface PAViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *useWebView;
@property (weak, nonatomic) IBOutlet UISwitch *prerender;
@property (weak, nonatomic) IBOutlet UISwitch *supportMraid;
@property (nonatomic) PARenderViewController *renderVc;

@end

@implementation PAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)supportFunction1:(id)sender {
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[PANetworkManager sharedManager] requestAPIDataSpport:1 success:^(PAAPIModel * _Nonnull apiModel) {
        [SVProgressHUD dismiss];
        if (apiModel.ads.count == 0) {
            [weakSelf.view makeToast:@"load fail..."];
            return ;
        }
        PAAdsModel *model = apiModel.ads[0];
        model.support_function = 1;
        [weakSelf loadHtml:model];
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [weakSelf.view makeToast:@"load fail..."];
        });
    }];
}

- (IBAction)supportFunction2:(id)sender {
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[PANetworkManager sharedManager] requestAPIDataSpport:2 success:^(PAAPIModel * _Nonnull apiModel) {
        [SVProgressHUD dismiss];
        if (apiModel.ads.count == 0) {
            [weakSelf.view makeToast:@"load fail..."];
            return ;
        }
        PAAdsModel *model = apiModel.ads[0];
        model.support_function = 2;
        [weakSelf loadHtml:model];
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [weakSelf.view makeToast:@"load fail..."];
        });
    }];
}

- (IBAction)presentAd:(id)sender {
    if (!self.renderVc) {
        return;
    }
    [self presentViewController:self.renderVc animated:YES completion:nil];
}

- (void)loadHtml:(PAAdsModel *)adModel {
    PARenderViewController *renderVc = [[PARenderViewController alloc] init];
    renderVc.adModel = adModel;
    renderVc.isSupportMraid = self.supportMraid.on;
    renderVc.isUseUIWebView = self.useWebView.on;
    renderVc.isPreRender = self.prerender.on;
    self.renderVc = renderVc;
    if (![adModel.playable_ads_html hasPrefix:@"http://"] && ![adModel.playable_ads_html hasPrefix:@"https://"]) {
        [renderVc loadHTMLString:adModel.playable_ads_html isReplace:NO];
    }else{
        [renderVc setLoadUrl:adModel.playable_ads_html];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
