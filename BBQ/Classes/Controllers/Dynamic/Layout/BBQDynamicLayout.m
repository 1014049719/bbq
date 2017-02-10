//
//  BBQDynamicLayout.m
//  BBQ
//
//  Created by 朱琨 on 15/11/17.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDynamicLayout.h"
#import "BBQDynamicHelper.h"
#import <DateTools.h>
#import "BBQTextLinePositionModifier.h"
#import "BBQDynamicCommentLayout.h"
#import "NSString+Common.h"
#import "BBQDynamicCell.h"

NSArray * reportTagType;

@implementation BBQDynamicLayout

+ (void)load {
    if (!reportTagType) {
        reportTagType = @[@(BBQDynamicContentTypeDailyReport), @(BBQDynamicContentTypeSchoolBulletin), @(BBQDynamicContentTypeClassBulletin), @(BBQDynamicContentTypeHomework)];
    }
}

- (instancetype)initWithDynamic:(Dynamic *)dynamic style:(BBQDynamicLayoutStyle)style {
    if (self = [super init]) {
        _dynamic = dynamic;
        _style = style;
        [self layout];
    }
    return self;
}

- (void)layout {
    [NSException raise:NSInternalInconsistencyException format:@"You muse override%@in a subclass", NSStringFromSelector(_cmd)];
}

- (void)layoutDateView {
    _dateLayout = nil;
    if (!_dynamic.graphtime || !_dynamic.graphtime.integerValue) return;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_dynamic.graphtime.integerValue];
    NSInteger day = date.day;
    NSInteger month = date.month;
    NSInteger year = date.year;
    
    NSMutableAttributedString *dateText = [NSMutableAttributedString new];
    
    NSMutableAttributedString *dayText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02ld", (long)day]];
    dayText.font = [UIFont boldSystemFontOfSize:18];
    dayText.color = UIColorHex(999999);
    [dateText appendAttributedString:dayText];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"日"];
    str.font = [UIFont systemFontOfSize:10];
    str.color = UIColorHex(999999);
    [dateText appendAttributedString:str];
    
    [dateText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    NSMutableAttributedString *monthText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld.%02ld", (long)year, (long)month]];
    monthText.font = [UIFont systemFontOfSize:10];
    monthText.color = [UIColor whiteColor];
    [dateText appendAttributedString:monthText];
    
    dateText.lineSpacing = 3;
    dateText.alignment = NSTextAlignmentCenter;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(45, MAXFLOAT)];
    container.maximumNumberOfRows = 2;
    _dateLayout = [YYTextLayout layoutWithContainer:container text:dateText];
}

- (void)layoutProfile {
    [self layoutName];
    [self layoutSource];
    [self layoutPostTime];
}

- (void)layoutName {
    NSString *nameStr = nil;
    if (_dynamic.ispajs.integerValue == BBQDynamicContentTypePickUp) {
        nameStr = @"小宝";
    } else if ([reportTagType containsObject:_dynamic.ispajs]) {
        nameStr = _dynamic.crenickname;
    } else {
        if (_dynamic.groupkey.integerValue == BBQGroupkeyTypeParent && _dynamic.dtype.integerValue != BBQDynamicGroupTypeSquare) {
            NSString *strRelation =
            [NSString relationshipWithID:_dynamic.gxid gxname:_dynamic.gxname];
            if ([strRelation isNotBlank]) {
                nameStr =
                [_dynamic.baobaoname stringByAppendingString:strRelation];
            } else {
                nameStr = _dynamic.crenickname;
            }
        } else {
            nameStr = _dynamic.crenickname;
        }
    }
    if (![nameStr isNotBlank]) {
        _nameTextLayout = nil;
        return;
    }
    NSMutableAttributedString *nameText = [[NSMutableAttributedString alloc] initWithString:nameStr];
    nameText.font = [UIFont systemFontOfSize:kDynamicCellNameFontSize];
    nameText.color = kDynamicCellTextNormalColor;
    nameText.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize size = [nameStr sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kDynamicCellNameFontSize]}];
    self.nameSize = CGSizeMake(ceil(kScreenWidth * 0.4), ceil(size.height));
    _nameTextLayout = [YYTextLayout layoutWithContainerSize:self.nameSize text:nameText];
}

