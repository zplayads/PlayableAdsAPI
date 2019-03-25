//
//  PAIPAModel.h
//  PreviewWebDemo
//
//  Created by Michael Tang on 2019/1/4.
//  Copyright © 2019 MichaelTang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kSupportFunctionType_01 = 1,
    kSupportFunctionType_02,
} SupportFunctionType;

NS_ASSUME_NONNULL_BEGIN

@interface PAAdsModel : NSObject
@property (nonatomic) NSString  *ad_unit_id;
@property (nonatomic) NSString  *app_bundle;
@property (nonatomic) NSString  *playable_ads_html;
@property (nonatomic) NSString *target_url;
@property (nonatomic , assign) SupportFunctionType support_function;

@end

@interface PAAPIModel : NSObject
@property (nonatomic) NSArray<PAAdsModel *>  *ads;

@end

NS_ASSUME_NONNULL_END
