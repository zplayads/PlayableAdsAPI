//
//  PAUIWebViewController.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/21.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAAPIModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PAUIWebViewController : UIViewController

@property (nonatomic) PAAdsModel *adModel;

- (void)setLoadUrl:(NSString *)urlString;
- (void)loadHTMLString:(NSString *)htmlStr isReplace:(BOOL)isReplace;

@end

NS_ASSUME_NONNULL_END
