//
//  BBQDynamicViewTimeline.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicViewTimeline.h"
#import "BBQDynamicCommentCell.h"
#import "BBQDynamicCell.h"

static CGFloat const kDynamicViewTimelineLeftOffset = 65.0;

@implementation BBQDynamicViewTimeline

- (void)setupUI {
    [self setupBgLayer];
    [self setupDateView];
    [self setupProfileView];
    [self setupTagView];
    [self setupContent];
    [self setupMedia];
    [self setupFuncView];
    [self setupGiftView];
    [self setupCommentView];
    [self setupToolbar];
}

- (void)setupBgLayer {
    [super setupBgLayer];
    self.bgLayer.width = kDynamicCellProfileWidth;
    self.bgLayer.top = kDynamicCellTopMargin + kDynamicCellProfileHeight;
    self.bgLayer.left = kDynamicViewTimelineLeftOffset;
}

- (void)setupDateView {
    self.dateView = [BBQDynamicDateView new];
    self.verticalLine = [CALayer new];
    self.verticalLine.backgroundColor = UIColorHex(eeeeee).CGColor;
    self.verticalLine.width = 2;
    self.verticalLine.centerX = self.dateView.centerX;
    [self.layer addSublayer:self.verticalLine];
    [self addSubview:self.dateView];
    
    UIView *dotView = [UIView new];
    dotView.size = CGSizeMake(31, 31);
    dotView.top = self.dateView.bottom + 5;
    dotView.centerX = self.dateView.centerX;
    dotView.layer.contents = (__bridge id)[UIImage imageNamed:@"dynamic_date_button"].CGImage;
    dotView.layer.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:dotView];
    
    @weakify(self)
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) {
            @strongify(self)
            if ([self.cell.delegate respondsToSelector:@selector(didClickDateView)]) {
                [self.cell.delegate didClickDateView];
            }
        }
    }];
    
    [dotView addGestureRecognizer:tap];
    
    [self.dateView bk_addObserverForKeyPath:@"hidden" task:^(id target) {
        @strongify(self)
        dotView.hidden = self.dateView.hidden;
    }];
}

- (void)showDateView:(BOOL)show {
    dispatch_async_on_main_queue(^{
        self.dateView.hidden = !show;
    });
}

- (void)setupProfileView {
    self.profileView = [[BBQDynamicProfileView alloc] initWithFrame:CGRectMake(kDynamicViewTimelineLeftOffset, kDynamicCellTopMargin, kDynamicCellProfileWidth, kDynamicCellProfileHeight)];
    self.profileView.avatarView.frame = CGRectMake(0, 0, 40, 40);
    self.profileView.nameLabel.left = self.profileView.avatarView.right + 7.5;
    self.profileView.nameLabel.top = self.profileView.avatarView.top + 5;
    self.profileView.sourceLabel.left = self.profileView.nameLabel.left;
    [self addSubview:self.profileView];
    [self addToThemeChangeObserver];
}

- (void)imy_themeChanged {
    if (TheCurUser.themeType == BBQThemeTypeDefault || TheCurUser.themeType == BBQThemeTypeXiaoP) {
        [self.profileView.themeBar removeFromSuperview];
    } else {
        self.profileView.themeBar = [UIView new];
        self.profileView.themeBar.layer.contentMode = UIViewContentModeScaleAspectFill;
        self.profileView.themeBar.layer.contents = (__bridge id)[UIImage imy_imageForKey:@"theme_dynamic_bar"].CGImage;
        self.profileView.themeBar.width = kScaleFrom_iPhone6_Desgin(380 / 3.0);
        self.profileView.themeBar.height = kScaleFrom_iPhone6_Desgin(50 / 3.0);
        self.profileView.themeBar.bottom = self.profileView.height;
        self.profileView.themeBar.right = self.profileView.width - 15;
        [self.profileView addSubview:self.profileView.themeBar];
    }
}

