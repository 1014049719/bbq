//
//  BBQVisitsCell.m
//  BBQ
//
//  Created by slovelys on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQVisitsCell.h"

@implementation BBQVisitsCell

- (void)awakeFromNib {
    // Initialization code
    _headImgView.layer.masksToBounds = YES;
    _headImgView.layer.cornerRadius = 20;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
