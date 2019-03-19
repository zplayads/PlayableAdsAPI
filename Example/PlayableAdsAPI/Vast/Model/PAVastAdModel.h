//
//  PAVastAdModel.h
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/18.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PAVastTrackingEvents : NSObject

@property (nonatomic) NSString  *startTracking;
@property (nonatomic) NSString  *completeTracking;
@property (nonatomic) NSString  *pauseTracking;
@property (nonatomic) NSString  *resumeTracking;
@property (nonatomic) NSString  *closeLinearTracking;
@property (nonatomic) NSString  *skipTracking;
@property (nonatomic) NSString  *muteTracking;
@property (nonatomic) NSString  *unmuteTracking;

@end

// VAST 广告服务器响应的第三方视频插播广告 XML 摘要
@interface PAVastAdModel : NSObject

@property (nonatomic) NSString *adID;
@property (nonatomic) NSString *adSystem; // Company Node Name
@property (nonatomic) NSString  *adTitle;
@property (nonatomic) NSString  *impressionTracking;
@property (nonatomic) NSString  *creativeId;
@property (nonatomic) NSString  *duration;
//用于跟踪播放过程中的各种事件的 URI
@property (nonatomic) PAVastTrackingEvents  *trackingEvents;

@property (nonatomic) NSString  *targetUrl; // 在用户点击视频时作为目标网页打开的 URI
@property (nonatomic) NSArray<NSString *>  *clickTrackers; //VideoClicks trackers 在用户点击视频时为进行跟踪而请求的 URI

// 线性文件的位置MediaFile
@property (nonatomic) NSString  *mediaUrl;
@property (nonatomic) NSString  *mediaDelivery; //广告的投放方法（Google 不建议采用流式传输）
@property (nonatomic) NSString  *mediaType; // MIME 类型（适用于 Windows Media 的热门 MIME 类型为“video/x-ms-wmv”）
@property (nonatomic , assign)int mediaBitrate; //编码视频的比特率（以 Kbps 为单位）
@property (nonatomic , assign)int mediaWidth; // 视频的像素尺寸 宽  整数
@property (nonatomic , assign)int mediaHeight; // 视频的像素尺寸  高
@property (nonatomic , assign) BOOL mediaScalable; // 广告是否接受图片比例调整（Google 默认情况做法

@end

NS_ASSUME_NONNULL_END