- (void)setupTagView {
    self.tagView = [[BBQDynamicTagView alloc] initWithFrame:CGRectMake(kDynamicViewTimelineLeftOffset, 0, kDynamicCellProfileWidth, 0)];
    self.tagView.topBarView =
    [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tagView.width, 5)];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.tagView.topBarView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.tagView.topBarView.bounds;
    maskLayer.path = path.CGPath;
    maskLayer.shouldRasterize = YES;
    maskLayer.rasterizationScale = [UIScreen mainScreen].scale;
    self.tagView.topBarView.layer.mask = maskLayer;
    [self.tagView addSubview:self.tagView.topBarView];
    [self addSubview:self.tagView];
}

- (void)setupContent {
    [super setupContent];
    self.textLabel.left = kDynamicCellPadding + 65;
    self.textLabel.width = kDynamicCellContentWidth;
}

- (void)setupMedia {
    NSMutableArray *picViews = [NSMutableArray new];
    for (NSInteger i = 0; i < 9; i++) {
        UIView *imageView = [UIView new];
        if (i == 0) {
            UIImageView *videoImage = [UIImageView new];
            videoImage.image = [UIImage imageNamed:@"video_play"];
            videoImage.contentMode = UIViewContentModeCenter;
            [imageView addSubview:videoImage];
            videoImage.hidden = YES;
        }
        imageView.layer.contentMode = UIViewContentModeScaleAspectFill;
        imageView.size = CGSizeMake(5, 5);
        imageView.hidden = YES;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = UIColorHex(f5f5f5);
        imageView.exclusiveTouch = YES;
        @weakify(self)
        UITapGestureRecognizer *singleTap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            @strongify(self)
            if ([self.cell.delegate
                 respondsToSelector:
                 @selector(cell:didClickMediaAtIndex:)]) {
                [self.cell.delegate cell:self.cell didClickMediaAtIndex:i];
            }
        }];
        [imageView addGestureRecognizer:singleTap];
        [picViews addObject:imageView];
        [self addSubview:imageView];
    }
    self.mediaViews = picViews;
}

- (void)setupFuncView {
    [super setupFuncView];
    self.commentButton.right = kScreenWidth - 15 * 2;
    self.giftButton.right = self.commentButton.left - 15;
}

- (void)setupGiftView {
    self.giftView = [[BBQDynamicGiftView alloc] initWithFrame:CGRectMake(65 + 7.5, 0, kDynamicCellContentWidth, 0)];
    [self addSubview:self.giftView];
}

- (void)setupCommentView {
    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(65 + kDynamicCellPadding, 0, kDynamicCellContentWidth, 0) style:UITableViewStylePlain];
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTableView.scrollEnabled = NO;
    [self.commentTableView setBackgroundView:nil];
    [self.commentTableView setBackgroundColor:[UIColor whiteColor]];
    [self.commentTableView registerClass:[BBQDynamicCommentCell class] forCellReuseIdentifier:kDynamicCommentCellIdentifier];
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    [self addSubview:self.commentTableView];
}

- (void)setupToolbar {
    self.toolbarView = [[BBQDynamicToolbarView alloc] initWithFrame:CGRectMake(65, 0, kDynamicCellProfileWidth, 45) needLikeButton:NO];
    [self addSubview:self.toolbarView];
}

#pragma mark - Comment Table View DataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.layout.commentTextLayouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBQDynamicCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kDynamicCommentCellIdentifier forIndexPath:indexPath];
    cell.delegate = self.cell.delegate;
    cell.layout = self.layout.commentTextLayouts[indexPath.row];
    @weakify(self)
    UILongPressGestureRecognizer *longPress = [UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if (state == UIGestureRecognizerStateBegan) {
            if ([cell.delegate respondsToSelector:@selector(cell:didLongPressCommentCell:)]) {
                [cell.delegate cell:self.cell didLongPressCommentCell:cell];
            }
        }
    }];
    [cell.contentView addGestureRecognizer:longPress];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((BBQDynamicCommentLayout *)self.layout.commentTextLayouts[indexPath.row]).height;
}