- (void)layoutSource {
    NSString *sourceStr = nil;
    if (_dynamic.ispajs.integerValue == BBQDynamicContentTypePickUp) {
        sourceStr = @"宝宝圈小管家";
    } else if (_dynamic.ispajs.integerValue == BBQDynamicContentTypeSchoolBulletin) {
        sourceStr = _dynamic.schoolname;
    } else if ([reportTagType containsObject:_dynamic.ispajs]) {
        sourceStr = _dynamic.classname;
    } else {
        if (_dynamic.groupkey.integerValue == BBQGroupkeyTypeTeacher) {
            sourceStr = _dynamic.classname;
        } else if (_dynamic.groupkey.integerValue == BBQGroupkeyTypeMaster) {
            sourceStr = _dynamic.schoolname;
        } else {
            sourceStr = _dynamic.crenickname;
        }
    }
    if (!sourceStr || !sourceStr.length) {
        _sourceTextLayout = nil;
        return;
    }
    NSMutableAttributedString *sourceText = [[NSMutableAttributedString alloc] initWithString:sourceStr];
    sourceText.font = [UIFont systemFontOfSize:kDynamicCellSourceFontSize];
    sourceText.color = kDynamicCellTextSubTitleColor;
    sourceText.lineBreakMode = NSLineBreakByCharWrapping;
    
    CGSize size = [sourceStr sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kDynamicCellSourceFontSize]}];
    self.sourceSize = CGSizeMake(ceil(size.width), ceil(size.height));
    _sourceTextLayout = [YYTextLayout layoutWithContainerSize:_sourceSize text:sourceText];
}

- (void)layoutPostTime {
    _postTimeTextLayout = nil;
    if (!_dynamic.dateline || !_dynamic.dateline.integerValue) return;
    NSString *postTimeStr = [NSString
                             stringWithFormat:
                             @"%@",
                             [NSDate timeAgoSinceDate:[NSDate dateWithTimeIntervalSince1970:
                                                       _dynamic.dateline.integerValue]]];
    if (postTimeStr) {
        NSMutableAttributedString *postTimeText = [[NSMutableAttributedString alloc] initWithString:postTimeStr];
        postTimeText.font = [UIFont systemFontOfSize:kDynamicCellSourceFontSize];
        postTimeText.color = kDynamicCellTextSubTitleColor;
        postTimeText.lineBreakMode = NSLineBreakByCharWrapping;
        postTimeText.alignment = NSTextAlignmentRight;
        
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(150, MAXFLOAT)];
        container.maximumNumberOfRows = 1;
        _postTimeTextLayout = [YYTextLayout layoutWithContainer:container text:postTimeText];
    }
}

- (void)layoutTagWithWidth:(CGFloat)width {
    self.tagType = BBQDynamicTagTypeNone;
    self.tagHeight = 0;
    self.tagTextLayout = nil;
    if (![self.dynamic.dynatag isNotBlank]) return;
    
    self.tagType = BBQDynamicTagTypeFirst;
    NSString *tagStr = self.dynamic.dynatag;
    NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:tagStr];
    tagText.font = [UIFont systemFontOfSize:kDynamicCellNormalFontSize];
    tagText.color = kDynamicCellTagFirstColor;
    tagText.lineBreakMode = NSLineBreakByCharWrapping;
    
    BBQTextLinePositionModifier *modifier = [BBQTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:kDynamicCellNormalFontSize];
    
    //        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kDynamicCellProfileWidth - kDynamicCellPadding * 2 - 24 - 5, HUGE)];
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(width, HUGE)];
    container.linePositionModifier = modifier;
    self.tagTextLayout = [YYTextLayout layoutWithContainer:container text:tagText];
    self.tagPicName = @"dynamic_create_first_selected";
    self.tagHeight = MAX([modifier heightForLineCount:_tagTextLayout.lines.count] + 15, 39);
    
    if (self.dynamic.ispajs.integerValue == BBQDynamicContentTypeNormal) {
        self.tagType = BBQDynamicTagTypeFirst;
        NSString *tagStr = self.dynamic.dynatag;
        NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:tagStr];
        tagText.font = [UIFont systemFontOfSize:kDynamicCellNormalFontSize];
        tagText.color = kDynamicCellTagFirstColor;
        tagText.lineBreakMode = NSLineBreakByCharWrapping;
        
        BBQTextLinePositionModifier *modifier = [BBQTextLinePositionModifier new];
        modifier.font = [UIFont fontWithName:@"Heiti SC" size:kDynamicCellNormalFontSize];
        
        //        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kDynamicCellProfileWidth - kDynamicCellPadding * 2 - 24 - 5, HUGE)];
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(width, HUGE)];
        container.linePositionModifier = modifier;
        self.tagTextLayout = [YYTextLayout layoutWithContainer:container text:tagText];
        self.tagPicName = @"dynamic_create_first_selected";
        self.tagHeight = MAX([modifier heightForLineCount:_tagTextLayout.lines.count] + 15, 39);
    }
}

- (void)layoutTitle {
    
}

