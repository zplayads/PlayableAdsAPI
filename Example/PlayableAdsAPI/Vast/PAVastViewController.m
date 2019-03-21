//
//  PAVastViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/18.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PAVastViewController.h"
#import <GDataXML_HTML/GDataXMLNode.h>
#import "PAVastAdModel.h"
#import <Masonry/Masonry.h>
#import "PAStatisticsReportManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "PANetworkManager.h"
#import "PAVideoPlayer.h"

@interface PAVastViewController ()<PAVideoPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic)PAVideoPlayer * videoPlayer;
@property (nonatomic , assign) BOOL isFullScreen;
@property (nonatomic , assign) BOOL isPlaying;
@property (nonatomic) PAVastAdModel *vastModel;
@property (nonatomic) UILabel  *videoTipLabel;
@property (nonatomic) UIView  *showPlayerView;

@end

@implementation PAVastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)handleBackAction:(UIButton *)sender {
    
    [self.videoPlayer stop];
    [self.showPlayerView removeFromSuperview];
    self.videoPlayer = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)parseVastAction:(UIButton *)sender {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"localVast" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
   
    [self showText:@"parse vast xml from local"];
    
    [self handleVastData:xmlData];
}

- (IBAction)handleNetworkVast:(UIButton *)sender {
    [SVProgressHUD show];
    [self showText:@"Request vast from server"];
    __weak typeof(self) weakSelf = self;
    [[PANetworkManager sharedManager] requestVastDataCompleted:^(NSData * _Nonnull vastData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSError *error;
            NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:vastData
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&error];
            if ([dictFromData[@"ads"] isKindOfClass:[NSArray class]]) {
                NSDictionary *ad = ((NSArray *)dictFromData[@"ads"]).firstObject;
                NSData *vastData = [ad[@"adm"] dataUsingEncoding:NSUTF8StringEncoding];
                [weakSelf handleVastData:vastData];
            }
            
        });
        
    }];
}

- (void)handleVastData:(NSData *)vastData{
    if (!vastData) {
        [self showText:@"Vast response fail"];
        return;
    }
  
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:vastData error:&error];
    
    if (doc == nil) {
        [self showText:@"doc is nil"];
        self.vastModel = nil;
        return;
    }
    
    NSArray *ads = [doc.rootElement elementsForName:@"Ad"];
    
    if (ads.count == 0) {
        self.vastModel = nil;
        [self showText:@"No ad element"];
        return;
    }
    
    GDataXMLElement *element = ads.firstObject;
    self.vastModel = [self convertToAdModelWithXMLAdTag:element];
    
    [self playVideo:self.vastModel.mediaUrl];
    
}

- (void)showText:(NSString *)logText{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.tipLabel.text = logText;
    });
}
- (void)playVideo:(NSString *)videoUrl{
    if (videoUrl.length == 0) {
        [self showText:@"videoUrl is nil"];
        return;
    }
   
    self.videoPlayer = [PAVideoPlayer sharedInstance];
    
    self.videoPlayer.delegate = self;
    self.isFullScreen = NO;
    [self layoutPlayFrame:self.isFullScreen];
    self.isPlaying = YES;
    
    
    [self.videoPlayer playWithUrl:[NSURL URLWithString:videoUrl] showView:self.showPlayerView andSuperView:self.view withCache:YES];
    
    // impressionTracking
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.impressionTracking];
   
}

- (void)layoutPlayFrame:(BOOL)isFullScreen{
    if (!self.showPlayerView.superview) {
        [self.view addSubview:self.showPlayerView];
    }

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat minWidth = MIN(screenSize.width, screenSize.height);

    [self.showPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(minWidth);
        make.center.equalTo(self.view);
        make.height.mas_equalTo(minWidth * 9 / 16);
    }];
    if (!self.videoTipLabel.superview) {
        [self.view addSubview:self.videoTipLabel];

    }
    CGFloat topMargin =  (screenSize.height + (minWidth * 9 / 16)) * 0.5 + 10;
    self.videoTipLabel.hidden = NO;
    [self.videoTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(topMargin);
    }];
    
    [self.view layoutIfNeeded];
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

//-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
//
//    self.isFullScreen = !self.isFullScreen;
//
//    [self layoutPlayFrame:self.isFullScreen];
//
//    if (self.isFullScreen) {
//        self.view.backgroundColor = [UIColor blackColor];
//        [self showText:@"video input full screen"];
//    }else{
//        self.view.backgroundColor = [UIColor whiteColor];
//        [self showText:@"video exit full screen"];
//    }
//
//}
#pragma mark: PAVideoPlayerDelegate
-(void)videoStartPlaying:(PAVideoPlayer *)player{
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.startTracking];
    [self showText:@"play start video"];
}
-(void)videoPlayerFinished:(PAVideoPlayer *)player{
    self.isPlaying = NO;
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.completeTracking];
    [self showText:@"video play finished"];
}
-(void)videoPlayerPause:(PAVideoPlayer *)player{
    //pause
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.pauseTracking];
    [self showText:@"pause video"];
}
-(void)videoPlayerResume:(PAVideoPlayer *)player{
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.resumeTracking];
    [self showText:@"resume video"];
}
-(void)videoPlayerClick:(PAVideoPlayer *)player{
    NSURL *targetUrl = [NSURL URLWithString:self.vastModel.targetUrl];
    if (!targetUrl) {
        [self showText:@"targetUrl is nil"];
        return;
    }
    
    [[PAStatisticsReportManager shareManager] sendTrackers:self.vastModel.clickTrackers];
    
    [[UIApplication sharedApplication] openURL:targetUrl options:nil completionHandler:^(BOOL success) {
        
    }];
    
    [self showText:@"double click open App Store"];
}
-(void)videoPlayerClose:(PAVideoPlayer *)player{
   
//    self.view.backgroundColor = [UIColor whiteColor];
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.closeLinearTracking];
    [self showText:@"close video"];
    self.videoTipLabel.hidden = YES;
}


- (UILabel *)videoTipLabel{
    if (!_videoTipLabel) {
        _videoTipLabel = [[UILabel alloc] init];
        _videoTipLabel.text = @"double click video screen open App Store";
        _videoTipLabel.textColor = [UIColor grayColor];
        _videoTipLabel.textAlignment = NSTextAlignmentCenter;
        _videoTipLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _videoTipLabel;
}

- (UIView *)showPlayerView{
    if (!_showPlayerView) {
        _showPlayerView = [[UIView alloc] init];
    }
    return _showPlayerView;
}

@end
