//
//  BBQDynamicLikeApi.m
//  BBQ
//
//  Created by 朱琨 on 16/3/10.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicLikeApi.h"

@interface BBQDynamicLikeApi ()

@property (strong, nonatomic) Dynamic *dynamic;

@end

@implementation BBQDynamicLikeApi

- (instancetype)initWithDynamic:(Dynamic *)dynamic {
    if (self = [super init]) {
        _dynamic = dynamic;
    }
    return self;
}

- (NSString *)requestUrl {
    return URL_DYNAMIC_LIKE;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

- (id)requestArgument {
    return @{
             @"guid": _dynamic.guid,
             @"dtype": _dynamic.dtype,
             @"action": _dynamic.islike ? @"add" : @"cancel"
             };
}

@end
