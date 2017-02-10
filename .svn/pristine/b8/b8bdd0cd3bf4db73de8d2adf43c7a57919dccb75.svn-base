//
//  BBQFetchAppointedDynamicApi.m
//  BBQ
//
//  Created by 朱琨 on 15/11/16.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQFetchAppointedDynamicApi.h"

@interface BBQFetchAppointedDynamicApi ()

@property (copy, nonatomic) NSString *guid;
@property (assign, nonatomic) BBQDynamicGroupType type;

@end

@implementation BBQFetchAppointedDynamicApi

- (instancetype)initWithGuid:(NSString *)guid dtype:(BBQDynamicGroupType)type {
    if (self = [super init]) {
        _guid = guid;
        _type = type;
    }
    return self;
}

- (NSString *)requestUrl {
    return URL_QUERY_SPECIFY_DYNA;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

- (id)requestArgument {
    return @{
             @"guid": _guid,
             @"dtype": @(_type)
             };
}

@end
