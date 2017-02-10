//
//  BBQVistisApi.m
//  BBQ
//
//  Created by slovelys on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQVistisApi.h"

@interface BBQVistisApi ()

@property (nonatomic, strong) Dynamic *dynamic;

@end

@implementation BBQVistisApi

- (instancetype)initWithDynamic:(Dynamic *)dynamic {
    if (self = [super init]) {
        _dynamic = dynamic;
    }
    return self;
}

- (NSString *)requestUrl {
    return URL_DYNAMIC_VISITS;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

- (id)requestArgument {
    return  @{
              @"guid" : _dynamic.guid,
              @"dtype" : _dynamic.dtype
              };
}

@end
