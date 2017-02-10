//
//  BBQTopicsModel.m
//  BBQ
//
//  Created by anymuse on 16/3/3.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQTopicsModel.h"

@implementation BBQTopicsModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"childdata": [BBQTopicsModel class]
             };
}
@end
