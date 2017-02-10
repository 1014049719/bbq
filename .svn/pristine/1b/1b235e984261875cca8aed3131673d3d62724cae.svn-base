//
//  BBQDynamicLayoutFactory.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicLayoutFactory.h"

static NSArray * layoutStyles;

@implementation BBQDynamicLayoutFactory

+ (void)load {
    if (!layoutStyles) {
        layoutStyles = @[@"BBQDynamicLayoutTimeline", @"BBQDynamicLayoutDetail", @"BBQDynamicLayoutWelcome", @"BBQDynamicLayoutSquareTimeline", @"BBQDynamicLayoutSquareDetail"];
    }
}

+ (BBQDynamicLayout *)layoutWithDynamic:(Dynamic *)dynamic style:(BBQDynamicLayoutStyle)style {
    Class cls = NSClassFromString(layoutStyles[style]);
    BBQDynamicLayout *layout = [[cls alloc] initWithDynamic:dynamic style:style];
    return layout;
}

@end
