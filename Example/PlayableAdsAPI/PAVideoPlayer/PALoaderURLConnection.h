//
//  PALoaderURLConnection.h
//  PlayableAdsAPI
//
//  Created by Michael Tang on 2019/3/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PAVideoRequestTask.h"

@protocol PALoaderURLConnectionDelegate <NSObject>

- (void)didFinishLoadingWithTask:(PAVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(PAVideoRequestTask *)task withError:(NSInteger )errorCode;

@end

@interface PALoaderURLConnection : NSURLConnection <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) PAVideoRequestTask *task;
@property (nonatomic, weak  ) id<PALoaderURLConnectionDelegate> delegate;
- (NSURL *)getSchemeVideoURL:(NSURL *)url;

@end
