//
//  BBQDynamicCell.h
//  BBQ
//
//  Created by 朱琨 on 15/11/17.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDynamicLayout.h"
#import "BBQDynamicView.h"
#import "BBQControl.h"
#import "BBQDynamicHelper.h"
#import "BBQDynamicFactory.h"

@class BBQDynamicCell, BBQDynamicCommentCell;

extern NSString * const kDynamicCellTimelineIdentifier;
extern NSString * const kDynamicCellDetailIdentifier;
extern NSString * const kDynamicCellSquareTimelineIdentifier;
extern NSString * const kDynamicCellSquareDetailIdentifier;

@protocol BBQDynamicCellDelegate <NSObject>

@optional
- (void)didClickUserWithID:(NSNumber *)uid;
- (void)cell:(BBQDynamicCell *)cell didClickMediaAtIndex:(NSInteger)index;
- (void)cell:(BBQDynamicCell *)cell didClickCommentCell:(BBQDynamicCommentCell *)commentCell;
- (void)cell:(BBQDynamicCell *)cell didLongPressCommentCell:(BBQDynamicCommentCell *)commentCell;
- (void)didLongPressCommentCell:(BBQDynamicCommentCell *)commentCell;
- (void)didClickShareButtonWithCell:(BBQDynamicCell *)cell;
- (void)didClickLikeButtonWithCell:(BBQDynamicCell *)cell;
- (void)didClickCommentButtonWithCell:(BBQDynamicCell *)cell;
- (void)didClickVisitsButtonWithCell:(BBQDynamicCell *)cell;
- (void)didClickDeleteButtonWithCell:(BBQDynamicCell *)cell;
- (void)didClickEditButtonWithCell:(BBQDynamicCell *)cell;
- (void)didClickGiftButtonWithCell:(BBQDynamicCell *)cell;
- (void)didClickWhiteSpaceWithCell:(BBQDynamicCell *)cell;
- (void)didClickGiftViewWithCell:(BBQDynamicCell *)cell;
- (void)didClickDateView;

@end

@interface BBQDynamicCell : UITableViewCell

@property (weak, nonatomic) id<BBQDynamicCellDelegate> delegate;
@property (strong, nonatomic) BBQDynamicView *dynamicView;
@property (strong, nonatomic) Dynamic *dynamic;
@property (strong, nonatomic) BBQDynamicLayout *layout;

@end
