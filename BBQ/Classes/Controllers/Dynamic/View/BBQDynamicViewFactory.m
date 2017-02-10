//
//  BBQDynamicViewFactory.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicViewFactory.h"

@implementation BBQDynamicViewFactory

+ (BBQDynamicView *)dynamicViewWithIdentifier:(NSString *)identifier {
    Class cls = NSClassFromString(identifier);
    BBQDynamicView *view = [[cls alloc] initWithFrame:CGRectZero];
    return view;
}

@end
