//
//  BBQBabyHeaderView.h
//  BBQ
//
//  Created by 朱琨 on 15/11/17.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBQBabyModel.h"

@interface BBQBabyHeaderView : UIImageView

@property (strong, readonly, nonatomic) BBQBabyModel *baby;
@property (copy, nonatomic) void (^avatarViewClicked)();
@property (copy, nonatomic) void (^inviteButtonClicked)();
@property (copy, nonatomic) void (^attentionButtonClicked)();
//广告
@property (copy,nonatomic) void (^advertisementImageViewClick)();
@property (strong,nonatomic) NSString *advPicUrlStr;
@property (strong,nonatomic) NSString *advUrlStr;
@property (strong,nonatomic) NSString *closeImageUrl;
@property (strong, nonatomic) UIButton *inviteButton;         // 邀请按钮
@property (strong, nonatomic) UIButton *attentionButton;

- (instancetype)initWithBaby:(BBQBabyModel *)baby;
- (void)updateView;

@end
