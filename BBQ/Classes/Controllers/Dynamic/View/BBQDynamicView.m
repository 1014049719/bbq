//
//  BBQDynamicView.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicView.h"
#import "BBQDynamicCell.h"
#import "BBQDynamicCommentCell.h"
#import "POP.h"
#import "UIButton+Extension.h"

@implementation BBQDynamicDateView

- (instancetype)initWithFrame:(CGRect)frame {
    frame = CGRectMake(5, kDynamicCellTopMargin, 45, 47);
    self = [super initWithFrame:frame];
    self.layer.contents =
    (__bridge id)[UIImage imageNamed:@"dynamic_date_bg"].CGImage;
    
    _dateLabel = [YYLabel new];
    _dateLabel.size = CGSizeMake(self.width, 35);
    _dateLabel.top = 8;
    _dateLabel.displaysAsynchronously = YES;
    _dateLabel.ignoreCommonProperties = YES;
    _dateLabel.fadeOnHighlight = NO;
    _dateLabel.fadeOnAsynchronouslyDisplay = NO;
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_dateLabel];
    return self;
}

- (void)setLayout:(BBQDynamicLayout *)layout {
    _layout = layout;
    self.dateLabel.textLayout = layout.dateLayout;
}

@end

@implementation BBQDynamicProfileView {
    BOOL _trackingTouch;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.exclusiveTouch = YES;
        _avatarView = [UIImageView new];
        _avatarView.size = CGSizeMake(40, 40);
        //        _avatarView.origin = CGPointMake(0, 0);
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_avatarView];
        
        _nameLabel = [YYLabel new];
        _nameLabel.displaysAsynchronously = YES;
        _nameLabel.ignoreCommonProperties = YES;
        _nameLabel.fadeOnAsynchronouslyDisplay = NO;
        _nameLabel.fadeOnHighlight = NO;
        _nameLabel.lineBreakMode = NSLineBreakByClipping;
        _nameLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        [self addSubview:_nameLabel];
        
        _sourceLabel = [YYLabel new];
        _sourceLabel.displaysAsynchronously = YES;
        _sourceLabel.ignoreCommonProperties = YES;
        _sourceLabel.fadeOnAsynchronouslyDisplay = NO;
        _sourceLabel.fadeOnHighlight = NO;
        _sourceLabel.textVerticalAlignment = YYTextVerticalAlignmentBottom;
        [self addSubview:_sourceLabel];
        
        _postTimeLabel = [YYLabel new];
        _postTimeLabel.size = CGSizeMake(150, 15);
        _postTimeLabel.right = self.width;
        _postTimeLabel.centerY = self.height / 2.0;
        _postTimeLabel.displaysAsynchronously = YES;
        _postTimeLabel.ignoreCommonProperties = YES;
        _postTimeLabel.fadeOnAsynchronouslyDisplay = NO;
        _postTimeLabel.fadeOnHighlight = NO;
        [self addSubview:_postTimeLabel];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.centerY = _avatarView.centerY;
        _indicator.right = kDynamicCellProfileWidth;
        _indicator.hidden = YES;
        [self addSubview:_indicator];
        
        _warningView = [UIView new];
        _warningView.size = CGSizeMake(20, 20);
        _warningView.centerY = _avatarView.centerY;
        _warningView.right = kDynamicCellProfileWidth;
        _warningView.layer.contents = (__bridge id)[UIImage imageNamed:@"tips_failed"].CGImage;
        _warningView.hidden = YES;
        [self addSubview:_warningView];
    }
    return self;
}

