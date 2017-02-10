//
//  BBQAttentionAgreeCell.m
//  BBQ
//
//  Created by anymuse on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQAttentionAgreeCell.h"
#import "BBQAttentionBaby.h"
@interface BBQAttentionAgreeCell()
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *refuseButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@end
@implementation BBQAttentionAgreeCell

- (void)awakeFromNib {
    self.agreeButton.layer.cornerRadius = 15;
    self.refuseButton.layer.cornerRadius = 15;
}
-(void)setAttention:(BBQAttentionManageBaby *)attention{
    _attention = attention;
    self.descLabel.text = [NSString stringWithFormat:@"%@申请关注%@",attention.nickname,attention.baobaoname];
    if (attention.flag) {
        self.refuseButton.hidden=YES;
        self.agreeButton.hidden = YES;
        self.stateLabel.hidden = NO;
        if (attention.agree ==1) {
            self.stateLabel.text =@"已同意";
        }else if (attention.agree == -1)
            self.stateLabel.text =@"已拒绝";
    }else{
        self.refuseButton.hidden=NO;
        self.agreeButton.hidden = NO;
        self.stateLabel.hidden = YES;
    }
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    // 1. 可重用标示符
    static NSString *ID = @"AttentionMangerCell";
    // 2. tableView查询可重用Cell
    BBQAttentionAgreeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    // 3. 如果没有可重用cell
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BBQAttentionAgreeCell" owner:nil options:nil] lastObject];
    }
    // 点击cell的时候不要变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction)agree {
    if ([_delegate respondsToSelector:@selector(attentionAgreeCell:DidClickButton:status:)]){
        [_delegate attentionAgreeCell:self DidClickButton:self.attention status:@"1" ];
    }
    
}
- (IBAction)refuse {
    if ([_delegate respondsToSelector:@selector(attentionAgreeCell:DidClickButton:status:)]){
        [_delegate attentionAgreeCell:self DidClickButton:self.attention status:@"-1" ];
    }
}
@end
