//
//  BBQAttentionCell.h
//  BBQ
//
//  Created by anymuse on 15/11/19.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBQAttentionCell;
@protocol BBQAttentionCellDelegate <NSObject>

@optional
- (void)attentionCell:(BBQAttentionCell *)cell DidClickButtonWithBaby:(BBQBabyModel*)baby;

@end
@interface BBQAttentionCell : UITableViewCell
@property(nonatomic, strong) BBQBabyModel *curBaobao;
@property (weak, nonatomic) IBOutlet UIView *nodataView;
@property (weak, nonatomic) IBOutlet UILabel *nodataLabel;
@property (nonatomic, weak) id<BBQAttentionCellDelegate> delegate;

@end
