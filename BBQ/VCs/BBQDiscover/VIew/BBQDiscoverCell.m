//
//  BBQDiscoverCell.m
//  BBQ
//
//  Created by anymuse on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDiscoverCell.h"
@interface BBQDiscoverCell()


@end

@implementation BBQDiscoverCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    // 1. 可重用标示符
    static NSString *ID = @"BBQDiscoverCell";
    // 2. tableView查询可重用Cell
    BBQDiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    // 3. 如果没有可重用cell
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BBQDiscoverCell" owner:nil options:nil] lastObject];
    }
    // 点击cell的时候不要变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
@end
