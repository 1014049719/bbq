//
//  BBQShareDynamicApi.m
//  BBQ
//
//  Created by 朱琨 on 15/11/16.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQShareDynamicApi.h"

@interface BBQShareDynamicApi ()

@property (copy, nonatomic) NSString *guid;
@property (strong, nonatomic) NSNumber *sharetype;
@property (strong, nonatomic) NSNumber *uid;
@property (nonatomic, strong) NSNumber *dtype;

@end

@implementation BBQShareDynamicApi

- (instancetype)initWithGuid:(NSString *)guid sharetype:(NSNumber *)type baobaouid:(NSNumber *)uid dtype:(NSNumber *)dtype {
    if (self = [super init]) {
        _guid = guid;
        _sharetype = type;
        _uid = uid;
        _dtype = dtype;
    }
    return self;
}

- (NSString *)requestUrl {
    return URL_SHARE_DYNA;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

- (id)requestArgument {
    return @{
             @"guid": _guid,
             @"sharetype": _sharetype,
             @"baobaouid": _uid,
             @"dtype" : _dtype
             };
}
@end
