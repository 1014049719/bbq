//
//  BBQSearchShoolModel.m
//  BBQ
//
//  Created by anymuse on 16/3/14.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQSearchShoolModel.h"
#import "BBQSearchClassModel.h"
@implementation BBQSearchShoolModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"myclassarr": [BBQSearchClassModel class]
             };
}
@end
