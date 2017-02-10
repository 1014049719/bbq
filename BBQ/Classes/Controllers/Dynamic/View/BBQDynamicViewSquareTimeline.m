//
//  BBQDynamicViewSquareTimeline.m
//  BBQ
//
//  Created by 朱琨 on 16/1/14.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicViewSquareTimeline.h"
#import "BBQDynamicCell.h"

@implementation BBQDynamicViewSquareTimeline

- (void)setupUI {
    [self setupBgLayer];
    [self setupProfileView];
    [self setupContent];
    [self setupMedia];
    [self setupFuncView];
    [self setupToolbar];
}

- (void)setupBgLayer {
    [super setupBgLayer];
    self.bgLayer.width = kScreenWidth - 30;
    self.bgLayer.top = kDynamicCellTopMargin;
    self.bgLayer.left = 15;
}

- (void)setupProfileView {
    self.profileView = [[BBQDynamicProfileView alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth - 30, 61)];
    
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorHex(f5f5f5).CGColor;
    line.frame = CGRectMake(0, 60, self.profileView.width, 1);
    [self.profileView.layer addSublayer:line];
    [self addSubview:self.profileView];
    
    [self.profileView.sourceLabel removeFromSuperview];
    self.profileView.avatarView.frame = CGRectMake(10, 10, 40, 40);
    
    self.profileView.indicator.right = self.profileView.width - 15;
    self.profileView.warningView.right = self.profileView.width - 15;
}
//
//- (void)imy_themeChanged {
//    if (TheCurUser.themeType == BBQThemeTypeDefault || TheCurUser.themeType == BBQThemeTypeXiaoP) {
//        [self.profileView.themeBar removeFromSuperview];
//    } else {
//        self.profileView.themeBar = [UIView new];
//        self.profileView.themeBar.layer.contentMode = UIViewContentModeScaleAspectFill;
//        self.profileView.themeBar.layer.contents = (__bridge id)[UIImage imy_imageForKey:@"theme_dynamic_bar"].CGImage;
//        self.profileView.themeBar.width = kScaleFrom_iPhone6_Desgin(380 / 3.0);
//        self.profileView.themeBar.height = kScaleFrom_iPhone6_Desgin(50 / 3.0);
//        self.profileView.themeBar.bottom = self.profileView.height;
//        self.profileView.themeBar.right = self.profileView.width - 15;
//        [self.profileView addSubview:self.profileView.themeBar];
//    }
//}

- (void)setupContent {
    [super setupContent];
    self.textLabel.left = 25;
    self.textLabel.width = kScreenWidth - 50;
}

- (void)setupMedia {
    UIView *imageView = [UIView new];
    
    UIImageView *videoImage = [UIImageView new];
    videoImage.image = [UIImage imageNamed:@"video_play"];
    videoImage.contentMode = UIViewContentModeCenter;
    [imageView addSubview:videoImage];
    videoImage.hidden = YES;
    
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
            [self.cell.delegate cell:self.cell didClickMediaAtIndex:0];
        }
    }];
    [imageView addGestureRecognizer:singleTap];
    
    [self addSubview:imageView];
    self.mediaViews = @[imageView];
}

- (void)setupFuncView {
    [super setupFuncView];
    self.commentButton.right = kScreenWidth - 15 * 2;
    [self.giftButton removeFromSuperview];
    self.editButton.right = self.commentButton.left - 15;
    self.deleteButton.right = self.editButton.left - 15;
}

- (void)setupToolbar {
    self.toolbarView = [[BBQDynamicToolbarView alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 30, 45) needLikeButton:YES];
    [self addSubview:self.toolbarView];
}

- (void)setImageViewWithTop:(CGFloat)imageTop {
    CGSize mediaSize = self.layout.mediaSize;
    NSArray *media = self.layout.dynamic.attachinfo;
    UIView *imageView = self.mediaViews[0];
    
    CGPoint origin = {0};
    origin.x = 15;
    origin.y = imageTop;
    
    imageView.frame = (CGRect){.origin = origin, .size = mediaSize};
    imageView.hidden = NO;
    [imageView.layer removeAnimationForKey:@"contents"];
    
    Attachment *mediaModel = media[0];
    if (![mediaModel.filepath isNotBlank]) {
        return;
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
             
             UIView *videoImage = imageView.subviews.firstObject;
             videoImage.size = imageView.size;
             videoImage.hidden = !mediaModel.itype.boolValue;
             
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

#pragma mark - Getter & Setter
- (void)setLayout:(BBQDynamicLayout *)layout {
    [super setLayout:layout];
    layout.topAnchor = kDynamicCellTopMargin;
    
    self.profileView.layout = layout;
    self.profileView.nameLabel.left = self.profileView.avatarView.right + 7.5;
    self.profileView.nameLabel.centerY = self.profileView.avatarView.centerY;
    self.profileView.postTimeLabel.centerY = self.profileView.avatarView.centerY;
    self.profileView.indicator.centerY = self.profileView.avatarView.centerY;
    self.profileView.warningView.centerY = self.profileView.avatarView.centerY;
    self.profileView.postTimeLabel.right = self.profileView.width - 15;
    
    self.textLabel.textLayout = layout.textLayout;
    self.textLabel.top = layout.topAnchor;
    self.textLabel.size = CGSizeMake(kScreenWidth - 50, layout.textSize.height);
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
    
    self.commentButton.top = layout.topAnchor;
    self.editButton.top = layout.topAnchor;
    self.deleteButton.top = layout.topAnchor;
    layout.topAnchor += kDynamicCellFuncHeight;

    self.editButton.hidden = self.deleteButton.hidden = !([TheCurUser checkAuthorityWithDynamicModel:self.cell.dynamic] || TheCurUser.member.ismanage);
    
    self.toolbarView.layout = layout;
    
    self.bgLayer.height = layout.height - kDynamicCellTopMargin - kDynamicCellToolbarBottomMargin;
}

@end
