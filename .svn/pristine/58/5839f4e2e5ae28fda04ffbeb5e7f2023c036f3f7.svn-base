//
//  BBQDynamicView.h
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBQDynamicLayout.h"

@class BBQDynamicCell;

@interface BBQDynamicDateView : UIView

@property (strong, nonatomic) YYLabel *dateLabel;
@property (weak, nonatomic) BBQDynamicLayout *layout;

@end

@interface BBQDynamicProfileView : UIView

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIView *warningView;
@property (strong, nonatomic) YYLabel *nameLabel;
@property (strong, nonatomic) YYLabel *sourceLabel;
@property (strong, nonatomic) YYLabel *postTimeLabel;
@property (strong, nonatomic) UIView *themeBar;
@property (weak, nonatomic) BBQDynamicCell *cell;
@property (weak, nonatomic) BBQDynamicLayout *layout;

@end

@interface BBQDynamicTagView : UIView

@property (strong, nonatomic) UIView *topBarView;
@property (strong, nonatomic) UIView *tagImageView;
@property (strong, nonatomic) YYLabel *tagLabel;
@property (weak, nonatomic) BBQDynamicLayout *layout;

@end

@interface BBQDynamicGiftView : UIView

@property (strong, nonatomic) YYLabel *totalCountLabel;
@property (strong, nonatomic) UIImageView *bgView;
@property (copy, nonatomic) NSArray *giftViews;
@property (copy, nonatomic) NSArray *countLabels;
@property (copy, nonatomic) NSArray *avatarViews;
@property (weak, nonatomic) BBQDynamicCell *cell;
@property (weak, nonatomic) BBQDynamicLayout *layout;

@end

@interface BBQDynamicToolbarView : UIView

@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *visitsButton;
@property (strong, nonatomic) CALayer *topLine;
@property (weak, nonatomic) BBQDynamicCell *cell;
@property (weak, nonatomic) BBQDynamicLayout *layout;

- (instancetype)initWithFrame:(CGRect)frame needLikeButton:(BOOL)needLike;

@end

@interface BBQDynamicView : UIView 

@property (strong, nonatomic) CALayer *bgLayer, *verticalLine;
@property (strong, nonatomic) BBQDynamicDateView *dateView;
@property (strong, nonatomic) BBQDynamicProfileView *profileView;
@property (strong, nonatomic) BBQDynamicTagView *tagView;
@property (strong, nonatomic) YYLabel *titleLabel;
@property (strong, nonatomic) YYLabel *textLabel;
@property (copy, nonatomic) NSArray *mediaViews;
@property (strong, nonatomic) UIButton *giftButton;
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UIButton *editButton;         // 编辑按钮
@property (strong, nonatomic) UIButton *deleteButton;         // 删除按钮
@property (strong, nonatomic) BBQDynamicGiftView *giftView;
@property (strong, nonatomic) BBQDynamicToolbarView *toolbarView;
@property (strong, nonatomic) BBQDynamicLayout *layout;
@property (weak, nonatomic) BBQDynamicCell *cell;

- (void)setupUI;
- (void)setupBgLayer;
- (void)setupProfileView;
- (void)setupTagView;
- (void)setupTitle;
- (void)setupContent;
- (void)setupMedia;
- (void)setupFuncView;
- (void)setupGiftView;
- (void)setupCommentView;
- (void)setupToolbar;

- (void)showDateView:(BOOL)show;
- (void)setImageViewWithTop:(CGFloat)imageTop;
- (void)hideImageViews;

@end
