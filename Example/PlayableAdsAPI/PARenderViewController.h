//
//  PARenderViewController.h
//  PlayableAdsAPI_Example
//
//  Created by 王泽永 on 2019/3/12.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAAPIModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PARenderViewController : UIViewController
@property (nonatomic, assign) BOOL isSupportMraid;
@property (nonatomic, assign) BOOL isUseUIWebView;
@property (nonatomic, assign) BOOL isPreRender;
@property (nonatomic) PAAdsModel *adModel;

- (void)setLoadUrl:(NSString *)urlString;
- (void)loadHTMLString:(NSString *)htmlStr isReplace:(BOOL)isReplace;

@end

NS_ASSUME_NONNULL_END
