//
//  ZplayAppStore.h
//  Expecta
//
//  Created by d on 19/10/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PAAppStoreDelegate <NSObject>
@optional
- (void)appStoreDidAppear;
- (void)appStoreDidDisappear;
@end
@interface ZplayAppStore : NSObject
@property (nonatomic, weak, nullable) id<PAAppStoreDelegate> appStoreDelegate;

- (instancetype)initWithItunesID:(NSNumber *)itunesID itunesLink:(NSString *)url;

- (void)present;

@end

NS_ASSUME_NONNULL_END