-(void)setLayout:(BBQDynamicLayout *)layout {
    _layout = layout;
    if (layout.dynamic.ispajs.integerValue == BBQDynamicContentTypePickUp) {
        UIImage *image = [UIImage imageNamed:@"panda_head"];
        UIImage *newImage = [BBQDynamicHelper avatarImageManager].sharedTransformBlock(image, nil);
        self.avatarView.image = newImage;
    } else {
        [self.avatarView setImageWithURL:[NSURL URLWithString:layout.dynamic.fbztx] placeholder:Placeholder_avatar
                                 options:YYWebImageOptionSetImageWithFadeAnimation
                                 manager:[BBQDynamicHelper avatarImageManager]
                                progress:nil
                               transform:nil
                              completion:nil];
    }
    
    self.nameLabel.textLayout = layout.nameTextLayout;
    self.nameLabel.size = layout.nameSize;
    self.sourceLabel.textLayout = layout.sourceTextLayout;
    self.sourceLabel.size = layout.sourceSize;
    self.cell = layout.cell;
    
    switch (layout.dynamic.uploadState) {
        case BBQDynamicUploadStateSuccess: {
            self.postTimeLabel.hidden = NO;
            self.postTimeLabel.textLayout = layout.postTimeTextLayout;
            self.warningView.hidden = YES;
            [self.indicator stopAnimating];
            break;
        }
        case BBQDynamicUploadStateWaiting:
        case BBQDynamicUploadStateUploading: {
            self.postTimeLabel.hidden = YES;
            self.warningView.hidden = YES;
            self.indicator.hidden = NO;
            [self.indicator startAnimating];
            break;
        }
        case BBQDynamicUploadStateFail: {
            self.postTimeLabel.hidden = YES;
            self.warningView.hidden = NO;
            [self.indicator stopAnimating];
            break;
        }
    }
    layout.topAnchor += self.height;
}

#pragma mark - Touche Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _trackingTouch = NO;
    UITouch *t = touches.anyObject;
    CGPoint p = [t locationInView:_avatarView];
    if (CGRectContainsPoint(_avatarView.bounds, p)) {
        _trackingTouch = YES;
    }
    p = [t locationInView:_nameLabel];
    if (CGRectContainsPoint(_nameLabel.bounds, p) &&
        _nameLabel.textLayout.textBoundingRect.size.width > p.x) {
        _trackingTouch = YES;
    }
    if (!_trackingTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch) {
        [super touchesEnded:touches withEvent:event];
    } else {
        if ([self.cell.delegate
             respondsToSelector:@selector(didClickUserWithID:)] && self.cell.layout.style != BBQDynamicLayoutStyleWelcome) {
            [self.cell.delegate didClickUserWithID:self.cell.dynamic.creuid];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch) {
        [super touchesCancelled:touches withEvent:event];
    }
}

@end

@implementation BBQDynamicTagView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tagImageView = [UIView new];
        _tagImageView.layer.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_tagImageView];
        _tagLabel = [YYLabel new];
        _tagLabel.displaysAsynchronously = YES;
        _tagLabel.ignoreCommonProperties = YES;
        _tagLabel.fadeOnAsynchronouslyDisplay = NO;
        _tagLabel.fadeOnHighlight = NO;
        [self addSubview:_tagLabel];
    }
    return self;
}

- (void)setLayout:(BBQDynamicLayout *)layout {
    _layout = layout;
    self.height = layout.tagHeight;
    if (layout.tagHeight) {
        self.hidden = NO;
        self.tagLabel.textLayout = layout.tagTextLayout;
        _tagImageView.layer.contents =
        (__bridge id)[UIImage imageNamed:layout.tagPicName].CGImage;
        self.top = layout.topAnchor;
        layout.topAnchor += layout.tagHeight;
    } else {
        self.hidden = YES;
    }
}

@end

