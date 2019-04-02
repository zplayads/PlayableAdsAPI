//
//  PAUnifiedRenderWebView.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PARenderVcDelegate <NSObject>

- (void)PARenderVcDidClosed;

@end

@protocol PAUnifiedRenderWebView <NSObject>

- (void)setAdModel:(PAAdsModel *)adModel;
- (void)setFunctionType:(SupportFunctionType)functionType;
- (void)setDelegate:(id<PARenderVcDelegate> _Nullable)delegate;
- (void)setLoadUrl:(NSString *)urlString;
- (void)loadHTMLString:(NSString *)htmlStr isReplace:(BOOL)isReplace;

#pragma mark: mraid JavaScript events
- (void)changeState:(NSString *)state;
- (void)readyEvent;
- (void)viewableEvent;

@end

NS_ASSUME_NONNULL_END
