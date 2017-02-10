//
//  BBQDynamicLayoutStyleWelcome.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicLayoutWelcome.h"

@implementation BBQDynamicLayoutWelcome

- (void)layout {
    if (self.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
        [self layoutSquare];
    } else {
        [self layoutTimeline];
    }
}

- (void)layoutTimeline {
    self.marginTop = kDynamicCellTopMargin;
    self.funcHeight = kDynamicCellFuncHeight;
    self.marginBottom = kDynamicCellToolbarBottomMargin;
    
    [self layoutDateView];
    [self layoutProfile];
    [super layoutTextWithWidth:kDynamicCellContentWidth];
    
    self.height = 0;
    self.height += self.marginTop;
    self.height += kDynamicCellProfileHeight;
    self.height += self.textSize.height;
    self.height += self.marginBottom;
}

- (void)layoutSquare {
    self.marginTop = kDynamicCellTopMargin;
    self.funcHeight = kDynamicCellFuncHeight;
    self.marginBottom = kDynamicCellToolbarBottomMargin;
    
    [self layoutProfile];
    [super layoutTextWithWidth:kScreenWidth - 50];
    
    self.height = 0;
    self.height += self.marginTop;
    self.height += 61;
    self.height += self.textSize.height;
    self.height += self.marginBottom;
}

@end
