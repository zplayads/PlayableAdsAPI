//
//  PAStatisticsReportManager.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/19.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PAStatisticsReportManager.h"
#import <AFNetworking/AFNetworking.h>

@interface PAStatisticsReportManager ()

@property (nonatomic) AFHTTPSessionManager *httpManager;

@end

@implementation PAStatisticsReportManager

+ (instancetype)shareManager{
    static PAStatisticsReportManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.httpManager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (void)sendTrackingUrl:(NSString *)trackingUrl{
   
    [self requestNetworkUseGetMethod:trackingUrl parameters:nil success:nil failure:nil];
}
- (void)sendTrackers:(NSArray *)trackers{
    [trackers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self requestNetworkUseGetMethod:obj parameters:nil success:nil failure:nil];
    }];
}

- (void)requestNetworkUseGetMethod:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))sucess failure:(void (^)(NSError *error))failure{
    if (![NSURL URLWithString:url]) {
        return;
    }
    [self.httpManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