#pragma mark - Comment Table View DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BBQDynamicCommentCell *commentCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self.cell.delegate respondsToSelector:@selector(cell:didClickCommentCell:)]) {
        [self.cell.delegate cell:self.cell didClickCommentCell:commentCell];
    }
}

- (void)setImageViewWithTop:(CGFloat)imageTop {
    CGSize mediaSize = self.layout.mediaSize;
    NSArray *media = self.layout.dynamic.attachinfo;
    NSInteger mediaCount = media.count;
    
    for (NSInteger i = 0; i < 9; i++) {
        UIView *imageView = self.mediaViews[i];
        if (i >= mediaCount) {
            [imageView.layer cancelCurrentImageRequest];
            imageView.size = CGSizeZero;
            imageView.hidden = YES;
        } else {
            CGPoint origin = {0};
            switch (mediaCount) {
                case 1: {
                    origin.x = kDynamicCellPadding + 65;
                    origin.y = imageTop;
                } break;
                case 2: case 3: case 4: {
                    origin.x = kDynamicCellPadding + 65 +
                    (i % 2) * (mediaSize.width + kDynamicCellPaddingPic);
                    origin.y =
                    imageTop + (i / 2) * (mediaSize.height + kDynamicCellPaddingPic);
                } break;
                default: {
                    origin.x = kDynamicCellPadding + 65 +
                    (i % 3) * (mediaSize.width + kDynamicCellPaddingPic);
                    origin.y =
                    imageTop + (i / 3) * (mediaSize.height + kDynamicCellPaddingPic);
                } break;
            }
            imageView.frame = (CGRect){.origin = origin, .size = mediaSize};
            imageView.hidden = NO;
            [imageView.layer removeAnimationForKey:@"contents"];
            
            Attachment *mediaModel = media[i];
            if (![mediaModel.filepath isNotBlank]) {
                continue;
            }
            
            NSString *picURLStr;
            NSURL *picURL;
            CGFloat scale = [UIScreen mainScreen].scale;
            
            if (mediaModel.itype.integerValue == BBQAttachmentTypePhoto) {
                picURLStr = mediaModel.filepath;
            } else {
                picURLStr = mediaModel.thumbpath;
            }
            
            if ([mediaModel.remote isEqualToNumber:@1]) {
                picURL = [NSURL URLWithString:picURLStr];
            } else if ([mediaModel.remote isEqualToNumber:@2]) {
                picURLStr = [picURLStr stringByAppendingFormat:@"?imageView2/1/w/%.0f/h/%.0f", imageView.width * scale,
                             imageView.height * scale];
                picURL = [NSURL URLWithString:picURLStr];
            } else {
                picURL = [[NSURL alloc] initFileURLWithPath:picURLStr];
            }
            
            @weakify(imageView)
            @weakify(mediaModel)
            [imageView.layer
             setImageWithURL:picURL
             placeholder:[UIImage
                          imageNamed:@"placeholder_white_loading"]
             options:YYWebImageOptionAvoidSetImage
             completion:^(UIImage *image, NSURL *url, YYWebImageFromType from,
                          YYWebImageStage stage, NSError *error) {
                 @strongify(imageView)
                 @strongify(mediaModel)
                 if (!imageView)
                     return;
                 if (error) {
                     imageView.layer.contents = (__bridge id)[UIImage imageNamed:@"placeholder_white_error"].CGImage;
                     UIView *videoImage = imageView.subviews.firstObject;
                     videoImage.hidden = YES;
                 } else if (image && stage == YYWebImageStageFinished) {
                     imageView.layer.contents = (__bridge id)image.CGImage;
                     if (i == 0) {
                         UIView *videoImage = imageView.subviews.firstObject;
                         videoImage.size = imageView.size;
                         videoImage.hidden = !mediaModel.itype.boolValue;
                     }
                     if (from != YYWebImageFromMemoryCacheFast) {
                         CATransition *transition = [CATransition animation];
                         transition.duration = 0.15;
                         transition.timingFunction = [CAMediaTimingFunction
                                                      functionWithName:kCAMediaTimingFunctionEaseOut];
                         transition.type = kCATransitionFade;
                         [imageView.layer addAnimation:transition
                                                forKey:@"contents"];
                     }
                 }
             }];
        }
    }
}

