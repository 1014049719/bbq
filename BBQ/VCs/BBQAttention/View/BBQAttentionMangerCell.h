//
//  BBQAttentionMangerCell.h
//  BBQ
//
//  Created by anymuse on 16/3/3.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  BBQAttentionMangerCell,BBQAttentionBaby;
@protocol BBQAttentionMangerCellDelegate <NSObject>

@optional
- (void)attentionManagerCell:(BBQAttentionMangerCell *)cell DidClickButton:(BBQAttentionBaby*)baby status:(NSInteger)status;

@end
@interface BBQAttentionMangerCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property(nonatomic, strong) BBQAttentionBaby* baby;
@property (nonatomic, weak) id<BBQAttentionMangerCellDelegate> delegate;
@end
