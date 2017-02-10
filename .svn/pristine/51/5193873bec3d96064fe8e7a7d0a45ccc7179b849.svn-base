//
//  BBQDeleteCommentApi.m
//  BBQ
//
//  Created by 朱琨 on 15/11/16.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDeleteCommentApi.h"

@interface BBQDeleteCommentApi ()

@property (strong, nonatomic) Comment *comment;
@property (strong, nonatomic) NSNumber *type;

@end

@implementation BBQDeleteCommentApi

- (instancetype)initWithComment:(Comment *)comment groupType:(NSNumber *)type {
    if (self = [super init]) {
        _comment = comment;
        _type = type;
    }
    return self;
}

- (NSString *)requestUrl {
    return URL_DELETE_COMMENT;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

- (id)requestArgument {
    return @{
             @"cguid": _comment.cguid,
             @"dtype": _type
             };
}

@end
