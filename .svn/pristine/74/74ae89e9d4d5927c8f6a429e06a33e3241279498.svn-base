//
//  BBQInviteViewCell.m
//  BBQ
//
//  Created by anymuse on 15/11/30.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQInviteViewCell.h"
#import "BBQAttentionBaby.h"
@interface BBQInviteViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation BBQInviteViewCell

-(void)setCurClass:(BBQClassByPhone *)curClass{
    _curClass = curClass;
    self.nameLabel.text = curClass.classname;
    if (curClass.isattention) {
        self.statusLabel.text = @"已加入";
        self.statusLabel.textColor =  UIColorHex(6ece6b);
    }else{
        self.statusLabel.text =@"未加入";
        self.statusLabel.textColor =[UIColor darkGrayColor];
    }
    self.iconView.hidden= YES;
}
-(void)setAttentionBaobao:(BBQAttentionBaby *)attentionBaobao{
    _attentionBaobao = attentionBaobao;
    self.nameLabel.text = attentionBaobao.realname;
    [self.iconView setImageWithURL:[NSURL URLWithString:attentionBaobao.avartar] placeholder:Placeholder_avatar];
    if (attentionBaobao.isattention) {
        self.statusLabel.text = @"已关注";
        self.statusLabel.textColor =  UIColorHex(6ece6b);
    }else{
        self.statusLabel.text =@"未关注";
        self.statusLabel.textColor =[UIColor darkGrayColor];
    }
}
- (void)awakeFromNib {
    self.iconView.layer.cornerRadius = 20;
    self.iconView.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}
@end
