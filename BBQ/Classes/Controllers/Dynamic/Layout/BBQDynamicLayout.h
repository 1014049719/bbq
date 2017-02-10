//
//  BBQDynamicLayout.h
//  BBQ
//
//  Created by 朱琨 on 15/11/17.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dynamic.h"
#import "BBQDynamicConst.h"

extern NSArray * reportTagType;

@class BBQDynamicCell;

typedef NS_ENUM(NSUInteger, BBQDynamicTagType) {
    BBQDynamicTagTypeNone,
    BBQDynamicTagTypeFirst,
    BBQDynamicTagTypeReport,
};

typedef NS_ENUM(NSUInteger, BBQDynamicLayoutStyle) {
    BBQDynamicLayoutStyleTimeline,
    BBQDynamicLayoutStyleDetail,
    BBQDynamicLayoutStyleWelcome,
    BBQDynamicLayoutStyleSquareTimeline,
    BBQDynamicLayoutStyleSquareDetail,
};

@interface BBQDynamicLayout : NSObject

@property (strong, nonatomic) Dynamic *dynamic;
@property (assign, nonatomic) CGFloat topAnchor;
@property (weak, nonatomic) BBQDynamicCell *cell;
@property (assign, nonatomic) BBQDynamicLayoutStyle style;
@property (assign, nonatomic) CGFloat height;   //总高度
@property (assign, nonatomic) CGFloat marginTop;    //顶部留白
@property (assign, nonatomic) BOOL showDateView;    //是否显示左边日期
@property (strong, nonatomic) YYTextLayout *dateLayout;
@property (strong, nonatomic) YYTextLayout *nameTextLayout;
@property (assign, nonatomic) CGSize nameSize;
@property (strong, nonatomic) YYTextLayout *sourceTextLayout;
@property (assign, nonatomic) CGSize sourceSize;
@property (strong, nonatomic) YYTextLayout *postTimeTextLayout;
@property (strong, nonatomic) YYTextLayout *tagTextLayout;
@property (assign, nonatomic) CGFloat tagHeight;    //标签
@property (copy, nonatomic) NSString *tagPicName;   //标签图片
@property (strong, nonatomic) UIColor *tagColor;
@property (assign, nonatomic) BBQDynamicTagType tagType;
@property (assign, nonatomic) CGSize titleSize;
@property (strong, nonatomic) YYTextLayout *titleLayout;
@property (assign, nonatomic) CGSize textSize;   //正文
@property (strong, nonatomic) YYTextLayout *textLayout;
@property (assign, nonatomic) BBQDynamicMediaType mediaType;    //媒体类型
@property (assign, nonatomic) CGFloat mediaHeight;    //媒体高度
@property (assign, nonatomic) CGSize mediaSize;  //媒体尺寸
@property (assign, nonatomic) CGFloat funcHeight;   //中间工具栏
@property (strong, nonatomic) YYTextLayout *giftTextLayout;
@property (assign, nonatomic) CGFloat giftHeight;   //礼物高度
@property (assign, nonatomic) CGFloat commentHeight;    //评论总高度
@property (copy, nonatomic) NSArray *commentTextLayouts;
@property (assign, nonatomic) CGFloat toolbarHeight;    //底部工具栏
@property (assign, nonatomic) CGFloat marginBottom;

- (instancetype)initWithDynamic:(Dynamic *)dynamic style:(BBQDynamicLayoutStyle)style;

- (void)layout;
- (void)layoutDateView;
- (void)layoutProfile;
- (void)layoutName;
- (void)layoutSource;
- (void)layoutPostTime;
- (void)layoutTagWithWidth:(CGFloat)width;
- (void)layoutTitle;
- (void)layoutTextWithWidth:(CGFloat)width;;
- (void)layoutMedia;
- (void)layoutGifts;
- (void)layoutComments;

@end