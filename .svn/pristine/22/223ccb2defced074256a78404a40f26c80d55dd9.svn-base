//
//  BBQAttentionAgreeCell.h
//  BBQ
//
//  Created by anymuse on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  BBQAttentionAgreeCell,BBQAttentionManageBaby;
@protocol BBQAttentionAgreeCellDelegate <NSObject>

@optional
- (void)attentionAgreeCell:(BBQAttentionAgreeCell *)cell DidClickButton:(BBQAttentionManageBaby*)attention status:(NSString *)status;

@end
@interface BBQAttentionAgreeCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property(nonatomic, strong) BBQAttentionManageBaby* attention;
@property (nonatomic, weak) id<BBQAttentionAgreeCellDelegate> delegate;
@end
