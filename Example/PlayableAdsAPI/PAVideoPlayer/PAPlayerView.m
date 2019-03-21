//
//  PAPlayerView.m
//  PlayableAdsAPI
//
//  Created by Michael Tang on 2019/3/21.
//

#import "PAPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PAPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