@implementation BBQDynamicGiftView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _bgView = [UIImageView new];
        _bgView.size = self.size;
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _bgView.image = [[UIImage imageNamed:@"gift_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 50, 30, 40)];
        [self addSubview:_bgView];
        @weakify(self)
        UITapGestureRecognizer *singleTap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            @strongify(self)
            if ([self.cell.delegate
                 respondsToSelector:
                 @selector(didClickGiftViewWithCell:)]) {
                [self.cell.delegate didClickGiftViewWithCell:self.cell];
            }
        }];
        [self addGestureRecognizer:singleTap];
        
        self.exclusiveTouch = YES;
        _totalCountLabel = [YYLabel new];
        _totalCountLabel.size = CGSizeMake(CGRectGetWidth(frame) - 35, 12);
        _totalCountLabel.top = 17;
        _totalCountLabel.left = 12.5;
        _totalCountLabel.displaysAsynchronously = YES;
        _totalCountLabel.ignoreCommonProperties = YES;
        _totalCountLabel.fadeOnAsynchronouslyDisplay = NO;
        _totalCountLabel.fadeOnHighlight = NO;
        [self addSubview:_totalCountLabel];
        
        UIView *arrow = [UIView new];
        arrow.size = CGSizeMake(10, 10);
        arrow.centerY = _totalCountLabel.centerY;
        arrow.right = CGRectGetWidth(frame) - 12.5;
        arrow.layer.contentMode = UIViewContentModeScaleAspectFit;
        arrow.layer.contents =
        (__bridge id)[UIImage imageNamed:@"gift_check"].CGImage;
        [self addSubview:arrow];
        
        UIView *line = [UIView new];
        line.backgroundColor = UIColorHex(f0e7c5);
        line.size = CGSizeMake(CGRectGetWidth(frame), 1);
        line.top = _totalCountLabel.bottom + 10;
        [self addSubview:line];
        
        CGFloat giftWidth = kScaleFrom_iPhone6_Desgin(50);
        CGFloat padding = (CGRectGetWidth(frame) - 5 - giftWidth * 4) / 5.0;
        NSMutableArray *tempGifts = [NSMutableArray array];
        NSMutableArray *tempLabels = [NSMutableArray array];
        NSMutableArray *tempAvatars = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i++) {
            UIView *gift = [UIView new];
            gift.contentMode = UIViewContentModeScaleAspectFit;
            gift.frame = CGRectMake(2.5 + padding * (i + 1) + giftWidth * i,
                                    line.bottom + 10, giftWidth, giftWidth);
            [tempGifts addObject:gift];
            [self addSubview:gift];
            
            YYLabel *label = [YYLabel new];
            label.backgroundColor = UIColorHex(ffc000);
            label.size = CGSizeMake(giftWidth * 0.8, 14);
            label.fadeOnHighlight = NO;
            label.displaysAsynchronously = YES;
            label.fadeOnAsynchronouslyDisplay = NO;
            label.layer.cornerRadius = label.height / 2.0;
            label.centerX = gift.centerX;
            label.centerY = gift.bottom;
            label.textAlignment = NSTextAlignmentCenter;
            [tempLabels addObject:label];
            [self addSubview:label];
            
            CGFloat avatarWidth = kScaleFrom_iPhone6_Desgin(29);
            UIView *avatar = [UIView new];
            avatar.layer.contentMode = UIViewContentModeScaleAspectFit;
            avatar.size = CGSizeMake(avatarWidth, avatarWidth);
            avatar.top = label.bottom + 5;
            avatar.centerX = label.centerX;
            [tempAvatars addObject:avatar];
            [self addSubview:avatar];
        }
        _giftViews = tempGifts;
        _countLabels = tempLabels;
        _avatarViews = tempAvatars;
    }
    
    return self;
}

