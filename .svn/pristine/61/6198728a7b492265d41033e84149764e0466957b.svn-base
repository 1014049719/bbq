//
//  BBQDynamicLayoutStyleTimeline.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicLayoutTimeline.h"
#import "BBQTextLinePositionModifier.h"


static NSDictionary * dailyReportItems = nil;

@implementation BBQDynamicLayoutTimeline

+(void)load {
    if (!dailyReportItems) {
        dailyReportItems = @{
                             @"早餐": @{@"imageName": @"dailyreport_breakfast", @"color": kDynamicCellTagBreakfastColor},
                             @"午餐": @{@"imageName": @"dailyreport_lunch", @"color": kDynamicCellTagLunchColor},
                             @"午睡": @{@"imageName": @"dailyreport_noonbreak", @"color": kDynamicCellTagNoonbreakColor},
                             @"喝水": @{@"imageName": @"dailyreport_drinking", @"color": kDynamicCellTagDrinkingColor},
                             @"学习": @{@"imageName": @"dailyreport_study", @"color": kDynamicCellTagStudyColor},
                             @"情绪": @{@"imageName": @"dailyreport_emotion", @"color": kDynamicCellTagEmotionColor},
                             @"健康": @{@"imageName": @"dailyreport_health", @"color": kDynamicCellTagHealthColor},
                             @"寄语": @{@"imageName": @"dailyreport_words", @"color": kDynamicCellTagWordsColor},
                             @"校园公告": @{@"imageName": @"dailyreport_message", @"color": kDynamicCellTagMessageColor},
                             @"班级公告": @{@"imageName": @"dailyreport_message", @"color": kDynamicCellTagMessageColor},
                             @"布置作业": @{@"imageName": @"dailyreport_homework", @"color": kDynamicCellTagHomeworkColor},
                             @"教职工公告": @{@"imageName": @"dailyreport_message", @"color": kDynamicCellTagMessageColor},
                             };
    }
}

- (void)layout {
    self.marginTop = kDynamicCellTopMargin;
    self.funcHeight = kDynamicCellFuncHeight;
    self.marginBottom = kDynamicCellToolbarBottomMargin;
    
    [self layoutDateView];
    [super layoutProfile];
    [self layoutTagWithWidth:kDynamicCellProfileWidth - kDynamicCellPadding * 2 - 24 - 5];
    [super layoutTextWithWidth:kDynamicCellContentWidth];
    [self layoutMedia];
    [super layoutGifts];
    [self layoutComments];

    self.height = 0;
    self.height += self.marginTop;
    self.height += kDynamicCellProfileHeight;
    self.height += self.tagHeight;
    self.height += self.textSize.height ?: 15;
    self.height += self.mediaHeight;
    self.height += kDynamicCellFuncHeight;
    self.height += self.giftHeight;
    self.height += self.commentHeight;
    self.height += kDynamicCellToolbarHeight;
    self.height += self.marginBottom;
}

- (void)layoutTagWithWidth:(CGFloat)width {
    [super layoutTagWithWidth:width];
    if ([reportTagType containsObject:self.dynamic.ispajs]) {
        self.tagType = BBQDynamicTagTypeReport;
        NSString *imageName = nil;
        NSString *tagStr;
        UIColor *color = nil;
        
        if (self.dynamic.ispajs.integerValue == BBQDynamicContentTypeDailyReport) {
            tagStr = self.dynamic.dynatag;
        } else if (self.dynamic.ispajs.integerValue == BBQDynamicContentTypeSchoolBulletin) {
            tagStr = @"校园公告";
            imageName = @"dailyreport_message";
            color = kDynamicCellTagMessageColor;
        } else if (self.dynamic.ispajs.integerValue == BBQDynamicContentTypeClassBulletin) {
            tagStr = @"班级公告";
            imageName = @"dailyreport_message";
            color = kDynamicCellTagMessageColor;
        } else if (self.dynamic.ispajs.integerValue == BBQDynamicContentTypeHomework) {
            tagStr = @"布置作业";
            imageName = @"dailyreport_homework";
            color = kDynamicCellTagHomeworkColor;
        } else {
            tagStr = @"教职工公告";
            imageName = @"dailyreport_message";
            color = kDynamicCellTagMessageColor;
        }
        
        if ([dailyReportItems containsObjectForKey:tagStr]) {
            imageName = dailyReportItems[tagStr][@"imageName"];
            color = dailyReportItems[tagStr][@"color"];
        }

        NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:tagStr];
        tagText.font = [UIFont systemFontOfSize:kDynamicCellNormalFontSize];
        tagText.color = color;
        tagText.lineBreakMode = NSLineBreakByCharWrapping;
        
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kDynamicCellProfileWidth - 46, 16)];
        container.maximumNumberOfRows = 1;
        self.tagTextLayout = [YYTextLayout layoutWithContainer:container text:tagText];
        self.tagColor = color;
        self.tagPicName = imageName;
        self.tagHeight = kDynamicCellTagReportHeight;
    }
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
    switch (self.dynamic.attachinfo.count) {
        case 1: {
            Attachment *model = self.dynamic.attachinfo.firstObject;
            if (model.itype.integerValue == BBQAttachmentTypeVideo) {
                self.mediaType = BBQDynamicMediaTypeVideo;
                mediaHeight = CGFloatPixelRound(kDynamicCellContentWidth * 3 / 4.0);
                mediaSize = CGSizeMake(kDynamicCellContentWidth, mediaHeight);
            } else {
                mediaHeight = CGFloatPixelRound(kDynamicCellContentWidth * 7 / 6.0);
                mediaSize = CGSizeMake(kDynamicCellContentWidth, mediaHeight);
            }
        } break;
        case 2: {
            mediaHeight = CGFloatPixelRound((kDynamicCellContentWidth - kDynamicCellPaddingPic) / 2.0);
            mediaSize = CGSizeMake(mediaHeight, mediaHeight);
        } break;
        case 3: case 4: {
            CGFloat height = CGFloatPixelRound((kDynamicCellContentWidth - kDynamicCellPaddingPic) / 2.0);
            mediaSize = CGSizeMake(height, height);
            mediaHeight = height * 2 + kDynamicCellPaddingPic;
        } break;
        case 5: case 6: {
            CGFloat height = CGFloatPixelRound((kDynamicCellContentWidth - kDynamicCellPaddingPic * 2) / 3.0);
            mediaSize = CGSizeMake(height, height);
            mediaHeight = height * 2 + kDynamicCellPaddingPic;
        } break;
        default: {
            CGFloat height = CGFloatPixelRound((kDynamicCellContentWidth - kDynamicCellPaddingPic * 2) / 3.0);
            mediaSize = CGSizeMake(height, height);
            mediaHeight = height * 3 + kDynamicCellPaddingPic * 2;
        } break;
    }
    self.mediaSize = mediaSize;
    self.mediaHeight = mediaHeight;
}

@end
