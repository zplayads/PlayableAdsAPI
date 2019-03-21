 
//
//
//  PAVideoRequestTask.h
//  PlayableAdsAPI
//
//  Created by Michael Tang on 2019/3/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class PAVideoRequestTask;

@protocol PAVideoRequestTaskDelegate <NSObject>

- (void)task:(PAVideoRequestTask *)task didReciveVideoLength:(NSUInteger)videoLength mimeType:(NSString *)mimeType;
- (void)didReciveVideoDataWithTask:(PAVideoRequestTask *)task;
- (void)didFinishLoadingWithTask:(PAVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(PAVideoRequestTask *)task withError:(NSInteger)errorCode;

@end

@interface PAVideoRequestTask : NSObject

@property (nonatomic, strong, readonly) NSURL         *url;
@property (nonatomic, readonly)         NSUInteger    offset;

@property (nonatomic, readonly)         NSUInteger    videoLength;
@property (nonatomic, readonly)         NSUInteger    downLoadingOffset;
@property (nonatomic, readonly)         NSString      *mimeType;
@property (nonatomic, assign)           BOOL          isFinishLoad;

@property (nonatomic, weak)             id<PAVideoRequestTaskDelegate> delegate;

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;

- (void)cancel;

- (void)continueLoading;

- (void)clearData;

@end
