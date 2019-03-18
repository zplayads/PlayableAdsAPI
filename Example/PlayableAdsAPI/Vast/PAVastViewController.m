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

@interface PAVastViewController ()

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
    }
    
    NSArray *ads = [doc.rootElement elementsForName:@"Ad"];
    for (GDataXMLElement *element in ads) {
        PAVastAdModel *model = [self convertToAdModelWithXMLAdTag:element];
    }
    
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


@end
