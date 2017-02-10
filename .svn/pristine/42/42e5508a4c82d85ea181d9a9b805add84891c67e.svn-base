//
//  BBQDynamicLayoutSquareDetail.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicLayoutSquareDetail.h"

@implementation BBQDynamicLayoutSquareDetail

- (void)layout {
    [self layoutProfile];
    [super layoutTextWithWidth:kScreenWidth - 30];
    [self layoutMedia];
    
    self.height = 0;
    self.height += 61;
    self.height += self.textSize.height ?: 15;
    self.height += self.mediaHeight;
    self.height += kDynamicCellFuncHeight;
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
    self.mediaType = BBQDynamicMediaTypePhoto;
    CGSize mediaSize = CGSizeZero;
    CGFloat mediaHeight = 0;
    CGFloat width = kScreenWidth - 30;
    
    Attachment *model = self.dynamic.attachinfo.firstObject;
    if (model.itype.integerValue == BBQAttachmentTypeVideo) {
        self.mediaType = BBQDynamicMediaTypeVideo;
        mediaHeight = CGFloatPixelRound(width * 3 / 4.0);
        mediaSize = CGSizeMake(width, mediaHeight);
    } else {
        mediaHeight = (width + 15) * self.dynamic.attachinfo.count - 15;
        mediaSize = CGSizeMake(width, width);
    }

    self.mediaSize = mediaSize;
    self.mediaHeight = mediaHeight;
}

@end
