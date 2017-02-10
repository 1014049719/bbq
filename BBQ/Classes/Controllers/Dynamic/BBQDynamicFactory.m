//
//  BBQDynamicFactory.m
//  BBQ
//
//  Created by 朱琨 on 16/1/18.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicFactory.h"

static NSArray * styles;

@implementation BBQDynamicFactory

+ (BBQDynamicView *)dynamicViewWithIdentifier:(NSString *)identifier {
    Class cls = NSClassFromString(identifier);
    BBQDynamicView *view = [[cls alloc] initWithFrame:CGRectZero];
    return view;
}

+ (BBQDynamicLayout *)layoutWithDynamic:(Dynamic *)dynamic style:(BBQDynamicLayoutStyle)style {
    Class cls = NSClassFromString([self layoutStyles][style]);
    BBQDynamicLayout *layout = [[cls alloc] initWithDynamic:dynamic style:style];
    return layout;
}

+ (NSArray *)layoutStyles {
    if(!styles) {
        styles = @[@"BBQDynamicLayoutTimeline", @"BBQDynamicLayoutDetail", @"BBQDynamicLayoutWelcome", @"BBQDynamicLayoutSquareTimeline", @"BBQDynamicLayoutSquareDetail"];
    }
    return styles;
}

@end
