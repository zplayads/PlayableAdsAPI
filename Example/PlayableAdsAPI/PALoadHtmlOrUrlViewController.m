//
//  PALoadHtmlOrUrlViewController.m
//  PlayableAdsAPI_Example
//
//  Created by 王泽永 on 2019/3/12.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PALoadHtmlOrUrlViewController.h"
#import "PARenderViewController.h"

@interface PALoadHtmlOrUrlViewController ()
@property (weak, nonatomic) IBOutlet UITextView *htmlTextView;
@property (nonatomic) PARenderViewController *detailVc;

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
    self.detailVc.isSupportMraid = self.isSupportMraid;
    self.detailVc.isUseUIWebView = self.isUseUIWebView;
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
        [self.detailVc setLoadUrl:text];
    }
}

- (IBAction)presentAd:(id)sender {
    if (self.isPreRender) {
        self.detailVc.view.hidden = NO;
    } else {
        [self presentViewController:self.detailVc animated:YES completion:nil];
    }
}
@end
