//
//  UIViewController+PACloseView.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/26.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "UIViewController+PACloseView.h"
#import <Masonry/Masonry.h>

@implementation UIViewController (PACloseView)

- (void)showCloseView{
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissAd) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:closeButton];
    
    CGFloat satusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(30);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.top.equalTo(self.view.mas_top).offset(satusHeight + 5);
    }];
    
}


@end