- (void)setLayout:(BBQDynamicLayout *)layout {
    _layout = layout;
    self.height = layout.giftHeight;
    if (layout.giftHeight) {
        self.hidden = NO;
        self.top = layout.topAnchor;
        self.height = layout.giftHeight;
        self.totalCountLabel.textLayout = layout.giftTextLayout;
        for (NSInteger i = 0; i < 4; i++) {
            if (i < layout.dynamic.giftdata.count) {
                [self hideGiftViewAtIndex:i hide:NO];
                Gift *giftModel = layout.dynamic.giftdata[i];
                UIView *gift = _giftViews[i];
                @weakify(gift)
                [gift.layer setImageWithURL:[NSURL URLWithString:giftModel.imgurl] placeholder:[UIImage imageNamed:@"placeholder_gift"] options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                    @strongify(gift)
                    if (error) {
                        gift.layer.contents = (__bridge id)[UIImage imageNamed:@"placeholder_gift"].CGImage;
                    }
                }];
                
                UIView *avatar = _avatarViews[i];
                [avatar.layer setImageWithURL:[NSURL URLWithString:giftModel.fbztx] placeholder:Placeholder_avatar options:YYWebImageOptionSetImageWithFadeAnimation manager:[BBQDynamicHelper avatarImageManager] progress:nil transform:nil completion:nil];
                
                NSString *countStr =
                [NSString stringWithFormat:@"+%@", giftModel.giftcount];
                NSMutableAttributedString *text =
                [[NSMutableAttributedString alloc] initWithString:countStr];
                text.font = [UIFont systemFontOfSize:10];
                text.color = [UIColor whiteColor];
                text.alignment = NSTextAlignmentCenter;
                [(YYLabel *)_countLabels[i] setAttributedText:text];
            } else {
                [self hideGiftViewAtIndex:i hide:YES];
            }
        }
        [self hideAvatar:layout.dynamic.dtype.integerValue != BBQDynamicGroupTypeBaby];
        layout.topAnchor += self.height;
    } else {
        self.hidden = YES;
    }
}

- (void)hideAvatar:(BOOL)hide {
    for (UIView *avatar in _avatarViews) {
        avatar.hidden = hide;
    }
}

- (void)hideGiftViewAtIndex:(NSInteger)index hide:(BOOL)hide {
    [(UIView *)_giftViews[index] setHidden:hide];
    [(YYLabel *)_countLabels[index] setHidden:hide];
    [(UIView *)_avatarViews[index] setHidden:hide];
}

@end

@implementation BBQDynamicToolbarView