- (void)layoutTextWithWidth:(CGFloat)width {
    _textSize = CGSizeZero;
    _textLayout = nil;
    if (![_dynamic.content isNotBlank] && !_dynamic.fb_flag) return;
    CGFloat topPadding = 7.5;
    if (![_dynamic.dynatag isNotBlank]) {
        topPadding = 15;
    }
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    if (_dynamic.fb_flag) {
        NSMutableAttributedString *preString = [[NSMutableAttributedString alloc] initWithString:@"转发于"];
        preString.font = [UIFont systemFontOfSize:kDynamicCellNormalFontSize];
        preString.color = kDynamicCellTextNormalColor;
        
        [text appendAttributedString:preString];
        NSMutableAttributedString *usernameText = [[NSMutableAttributedString alloc] initWithString:_dynamic.oldcrenickname];
        
        YYTextBorder *highlightBorder = [YYTextBorder new];
        highlightBorder.strokeWidth = 0;
        highlightBorder.strokeColor = [UIColor lightGrayColor];
        highlightBorder.fillColor = [UIColor lightGrayColor];
        
        usernameText.font = [UIFont systemFontOfSize:kDynamicCellNormalFontSize];
        usernameText.color = UIColorHex(ff6440);
        YYTextHighlight *usernameHighlight = [YYTextHighlight new];
        [usernameHighlight setBackgroundBorder:highlightBorder];
        @weakify(self)
        usernameHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            @strongify(self)
            if ([self.cell.delegate respondsToSelector:@selector(didClickUserWithID:)]) {
                [self.cell.delegate didClickUserWithID:self.dynamic.oldcreuid];
            }
        };
        [usernameText setTextHighlight:usernameHighlight range:usernameText.rangeOfAll];
        [text appendAttributedString:usernameText];
        [text appendString:@"：\n"];
    }
    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithString: _dynamic.content];
    contentText.font = [UIFont systemFontOfSize:kDynamicCellNormalFontSize];
    contentText.color = kDynamicCellTextNormalColor;
    [text appendAttributedString:contentText];
    text.lineBreakMode = NSLineBreakByCharWrapping;
    
    BBQTextLinePositionModifier *modifier = [BBQTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:kDynamicCellNormalFontSize];
    modifier.paddingTop = topPadding;
    modifier.paddingBottom = 15;
    
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(width, HUGE);
    container.linePositionModifier = modifier;
    
    _textLayout = [YYTextLayout layoutWithContainer:container text:text];
    if (!_textLayout) return;
    _textSize = CGSizeMake(width, [modifier heightForLineCount:_textLayout.rowCount]);
}

- (void)layoutMedia {
    
}

- (void)layoutGifts {
    _giftHeight = 0;
    _giftTextLayout = nil;
    if (!_dynamic.giftdata || !_dynamic.giftdata.count) return;
    
    NSString *str = [NSString stringWithFormat:@"共收到%@个人赠送的礼物", @(_dynamic.giftdata.count)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    text.color = kDynamicCellTextSubTitleColor;
    text.font = [UIFont systemFontOfSize:10];
    text.lineBreakMode = NSLineBreakByCharWrapping;
    
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(kDynamicCellContentWidth - 35, HUGE);
    container.maximumNumberOfRows = 1;
    
    _giftTextLayout = [YYTextLayout layoutWithContainer:container text:text];
    if (!_giftTextLayout) return;
    if (_dynamic.dtype.integerValue == BBQDynamicGroupTypeBaby) {
        _giftHeight = 7 + 10 + 12 + 10 + 1 + 10 + kScaleFrom_iPhone6_Desgin(50) + 7 + 5 + kScaleFrom_iPhone6_Desgin(29) + 5 + 2.5;
    } else {
        _giftHeight = 7 + 10 + 12 + 10 + 1 + 10 + kScaleFrom_iPhone6_Desgin(50) + 7 + 5 + 2.5;
    }
}

- (void)layoutComments {
    _commentHeight = 0;
    if (!_dynamic.reply.count || _style == BBQDynamicLayoutStyleDetail) return;
    NSMutableArray *tempLayouts = [NSMutableArray array];
    for (Comment *comment in _dynamic.reply) {
        BBQDynamicCommentLayout *layout = [[BBQDynamicCommentLayout alloc] initWithComment:comment style:BBQDynamicLayoutStyleTimeline];
        _commentHeight += layout.height;
        [tempLayouts addObject:layout];
    }
    _commentTextLayouts = tempLayouts.copy;
}

#pragma mark - Getter & Setter
- (void)setShowDateView:(BOOL)showDateView {
    _showDateView = showDateView;
}

@end


