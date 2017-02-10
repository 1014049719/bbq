//
//  BBQUserInfoApi.m
//  BBQ
//
//  Created by 朱琨 on 16/1/12.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQUserInfoApi.h"

@interface BBQUserInfoApi ()

@property (strong, nonatomic) NSNumber *uid;

@end

@implementation BBQUserInfoApi

- (instancetype)initWithUid:(NSNumber *)uid {
    if (self = [super init]) {
        _uid = uid;
    }
    return self;
}

- (NSString *)requestUrl {
    return URL_GET_USER_DATA;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

- (id)requestArgument {
    return @{
             @"uid": _uid
             };
}

- (void)start {
    [super start];
}

- (void)startWithCompletionBlockWithSuccess:(YTKRequestCompletionBlock)success failure:(YTKRequestCompletionBlock)failure {
    [super startWithCompletionBlockWithSuccess:success failure:failure];
}

@end
