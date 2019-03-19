//
//  PAVastViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/18.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PAVastViewController.h"
#import "GDataXMLNode.h"
#import "PAVastAdModel.h"
#import <WMPlayer/WMPlayer.h>
#import <Masonry/Masonry.h>
#import "PAStatisticsReportManager.h"

@interface PAVastViewController ()<WMPlayerDelegate>

@property (nonatomic)WMPlayer * wmPlayer;
@property (nonatomic , assign) BOOL isFullScreen;
@property (nonatomic , assign) BOOL isPlaying;
@property (nonatomic) PAVastAdModel *vastModel;

@end

@implementation PAVastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)handleBackAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)parseVastAction:(UIButton *)sender {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"localVast" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData error:&error];

    if (doc == nil) {
        NSLog(@" doc is nil");
        self.vastModel = nil;
        return;
    }

    NSArray *ads = [doc.rootElement elementsForName:@"Ad"];
   
    if (ads.count == 0) {
        self.vastModel = nil;
        NSLog(@"No ad element");
        return;
    }
    
    GDataXMLElement *element = ads.firstObject;
    self.vastModel = [self convertToAdModelWithXMLAdTag:element];
    
    [self playVideo:self.vastModel.mediaUrl];
}

- (void)playVideo:(NSString *)videoUrl{
    if (videoUrl.length == 0) {
        return;
    }
    WMPlayerModel *playerModel = [[WMPlayerModel alloc] init];
    playerModel.title = @"Ad Video";
    playerModel.videoURL = [NSURL URLWithString:videoUrl];
    self.wmPlayer = [[WMPlayer alloc]initPlayerModel:playerModel];
    self.wmPlayer.delegate = self;
    self.wmPlayer.enableVolumeGesture = YES;
    self.wmPlayer.enableFastForwardGesture = YES;
    
    self.isFullScreen = NO;
    [self layoutPlayFrame:self.isFullScreen];
    self.isPlaying = YES;
    [self.wmPlayer play];
    
    // impressionTracking
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.impressionTracking];
    
}

- (void)layoutPlayFrame:(BOOL)isFullScreen{
    if (!self.wmPlayer.superview) {
        [self.view addSubview:self.wmPlayer];
    }
    
    if (isFullScreen) {
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.wmPlayer.superview);
            make.top.equalTo(self.view.mas_top).offset(44);
            make.bottom.equalTo(self.view.mas_bottom).offset(-34);
        }];
        return;
    }
    [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(self.wmPlayer.mas_width).multipliedBy(9.0/16);
    }];
}

