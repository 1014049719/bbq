//
//  BBQAttentionMangerCell.m
//  BBQ
//
//  Created by anymuse on 16/3/3.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQAttentionMangerCell.h"
#import "BBQAttentionBaby.h"
@interface BBQAttentionMangerCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;
@property (weak, nonatomic) IBOutlet UIButton *attentionButton;

@end;

@implementation BBQAttentionMangerCell
-(void)setBaby:(BBQAttentionBaby*)baby{
    _baby = baby;
    self.nameLabel.text = baby.realname;
    if (baby.isattention) {
        self.attentionLabel.text =@"已关注";
        self.attentionLabel.textColor =UIColorHex(6ece6b);
        self.attentionButton.hidden = YES;
    }else{
        self.attentionLabel.text =@"未关注";
        self.attentionLabel.textColor =[UIColor darkGrayColor];
        self.attentionButton.hidden = NO;
        [self.attentionButton setTitle:@"关注" forState:UIControlStateNormal];
        [self.attentionButton setBackgroundColor:UIColorHex(6ece6b)];
    }
    [self.iconImageView setImageWithURL:[NSURL URLWithString:baby.avartar] placeholder:Placeholder_avatar];
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    // 1. 可重用标示符
    static NSString *ID = @"AttentionMangerCell";
    // 2. tableView查询可重用Cell
    BBQAttentionMangerCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    // 3. 如果没有可重用cell
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BBQAttentionMangerCell" owner:nil options:nil] lastObject];
    }
    // 点击cell的时候不要变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)awakeFromNib {
    self.iconImageView.layer.cornerRadius = 20;
    self.iconImageView.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.attentionButton.layer.cornerRadius = 15;
}

- (IBAction)attentionButtonClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(attentionManagerCell:DidClickButton:status:)]){
        BBQAttentionBaby* model = self.baby;
        [_delegate attentionManagerCell:self DidClickButton:self.baby status: model.isattention];
    }
}

@end