#pragma mark - Getter & Setter
- (void)setLayout:(BBQDynamicLayout *)layout {
    [super setLayout:layout];
    layout.topAnchor = kDynamicCellTopMargin;
    
    self.dateView.layout = layout;
    self.verticalLine.height = layout.height;
    
    self.profileView.layout = layout;
    self.profileView.sourceLabel.bottom = self.profileView.avatarView.bottom - 3;
    
    self.tagView.layout = layout;
    if (layout.tagType == BBQDynamicTagTypeReport) {
        self.tagView.tagImageView.frame = CGRectMake(5, 4.5, 22.5, 25);
        self.tagView.tagLabel.left = self.tagView.tagImageView.right + 10;
        self.tagView.tagLabel.top = 10;
        self.tagView.tagLabel.size = CGSizeMake(kDynamicCellProfileWidth - 46, 16);
        self.tagView.topBarView.hidden = NO;
        self.tagView.topBarView.backgroundColor = layout.tagColor;
    } else {
        self.tagView.topBarView.hidden = YES;
        self.tagView.tagLabel.top = 15;
        self.tagView.tagLabel.size = CGSizeMake(kDynamicCellProfileWidth - kDynamicCellPadding * 2 - 24 - 5, layout.tagHeight - 15);
        self.tagView.tagImageView.size = CGSizeMake(24, 24);
        self.tagView.tagImageView.left = kDynamicCellPadding;
        self.tagView.tagImageView.centerY = self.tagView.tagLabel.centerY;
        self.tagView.tagLabel.left = self.tagView.tagImageView.right + 5;
    }
    
    self.textLabel.textLayout = layout.textLayout;
    self.textLabel.top = layout.topAnchor;
    self.textLabel.size = layout.textSize;
    layout.topAnchor += layout.textSize.height;

    if (!layout.textSize.height) {
        layout.topAnchor += 15;
    }
    
    if (layout.mediaType != BBQDynamicMediaTypeNone) {
        [self setImageViewWithTop:layout.topAnchor];
        layout.topAnchor += layout.mediaHeight;
    } else {
        [self hideImageViews];
    }
    
    self.giftButton.top = layout.topAnchor;
    self.commentButton.top = layout.topAnchor;
    self.editButton.top = layout.topAnchor;
    self.deleteButton.top = layout.topAnchor;
    layout.topAnchor += kDynamicCellFuncHeight;
    
    if ([TheCurUser checkAuthorityWithDynamicModel:self.cell.dynamic] && layout.style != BBQDynamicLayoutStyleWelcome) {
        self.deleteButton.hidden = NO;
        if (self.cell.dynamic.ispajs.integerValue != 0) {
            self.editButton.hidden = YES;
            self.deleteButton.right = self.giftButton.left - 15;
        } else {
            self.editButton.hidden = NO;
            self.editButton.right = self.giftButton.left - 15;
            self.deleteButton.right = self.editButton.left - 15;
        }
    } else {
        self.editButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }
    
    self.giftView.layout = layout;
    
    if (layout.commentHeight > 0) {
        self.commentTableView.hidden = NO;
        self.commentTableView.top = layout.topAnchor;
        self.commentTableView.height = layout.commentHeight;
        [self.commentTableView reloadData];
        layout.topAnchor += layout.commentHeight;
    } else {
        self.commentTableView.hidden = YES;
    }
    
    self.toolbarView.layout = layout;
    
    self.bgLayer.height = layout.height - kDynamicCellProfileHeight - kDynamicCellTopMargin - kDynamicCellToolbarBottomMargin;
}

@end
