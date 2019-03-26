//
//  PANetworkManager.h
//  PreviewWebDemo
//
//  Created by Michael Tang on 2019/1/4.
//  Copyright © 2019 MichaelTang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAAPIModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface PANetworkManager : NSObject
+(instancetype)sharedManager;
- (void)requestAPIDataSpport:(NSDictionary *)parameters
                     success:(void (^)(PAAPIModel *apiModel))success
                     failure:(void (^)(NSError *error))failure;

// request vast
- (void)requestVastData:(NSDictionary *)parameters completed:(void (^)(NSData *vastData))completed;

@end
NS_ASSUME_NONNULL_END
