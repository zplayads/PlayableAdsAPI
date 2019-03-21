//
//  PAPlayerHeader.h
//  PlayableAdsAPI
//
//  Created by polesapp-hcd on 16/7/7.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

// 图片路径
#define PAImageSrcName(file)               [@"PAVideoPlayer.bundle" stringByAppendingPathComponent:file]
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

#import "PAVideoPlayer.h"
#import "PALoaderURLConnection.h"
#import "NSString+PA.h"
#import <Masonry/Masonry.h>
#import "PAPlayerView.h"
#import "PATimeSheetView.h"
#import "PALightView.h"
