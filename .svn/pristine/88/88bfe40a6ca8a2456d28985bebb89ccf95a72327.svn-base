//
//  UITableView+BBQTableViewCategory.m
//  BBQ
//
//  Created by 朱琨 on 16/3/2.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "UITableView+BBQTableViewCategory.h"

@implementation UITableView (BBQTableViewCategory)

- (BOOL)allowsHeaderViewsToFloat {
    return self.floatHeaderView;
}

- (BOOL)floatHeaderView {
    NSNumber *f = objc_getAssociatedObject(self, _cmd);
    if (!f) {
        f = [NSNumber numberWithBool:YES];
        objc_setAssociatedObject(self, _cmd, f, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [f boolValue];
}

- (void)setFloatHeaderView:(BOOL)floatHeaderView {
    NSNumber *f = [NSNumber numberWithBool:floatHeaderView];
    objc_setAssociatedObject(self, @selector(floatHeaderView), f, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
