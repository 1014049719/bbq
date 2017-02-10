//
//  UIButton+Extension.m
//  BBQ
//
//  Created by anymuse on 15/12/15.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "UIButton+Extension.h"
#import "POP.h"

@implementation UIButton (Extension)

- (void)buttonDispNetorLocalImg:(NSString *)avatarUrl {
    if ([avatarUrl hasPrefix:@"http://"] || [avatarUrl isEqualToString:@""])
        [self setBackgroundImageWithURL:[NSURL URLWithString:avatarUrl]
                                  forState:UIControlStateNormal
                               placeholder:[UIImage imageNamed:@"set_head_image_button@2x"]
                                   options:YYWebImageOptionSetImageWithFadeAnimation
                                completion:nil];
    else
        [self setBackgroundImage:[UIImage imageWithContentsOfFile:avatarUrl]
                           forState:UIControlStateNormal];
}

- (void)animateToImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        return;
    }
    [self setImage:image forState:UIControlStateNormal];
    if ([self superview]) {
        UIView *superV = [self superview];
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        CGRect vFrame = [self convertRect:self.imageView.frame toView:superV];
        imageV.frame = vFrame;
        [superV addSubview:imageV];
        
        //animate
        CGAffineTransform fromTransform = imageV.transform;
        CGPoint fromCenter = imageV.center;
        CGFloat dx = CGRectGetWidth(self.frame) /2;
        CGFloat dy = CGRectGetHeight(self.frame) *3;
        CGFloat dScale = 3.0;
        CGFloat dRotation = M_PI_4;
        
        NSTimeInterval moveDurarion = 1.0;
        POPCustomAnimation *moveA = [POPCustomAnimation animationWithBlock:^BOOL(id target, POPCustomAnimation *animation) {
            float time_percent = (animation.currentTime - animation.beginTime)/moveDurarion;
            UIView *view = (UIView *)target;
            CGPoint toCenter = CGPointMake(fromCenter.x + time_percent * dx, fromCenter.y - (dy * time_percent * (2 - time_percent)));//抛物线移动
            view.center = toCenter;
            
            CGAffineTransform toTransform = fromTransform;
            toTransform = CGAffineTransformTranslate(toTransform, 50, -50);
            
            CGFloat toScale = 1 + time_percent *(dScale - 1);//线性放大
            toTransform = CGAffineTransformMakeScale(toScale, toScale);
            CGFloat toRotation = dRotation * (1- cosf(time_percent * M_PI_2));//cos曲线旋转（先慢后快）
            toTransform = CGAffineTransformRotate(toTransform, toRotation);
            view.transform = toTransform;
            
            view.alpha = 1 - time_percent;
            return time_percent < 1.0;
        }];
        [imageV pop_addAnimation:moveA forKey:@"animateToImage"];
    }
}

@end
