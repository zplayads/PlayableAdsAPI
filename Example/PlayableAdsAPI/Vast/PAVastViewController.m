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

@property (weak, nonatomic) IBOutlet UITextView *requestTextView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@property (nonatomic)PAVideoPlayer * videoPlayer;
@property (nonatomic) PAVastAdModel *vastModel;
@property (nonatomic) UILabel  *videoTipLabel;

@property (strong, nonatomic) IBOutlet UIView *showPlayerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint;

@end

@implementation PAVastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefault];
}

- (void)setupDefault{
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"vastRequest" ofType:@"json"];;
    
    if (dataPath.length == 0) {
        return;
    }
    
    NSString *defaultText = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:dataPath] encoding:NSUTF8StringEncoding error:nil];
    self.requestTextView.text = defaultText;
}

#pragma mark: 禁用和恢复右滑返回

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    }
}

- (IBAction)handleBack:(UIBarButtonItem *)sender {
    [self clearVideoPlayer];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)parseVastAction {
    
    [self clearVideoPlayer];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"localVast" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
   
    [self showText:@"parse vast xml from local"];
    
    [self handleVastData:xmlData];
}

- (IBAction)handleNetworkVast:(UIButton *)sender {
    
    [self clearVideoPlayer];
    [self showText:@"Request vast from server"];
    
    NSDictionary *param =  [self handleRequestParams];
    if (!param) {
        
        return;
    }
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    [[PANetworkManager sharedManager] requestVastData:param completed:^(NSData * _Nonnull vastData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (!vastData) {
                
                [weakSelf showText:@"vast response is nil"];
                return ;
            }
            NSError *error;
            NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:vastData
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&error];
            if ([dictFromData[@"ads"] isKindOfClass:[NSArray class]]) {
                NSDictionary *ad = ((NSArray *)dictFromData[@"ads"]).firstObject;
                NSData *vastData = [ad[@"adm"] dataUsingEncoding:NSUTF8StringEncoding];
                [weakSelf handleVastData:vastData];
                return;
            }
            [weakSelf showText:@"vast ads is nil"];
        });
        
    }];
}

- (void)handleVastData:(NSData *)vastData{
    if (!vastData) {
        [self showText:@"Vast response adm is nil"];
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

- (NSDictionary *)handleRequestParams{
    NSString *requestText = self.requestTextView.text;
    // 去除首尾空格和换行
    requestText = [requestText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    requestText = [requestText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (requestText.length == 0) {
        [self showText:@"request params is nil !!!"];
        return nil;
    }
    NSData *objectData = [requestText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    if (error || !parameters) {
        [self showText:@"Request parameter is not a standard json string"];
        return nil;
    }
    
    return parameters;
}

- (void)showText:(NSString *)logText{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.resultTextView.layoutManager.allowsNonContiguousLayout = NO;
        NSString *oldLog = weakSelf.resultTextView.text;
        NSString *text = [NSString stringWithFormat:@"%@\n%@", oldLog, logText];
        if (oldLog.length == 0) {
            text = [NSString stringWithFormat:@"%@", logText];
        }
        [weakSelf.resultTextView scrollRangeToVisible:NSMakeRange(text.length, 1)];
        weakSelf.resultTextView.text = text;
    });
}
- (void)playVideo:(NSString *)videoUrl{
    if (videoUrl.length == 0) {
        [self showText:@"videoUrl is nil"];
        return;
    }
    
    self.videoPlayer = [PAVideoPlayer sharedInstance];
    
    self.videoPlayer.delegate = self;
    [self layoutPlayFrame];
    
    [self.videoPlayer playWithUrl:[NSURL URLWithString:videoUrl] showView:self.showPlayerView andSuperView:self.view withCache:YES];
    
    // impressionTracking
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.impressionTracking];
   
}

- (void)clearVideoPlayer{
    [self.videoPlayer stop];
    self.videoPlayer.delegate = nil;
    self.videoPlayer = nil;
    [self.showPlayerView removeFromSuperview];
}

- (void)layoutPlayFrame{
    if (!self.showPlayerView.superview) {
        [self.view addSubview:self.showPlayerView];
    }

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat minWidth = MIN(screenSize.width, screenSize.height);
    CGFloat scale = 0.5;
    [self.showPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(minWidth);
        make.center.equalTo(self.view);
        make.height.mas_equalTo(minWidth * scale);
    }];
    // 调整xib布局
    self.playerViewHeightConstraint.constant = minWidth * scale;
    self.playerViewWidthConstraint.constant = minWidth;
    self.topSpaceConstraint.constant = minWidth * scale + 40;
    
    if (!self.videoTipLabel.superview) {
        [self.view addSubview:self.videoTipLabel];

    }
    CGFloat topMargin =  (screenSize.height + (minWidth * scale)) * 0.5 + 5;
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

- (void)hideKeyBoard{
    [self.requestTextView resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideKeyBoard];
}

#pragma mark: UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self hideKeyBoard];
        return NO;
    }
    return YES;
}

#pragma mark: PAVideoPlayerDelegate
-(void)videoStartPlaying:(PAVideoPlayer *)player{
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.startTracking];
    [self showText:@"play start video"];
}
-(void)videoPlayerFinished:(PAVideoPlayer *)player{
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
-(void)videoPlayerClose:(PAVideoPlayer *)player isFinished:(BOOL)isFinished{
   
//    self.view.backgroundColor = [UIColor whiteColor];
    self.videoTipLabel.hidden = YES;
    if (isFinished) {
        [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.closeLinearTracking];
        
        [self showText:@"close finish video"];
        return ;
    }
    
    [[PAStatisticsReportManager shareManager] sendTrackingUrl:self.vastModel.trackingEvents.skipTracking];
   [self showText:@"close skip video"];
    
    
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

@end
