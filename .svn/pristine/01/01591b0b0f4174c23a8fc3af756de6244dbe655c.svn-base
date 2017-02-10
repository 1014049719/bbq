//
//  BBQDynamicViewDetail.m
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicViewSquareDetail.h"
#import "BBQDynamicCell.h"

@interface BBQDynamicViewSquareDetail ()

@property (strong, nonatomic) UIButton *graphtimeButton;
@property (strong, nonatomic) UIButton *visitsButton;

@end

@implementation BBQDynamicViewSquareDetail

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    [self setupProfileView];
    [self setupContent];
    [self setupMedia];
    [self setupToolbar];
}

- (void)setupProfileView {
    self.profileView = [[BBQDynamicProfileView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 61)];
    self.profileView.avatarView.frame = CGRectMake(15, 10, 40, 40);
    self.profileView.nameLabel.left = self.profileView.avatarView.right + 15;
    [self.profileView.sourceLabel removeFromSuperview];
    [self addSubview:self.profileView];
    
    CALayer *line = [CALayer layer];
    line.size = CGSizeMake(self.profileView.width, 1);
    line.top = 60;
    line.backgroundColor = UIColorHex(f5f5f5).CGColor;
    [self.profileView.layer addSublayer:line];
}

- (void)setupContent {
    [super setupContent];
    self.textLabel.left = 15;
    self.textLabel.width = kScreenWidth - 30;
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

- (void)setupToolbar {
    [self addSubview:self.visitsButton];
    [self addSubview:self.graphtimeButton];
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
            CGPoint origin = CGPointMake(15, imageTop + (mediaSize.height + 15) * i);
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
    layout.topAnchor = 0;
    
    self.profileView.layout = layout;
    self.profileView.postTimeLabel.right = kScreenWidth - 15;
    self.profileView.nameLabel.centerY = 30;
    
    self.textLabel.textLayout = layout.textLayout;
    self.textLabel.top = layout.topAnchor;
    self.textLabel.size = layout.textSize;
    
    layout.topAnchor += layout.textSize.height ?: 15;
    
    if (layout.mediaType != BBQDynamicMediaTypeNone) {
        [self setImageViewWithTop:layout.topAnchor];
        layout.topAnchor += layout.mediaHeight;
    } else {
        [self hideImageViews];
        self.graphtimeButton.hidden = YES;
    }
    
    [self.graphtimeButton setTitle:[NSString stringWithFormat:@" 拍摄于 %@", [[NSDate dateWithTimeIntervalSince1970:layout.dynamic.graphtime.integerValue] stringWithFormat:@"yyyy-MM-dd HH:mm"]] forState:UIControlStateNormal];
    if (layout.dynamic.browsecount.integerValue) {
        [self.visitsButton setTitle:[NSString stringWithFormat:@" 浏览(%@)", layout.dynamic.browsecount] forState:UIControlStateNormal];
    } else {
        [self.visitsButton setTitle:@" 浏览" forState:UIControlStateNormal];
    }
    [self.graphtimeButton sizeToFit];
    [self.visitsButton sizeToFit];
    self.graphtimeButton.height = 34;
    self.visitsButton.height = 34;
    
    self.graphtimeButton.top = layout.topAnchor;
    self.visitsButton.top = layout.topAnchor;
    self.graphtimeButton.left = 15;
    self.visitsButton.right = kScreenWidth - 15;
    
    layout.topAnchor += kDynamicCellFuncHeight;
}

- (UIButton *)visitsButton {
    if(!_visitsButton) {
        _visitsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _visitsButton.exclusiveTouch = YES;
        [_visitsButton setTitleColor:kDynamicCellTextSubTitleColor
                            forState:UIControlStateNormal];
        _visitsButton.titleLabel.font =
        [UIFont systemFontOfSize:kDynamicCellTextSubTitleFontSize];
        [_visitsButton setImage:[UIImage imageNamed:@"dynamic_visits"]
                       forState:UIControlStateNormal];
        _visitsButton.size = CGSizeMake(79, 34);
        _visitsButton.right = self.width;
        @weakify(self)
        [_visitsButton bk_addEventHandler:^(id sender) {
            @strongify(self)
            if ([self.cell.delegate respondsToSelector:@selector(didClickVisitsButtonWithCell:)]) {
                [self.cell.delegate didClickVisitsButtonWithCell:self.cell];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _visitsButton;
}

- (UIButton *)graphtimeButton {
    if(!_graphtimeButton) {
        _graphtimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _graphtimeButton.size = CGSizeMake(79, 34);
        [_graphtimeButton setTitleColor:kDynamicCellTextSubTitleColor forState:UIControlStateNormal];
        [_graphtimeButton setImage:[UIImage imageNamed:@"dynamic_create_time"] forState:UIControlStateNormal];
        _graphtimeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _graphtimeButton.userInteractionEnabled = NO;
    }
    return _graphtimeButton;
}

@end
