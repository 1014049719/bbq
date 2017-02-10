//
//  BBQDynamicCell.m
//  BBQ
//
//  Created by 朱琨 on 15/11/17.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDynamicCell.h"
#import "BBQDynamicCommentCell.h"
#import <NYXImagesKit.h>
#import "UIImage+Common.h"
#import "BBQThemeManager.h"
#import "BBQDynamicLayoutTimeline.h"
#import "BBQDynamicLayoutDetail.h"
#import "BBQDynamicLayoutSquareTimeline.h"
#import "BBQDynamicLayoutSquareDetail.h"

NSString * const kDynamicCellTimelineIdentifier = @"BBQDynamicViewTimeline";
NSString * const kDynamicCellDetailIdentifier = @"BBQDynamicViewDetail";
NSString * const kDynamicCellSquareTimelineIdentifier = @"BBQDynamicViewSquareTimeline";
NSString * const kDynamicCellSquareDetailIdentifier = @"BBQDynamicViewSquareDetail";

@implementation BBQDynamicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _dynamicView = [BBQDynamicFactory dynamicViewWithIdentifier:reuseIdentifier];
        [self.contentView addSubview:_dynamicView];
    }
    return self;
}

- (void)setLayout:(BBQDynamicLayout *)layout {
    _layout = layout;
    _dynamic = layout.dynamic;
//    self.height = layout.height;
    layout.cell = self;
    _dynamicView.cell = self;
    self.contentView.height = layout.height;
    _dynamicView.layout = layout;
}

@end
