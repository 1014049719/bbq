//
//  BBQDynamicLayoutStyleSquareTimeline.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicLayoutSquareTimeline.h"

@implementation BBQDynamicLayoutSquareTimeline

- (void)layout {
    self.marginTop = kDynamicCellTopMargin;
    self.marginBottom = kDynamicCellToolbarBottomMargin;
    
    [self layoutProfile];
    [super layoutTextWithWidth:kScreenWidth - 50];
    [self layoutMedia];
    
    self.height = 0;
    self.height += self.marginTop;
    self.height += 61;
    self.height += self.textSize.height ?: 15;
    self.height += self.mediaHeight;
    self.height += kDynamicCellFuncHeight;
    self.height += kDynamicCellToolbarHeight;
    self.height += self.marginBottom;
}

- (void)layoutProfile {
    [super layoutName];
    [super layoutPostTime];
}

- (void)layoutMedia {
    self.mediaSize = CGSizeZero;
    self.mediaHeight = 0;
    if (!self.dynamic.attachinfo.count) {
        self.mediaType = BBQDynamicMediaTypeNone;
        return;
    }
    
    Attachment *model = self.dynamic.attachinfo.firstObject;
    self.mediaType = model.itype.integerValue == BBQAttachmentTypePhoto ? BBQDynamicMediaTypePhoto : BBQDynamicMediaTypeVideo;
    CGFloat width = kScreenWidth - 30;
    CGFloat height = width * 0.75;
    self.mediaSize = CGSizeMake(width, height);
    self.mediaHeight = height;
}

@end