- (PAVastAdModel *)convertToAdModelWithXMLAdTag:(GDataXMLElement *)adElement{
    
    PAVastAdModel *vastModel = [[PAVastAdModel alloc] init];
    
    if ([adElement attributes].count > 0) {
        vastModel.adID = ((GDataXMLNode *)[adElement attributes][0]).stringValue;
    }
    
    // InLine
    if ([adElement elementsForName:@"InLine"].count == 0) {
        return nil;
    }
    GDataXMLElement *inLineElement = [adElement elementsForName:@"InLine"].firstObject;
    
    if ([inLineElement elementsForName:@"AdSystem"].count > 0) {
        vastModel.adSystem = ((GDataXMLElement *)[inLineElement elementsForName:@"AdSystem"].firstObject).stringValue;
    }
    
    if ([inLineElement elementsForName:@"AdTitle"].count > 0) {
        vastModel.adTitle = ((GDataXMLElement *)[inLineElement elementsForName:@"AdTitle"].firstObject).stringValue;
    }
    if ([inLineElement elementsForName:@"Impression"].count > 0) {
        vastModel.impressionTracking = ((GDataXMLElement *)[inLineElement elementsForName:@"Impression"].firstObject).stringValue;
    }
    //Creatives
    if ([inLineElement elementsForName:@"Creatives"].count > 0) {
        GDataXMLElement *creativesElement = [inLineElement elementsForName:@"Creatives"].firstObject;
        // Creative
        if ([creativesElement elementsForName:@"Creative"].count > 0) {
            GDataXMLElement *creative =  [creativesElement elementsForName:@"Creative"].firstObject;
            if ([creative attributes].count > 0) {
                vastModel.creativeId = ((GDataXMLNode *)[creative attributes][0]).stringValue;
            }
            // Linear
            if ([creative elementsForName:@"Linear"].count > 0) {
                GDataXMLElement *linearElement =  [creative elementsForName:@"Linear"].firstObject;
                //Duration
                if ([linearElement elementsForName:@"Duration"].count > 0) {
                    vastModel.duration = ((GDataXMLElement *)[linearElement elementsForName:@"Duration"].firstObject).stringValue;
                }
                // TrackingEvents
                if ([linearElement elementsForName:@"TrackingEvents"].count > 0) {
                    if ([[linearElement elementsForName:@"TrackingEvents"].firstObject elementsForName:@"Tracking"].count > 0) {
                        
                        PAVastTrackingEvents *event = [[PAVastTrackingEvents alloc] init];
                        
                        for (GDataXMLElement *trackElement in [[linearElement elementsForName:@"TrackingEvents"].firstObject elementsForName:@"Tracking"]) {
                            if ([trackElement attributes].count > 0) {
                                NSString *eventName =  ((GDataXMLNode *)[trackElement attributes][0]).stringValue;
                                NSString *eventValue = trackElement.stringValue;
                                
                                if ([eventName isEqualToString:@"start"]) {
                                    event.startTracking = eventValue;
                                }
                                if ([eventName isEqualToString:@"complete"]) {
                                    event.completeTracking = eventValue;
                                }
                                if ([eventName isEqualToString:@"pause"]) {
                                    event.pauseTracking = eventValue;
                                }
                                if ([eventName isEqualToString:@"resume"]) {
                                    event.resumeTracking = eventValue;
                                }
                                if ([eventName isEqualToString:@"closeLinear"]) {
                                    event.closeLinearTracking = eventValue;
                                }
                                if ([eventName isEqualToString:@"skip"]) {
                                    event.skipTracking = eventValue;
                                }
                                //mute
                                if ([eventName isEqualToString:@"mute"]) {
                                    event.muteTracking = eventValue;
                                }
                                if ([eventName isEqualToString:@"unmute"]) {
                                    event.unmuteTracking = eventValue;
                                }
                            }
                        }
                        vastModel.trackingEvents = event;
                    }
                }
                // VideoClicks
                if ([linearElement elementsForName:@"VideoClicks"].count > 0) {
                    
                    GDataXMLElement *videoClicks =  [linearElement elementsForName:@"VideoClicks"].firstObject;
                    
                    // ClickThrough
                    if ([videoClicks elementsForName:@"ClickThrough"].count > 0) {
                         GDataXMLNode *clickThrough =  [videoClicks elementsForName:@"ClickThrough"].firstObject;
                        vastModel.targetUrl = clickThrough.stringValue;
                    }
                    // ClickTrackings
                    if ([videoClicks elementsForName:@"ClickTracking"].count > 0) {
                        NSMutableArray *clickTrackers = [NSMutableArray array];
                        for (GDataXMLElement *element in [videoClicks elementsForName:@"ClickTracking"]) {
                            if (element.stringValue.length != 0) {
                                [clickTrackers addObject:element.stringValue];
                            }
                        }
                        vastModel.clickTrackers = [clickTrackers copy];
                    }
                    
                }
                // MediaFiles
                if ([linearElement elementsForName:@"MediaFiles"].count > 0) {
                    GDataXMLElement *mediaFilesElement = [linearElement elementsForName:@"MediaFiles"].firstObject;
                    //media
                    if ([mediaFilesElement elementsForName:@"MediaFile"].count > 0) {
                        GDataXMLElement *mediaElement = [mediaFilesElement elementsForName:@"MediaFile"].firstObject;
                        // media url
                        vastModel.mediaUrl = mediaElement.stringValue;
                        if ([mediaElement attributes].count > 0) {
                            for (GDataXMLNode *assetNode in [mediaElement attributes]) {
                                if ([assetNode.name isEqualToString:@"delivery"]) {
                                    vastModel.mediaDelivery = assetNode.stringValue;
                                }
                                if ([assetNode.name isEqualToString:@"type"]) {
                                    vastModel.mediaType = assetNode.stringValue;
                                }
                                if ([assetNode.name isEqualToString:@"bitrate"]) {
                                    vastModel.mediaBitrate = [assetNode.stringValue intValue];
                                }
                                if ([assetNode.name isEqualToString:@"width"]) {
                                    vastModel.mediaWidth = [assetNode.stringValue intValue];
                                }
                                if ([assetNode.name isEqualToString:@"height"]) {
                                    vastModel.mediaHeight = [assetNode.stringValue intValue];
                                }
                                if ([assetNode.name isEqualToString:@"scalable"]) {
                                    vastModel.mediaScalable = [assetNode.stringValue boolValue];
                                }
                                
                                
                            }
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    return  vastModel;
}

#pragma mark: WMPlayerDelegate
//点击播放暂停按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying) { // resumeTracking
        [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.resumeTracking];
        return;
    }
    //pause
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.pauseTracking];
}
//点击关闭按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)backBtn{
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
    self.view.backgroundColor = [UIColor whiteColor];
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.closeLinearTracking];
    
}
//点击全屏按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    
    self.isFullScreen = !self.isFullScreen;
    
    [self layoutPlayFrame:self.isFullScreen];
    
    if (self.isFullScreen) {
        self.view.backgroundColor = [UIColor blackColor];
    }else{
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
}
//点击锁定🔒按钮的方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedLockButton:(UIButton *)lockBtn{
    
}
//单击WMPlayer的代理方法
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    
}
//双击WMPlayer的代理方法
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSURL *targetUrl = [NSURL URLWithString:self.vastModel.targetUrl];
    if (!targetUrl) {
        NSLog(@"targetUrl is nil");
        return;
    }
    
    [[PAStatisticsReportManager shareManager] sendTrackers:self.vastModel.clickTrackers];
    
    [[UIApplication sharedApplication] openURL:targetUrl options:nil completionHandler:^(BOOL success) {
        
    }];
}
//WMPlayer的的操作栏隐藏和显示
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL )isHidden{
    
}
//播放失败的代理方法
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    
}
//准备播放的代理方法
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.startTracking];
}
//播放器已经拿到视频的尺寸大小
-(void)wmplayerGotVideoSize:(WMPlayer *)wmplayer videoSize:(CGSize )presentationSize{
    
}
//播放完毕的代理方法
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    self.isPlaying = NO;
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.completeTracking];
}

@end
