//
//  PANetworkManager.m
//  PreviewWebDemo
//
//  Created by Michael Tang on 2019/1/4.
//  Copyright © 2019 MichaelTang. All rights reserved.
//

#import "PANetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "NSObject+YYModel.h"
#import "PAAPIModel.h"

@interface PANetworkManager ()

@property (nonatomic)AFHTTPSessionManager *httpManager;

@end

@implementation PANetworkManager

+(instancetype)sharedManager{
    static PANetworkManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
    
}

- (void)requestAPIDataSpport:(int)supportType
                     success:(void (^)(PAAPIModel *apiModel))success
                     failure:(void (^)(NSError *error))failure {
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"supportFunction1" ofType:@"json"];
    if (supportType == 2) {
        dataPath = [[NSBundle mainBundle] pathForResource:@"supportFunction2" ofType:@"json"];
    }
    NSData *objectData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:dataPath]];
    NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    
//    [self.httpManager POST:@"http://pa-engine.zplayads.com/v1/api/ads" parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject = %@",responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"rrr= %@",error);
//    }];
    NSString *httpUrl = @"https://pa-engine.zplayads.com/v1/api/ads";
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]
                                    initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request =
    [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:httpUrl parameters:nil error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"223.104.147.162" forHTTPHeaderField:@"X-Forwarded-For"];
    // 设置body+
    NSData *body = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:body];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes =
    [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
    manager.responseSerializer = responseSerializer;
    
    [[manager
      dataTaskWithRequest:request
      completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
          if (error) {
              failure(error);
              return ;
          }
          NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:&error];
          PAAPIModel *model = [PAAPIModel yy_modelWithJSON:dictFromData];
          success(model);
      }] resume];
}

- (void)requestVastDataCompleted:(void (^)(NSData *vastData))completed{
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"vastRequest" ofType:@"json"];
    NSData *objectData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:dataPath]];
    NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:nil];
    NSString *httpUrl = @"http://101.201.78.229:8999/v1/api/ads";
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]
                                    initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request =
    [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:httpUrl parameters:nil error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"223.104.147.164" forHTTPHeaderField:@"X-Forwarded-For"];
    // 设置body+
    NSData *body = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:body];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes =
    [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
    manager.responseSerializer = responseSerializer;
    
    [[manager
      dataTaskWithRequest:request
      completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
          if (error) {
              if (completed) {
                  completed(nil);
              }
              return ;
          }
          if (completed) {
              completed(responseObject);
          }
         
      }] resume];
}
- (AFHTTPSessionManager *)httpManager{
    if(!_httpManager){
        _httpManager = [AFHTTPSessionManager manager];
         [_httpManager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91" forHTTPHeaderField:@"User-Agent"];
    }
    return _httpManager;
}

@end