- (instancetype)initWithFrame:(CGRect)frame needLikeButton:(BOOL)needLike {
    if (self = [super initWithFrame:frame]) {
        self.exclusiveTouch = YES;
        CGSize buttonSize;
        CGFloat top = 0;
        
        _topLine = [CALayer layer];
        _topLine.size = CGSizeMake(self.width, 1);
        _topLine.top = needLike ?: 5;
        _topLine.backgroundColor = UIColorHex(f5f5f5).CGColor;
        [self.layer addSublayer:_topLine];
        buttonSize = CGSizeMake(79, self.height - _topLine.bottom);
        top = _topLine.bottom;
        
        if (needLike) {
            _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _likeButton.exclusiveTouch = YES;
            [_likeButton setTitle:@"赞" forState:UIControlStateNormal];
            _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
            [_likeButton setTitleColor:kDynamicCellTextSubTitleColor
                              forState:UIControlStateNormal];
            _likeButton.titleLabel.font =
            [UIFont systemFontOfSize:kDynamicCellTextSubTitleFontSize];
            [_likeButton setImage:[UIImage imageNamed:@"dynamic_like"]
                         forState:UIControlStateNormal];
            _likeButton.size = buttonSize;
            _likeButton.centerX = self.width / 2.0;
            [_likeButton addTarget:self action:@selector(didClickLikeButton) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_likeButton];
        }
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.exclusiveTouch = YES;
        [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [_shareButton setTitleColor:kDynamicCellTextSubTitleColor
                           forState:UIControlStateNormal];
        _shareButton.titleLabel.font =
        [UIFont systemFontOfSize:kDynamicCellTextSubTitleFontSize];
        [_shareButton setImage:[UIImage imageNamed:@"share"]
                      forState:UIControlStateNormal];
        _shareButton.size = CGSizeMake(79, self.height - _topLine.bottom);
        _shareButton.top = top;
        [_shareButton addTarget:self action:@selector(didClickShareButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
        
        
        _visitsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _visitsButton.exclusiveTouch = YES;
        [_visitsButton setTitleColor:kDynamicCellTextSubTitleColor
                             forState:UIControlStateNormal];
        _visitsButton.titleLabel.font =
        [UIFont systemFontOfSize:kDynamicCellTextSubTitleFontSize];
        [_visitsButton setImage:[UIImage imageNamed:@"dynamic_visits"]
                        forState:UIControlStateNormal];
        _visitsButton.size = CGSizeMake(79, _shareButton.height);
        _visitsButton.top = _shareButton.top;
        _visitsButton.right = self.width;
        [_visitsButton addTarget:self action:@selector(didClickVisitsButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_visitsButton];
    }
    return self;
}

- (void)didClickShareButton {
    if (self.cell.delegate && [self.cell.delegate respondsToSelector:@selector(didClickShareButtonWithCell:)]) {
        [self.cell.delegate didClickShareButtonWithCell:self.cell];
    }
}

- (void)didClickLikeButton {
    CheckNetwork
    BOOL preLiked = _layout.dynamic.islike;
    NSInteger preLikes = _layout.dynamic.likecount.integerValue;
    
    if (preLiked) {
        [self.likeButton setImage:[UIImage imageNamed:@"dynamic_like"] forState:UIControlStateNormal];
        preLikes--;
    }else{
        [self.likeButton animateToImage:@"dynamic_liked"];
        preLikes++;
    }

    NSString *str;
    if (preLikes) {
        str = [NSString stringWithFormat:@"赞(%@)", @(preLikes)];
    } else {
        str = @"赞";
    }
    
    [self.likeButton setTitle:str forState:UIControlStateNormal];
    
    if ([self.cell.delegate respondsToSelector:@selector(didClickLikeButtonWithCell:)]) {
        [self.cell.delegate didClickLikeButtonWithCell:self.cell];
    }
}

- (void)didClickVisitsButton {
    if ([self.cell.delegate respondsToSelector:@selector(didClickVisitsButtonWithCell:)]) {
        [self.cell.delegate didClickVisitsButtonWithCell:self.cell];
    }
}

- (void)setLayout:(BBQDynamicLayout *)layout {
    _layout = layout;
    NSInteger visitsCount = _layout.dynamic.browsecount.integerValue;
    NSString *visitsButtonTitle = @"浏览";
    if (visitsCount) {
        visitsButtonTitle = [NSString stringWithFormat:@"浏览(%@)", @(visitsCount)];
    }
    [self.visitsButton setTitle:visitsButtonTitle forState:UIControlStateNormal];
    
    if (layout.style == BBQDynamicLayoutStyleSquareTimeline) {
        if (layout.dynamic.islike) {
            [self.likeButton setImage:[UIImage imageNamed:@"dynamic_liked"] forState:UIControlStateNormal];
        } else {
            [self.likeButton setImage:[UIImage imageNamed:@"dynamic_like"] forState:UIControlStateNormal];
        }
        NSString *str;
        if (layout.dynamic.likecount.integerValue) {
            str = [NSString stringWithFormat:@"赞(%@)",layout.dynamic.likecount];
        } else {
            str = @"赞";
        }
        [self.likeButton setTitle:str forState:UIControlStateNormal];
    }
    
    self.top = layout.topAnchor;
    layout.topAnchor += layout.toolbarHeight;
}

@end

@implementation BBQDynamicView {
    BOOL _trackingTouch;
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame = CGRectMake(0, 0, kScreenWidth, 1);
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorHex(f5f5f5);
        self.exclusiveTouch = YES;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [NSException raise:NSInternalInconsistencyException format:@"You must override%@in subclass", NSStringFromSelector(_cmd)];
}


- (void)setupBgLayer {
    _bgLayer = [CALayer new];
    _bgLayer.shouldRasterize = YES;
    _bgLayer.rasterizationScale = [UIScreen screenScale];
    _bgLayer.cornerRadius = 5;
    _bgLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_bgLayer];
}

- (void)showDateView:(BOOL)show {
    
}

- (void)setupProfileView {
    
}

- (void)setupTagView {
    
}

- (void)setupTitle {
    
}

- (void)setupContent {
    self.textLabel = [YYLabel new];
    self.textLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    self.textLabel.displaysAsynchronously = YES;
    self.textLabel.ignoreCommonProperties = YES;
    self.textLabel.fadeOnAsynchronouslyDisplay = NO;
    self.textLabel.fadeOnHighlight = NO;
    [self addSubview:self.textLabel];
}

- (void)setupMedia {
    
}

- (void)setImageViewWithTop:(CGFloat)imageTop {
    
}

- (void)hideImageViews {
    for (UIView *view in _mediaViews) {
        view.hidden = YES;
    }
}

- (void)setupFuncView {
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.size =
    CGSizeMake(kDynamicCellFuncHeight, kDynamicCellFuncHeight);
    _commentButton.right = kDynamicCellProfileWidth - kDynamicCellPadding;
    [_commentButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(didClickCommentButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_commentButton];
    
    _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _giftButton.size =
    CGSizeMake(kDynamicCellFuncHeight, kDynamicCellFuncHeight);
    [_giftButton addTarget:self action:@selector(didClickGiftButton) forControlEvents:UIControlEventTouchUpInside];
    _giftButton.right = _commentButton.left - 15;
    [_giftButton setImage:[UIImage imageNamed:@"gift_button"] forState:UIControlStateNormal];
    [self addSubview:_giftButton];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editButton.size = CGSizeMake(kDynamicCellFuncHeight, kDynamicCellFuncHeight);
    [_editButton addTarget:self action:@selector(didClickEditButton) forControlEvents:UIControlEventTouchUpInside];
    _editButton.right = _giftButton.left - 15;
    [_editButton setImage:[UIImage imageNamed:@"dynamic_edit"] forState:UIControlStateNormal];
    [self addSubview:_editButton];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton addTarget:self action:@selector(didClickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.size = CGSizeMake(kDynamicCellFuncHeight, kDynamicCellFuncHeight);
    _deleteButton.right = _editButton.left - 15;
    [_deleteButton setImage:[UIImage imageNamed:@"detail_menu_delete"] forState:UIControlStateNormal];
    [self addSubview:_deleteButton];
}

- (void)setupGiftView {
    
}

- (void)setupCommentView {
    
}

- (void)setupToolbar {
    
}

#pragma mark - Action
- (void)didClickGiftButton {
    if ([self.cell.delegate respondsToSelector:@selector(didClickGiftButtonWithCell:)]) {
        [self.cell.delegate didClickGiftButtonWithCell:self.cell];
    }
}

- (void)didClickEditButton {
    if ([self.cell.delegate respondsToSelector:@selector(didClickEditButtonWithCell:)]) {
        [self.cell.delegate didClickEditButtonWithCell:self.cell];
    }
}

- (void)didClickDeleteButton {
    if ([self.cell.delegate respondsToSelector:@selector(didClickDeleteButtonWithCell:)]) {
        [self.cell.delegate didClickDeleteButtonWithCell:self.cell];
    }
}

- (void)didClickCommentButton {
    if ([self.cell.delegate respondsToSelector:@selector(didClickCommentButtonWithCell:)]) {
        [self.cell.delegate didClickCommentButtonWithCell:self.cell];
    }
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _trackingTouch = NO;
    UITouch *t = touches.anyObject;
    CGPoint p = [t locationInView:self];
    CALayer *layer = [_bgLayer hitTest:p];
    if (layer == _bgLayer) {
        _trackingTouch = YES;
    }
    if (!_trackingTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch) {
        [super touchesEnded:touches withEvent:event];
    } else {
        if ([self.cell.delegate respondsToSelector:@selector(didClickWhiteSpaceWithCell:)] && self.cell.layout.style != BBQDynamicLayoutStyleWelcome) {
            [self.cell.delegate didClickWhiteSpaceWithCell:self.cell];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch) {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - Getter & Setter
- (void)setLayout:(BBQDynamicLayout *)layout {
    _layout = layout;
    BOOL hidden = layout.style == BBQDynamicLayoutStyleWelcome;
    self.deleteButton.hidden = hidden;
    self.editButton.hidden = hidden;
    self.giftButton.hidden = hidden;
    self.commentButton.hidden = hidden;
    self.toolbarView.hidden = hidden;
    self.height = layout.height;
}

- (void)setCell:(BBQDynamicCell *)cell {
    _cell = cell;
    _profileView.cell = cell;
    _giftView.cell = cell;
    _toolbarView.cell = cell;
}

@end
