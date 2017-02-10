//
//  Dynamic.h
//  BBQ
//
//  Created by 朱琨 on 15/12/6.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Attachment.h"
#import "Gift.h"
#import "Comment.h"
#import "JJFMDB.h"

typedef void (^SearchCompletion)(NSArray *dynamics);

typedef NS_ENUM(NSInteger, BBQDynamicSortType) {
    BBQDynamicSortTypeGraphtime,
    BBQDynamicSortTypeDateline
};

typedef NS_ENUM(NSInteger, BBQDynamicUploadState) {
    BBQDynamicUploadStateSuccess,
    BBQDynamicUploadStateWaiting,
    BBQDynamicUploadStateUploading,
    BBQDynamicUploadStateFail
};

typedef NS_ENUM(NSInteger, BBQDynamicContentType) {
    BBQDynamicContentTypeNormal,
    BBQDynamicContentTypePickUp,
    BBQDynamicContentTypeDailyReport,
    BBQDynamicContentTypeSchoolBulletin,
    BBQDynamicContentTypeClassBulletin,
    BBQDynamicContentTypeHomework,
    BBQDynamicContentTypeShowBaby = 11,
    BBQDynamicContentTypeExchange = 12
};

typedef NS_ENUM(NSInteger, BBQDynamicGroupType) {
    BBQDynamicGroupTypeBaby = 1,
    BBQDynamicGroupTypeClass,
    BBQDynamicGroupTypeSchool,
    BBQDynamicGroupTypeSquare
};

typedef NS_ENUM(NSInteger, BBQDynamicMediaType) {
    BBQDynamicMediaTypeNone,
    BBQDynamicMediaTypePhoto,
    BBQDynamicMediaTypeVideo,
    BBQDynamicMediaTypeBatch
};

@interface Dynamic : NSObject<YYModel, JJFMDBProtocol, NSCopying>

@property (assign, nonatomic) BBQDynamicMediaType mediaType;
@property (assign, nonatomic) BBQDynamicUploadState uploadState;
@property (assign, nonatomic) BOOL flag;
@property (assign, nonatomic) BOOL fb_flag;
@property (assign, nonatomic) BOOL reedit;
@property (assign, nonatomic) BOOL setDate;
@property (copy, nonatomic) NSArray *giftdata;
@property (copy, nonatomic) NSArray *reply;
@property (strong, nonatomic) NSNumber *baobaouid;
@property (strong, nonatomic) NSNumber *classuid;
@property (strong, nonatomic) NSNumber *commentcount;
@property (strong, nonatomic) NSNumber *commentupdate;
@property (strong, nonatomic) NSNumber *contentupdate;
@property (strong, nonatomic) NSNumber *creuid;
@property (strong, nonatomic) NSNumber *dateline;
@property (strong, nonatomic) NSNumber *dtype;
@property (strong, nonatomic) NSNumber *giftcount;
@property (strong, nonatomic) NSNumber *giftupdate;
@property (strong, nonatomic) NSNumber *graphtime;
@property (strong, nonatomic) NSNumber *groupkey;
@property (strong, nonatomic) NSNumber *gxid;
/**
 *  BBQDynamicContentType
 */
@property (strong, nonatomic) NSNumber *ispajs;
@property (strong, nonatomic) NSNumber *oldcreuid;
@property (strong, nonatomic) NSNumber *schoolid;
@property (strong, nonatomic) NSNumber *shareflag;
@property (strong, nonatomic) NSNumber *updatetime;
@property (strong, nonatomic) NSNumber *likecount;
@property (assign, nonatomic) BOOL islike;
@property (strong, nonatomic) NSNumber *crelevel;
@property (strong, nonatomic) NSNumber *browsecount;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *baobaoname;
@property (copy, nonatomic) NSString *baobaousername;
@property (copy, nonatomic) NSString *classname;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *crenickname;
@property (copy, nonatomic) NSString *dynatag;
@property (copy, nonatomic) NSString *fbztx;
@property (copy, nonatomic) NSString *guid;
@property (copy, nonatomic) NSString *gxname;
@property (copy, nonatomic) NSString *localid;
@property (copy, nonatomic) NSString *oldcrenickname;
@property (copy, nonatomic) NSString *position;
@property (copy, nonatomic) NSString *schoolname;
@property (copy, nonatomic) NSString *shareusergxname;
@property (copy, nonatomic) NSString *shareusername;
@property (copy, nonatomic) NSString *tradetable;
@property (copy, nonatomic) NSString *user_type;
@property (strong, nonatomic) NSMutableArray *attachinfo;
@property (strong, nonatomic) NSMutableArray *selectedAssetURLs;

+ (instancetype)dynamicWithMediaType:(BBQDynamicMediaType)mediaType object:(id)object;
+ (instancetype)dynamicForWelcomeWithType:(BBQDynamicGroupType)type date:(NSDate *)date;

- (void)updateAttachment:(Attachment *)attach;
- (void)addSelectedAssetURLs:(NSMutableOrderedSet *)selectedAssetURLs;
- (void)addASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteAAttach:(Attachment *)attach;
- (BOOL)isAllImagesHaveDone;
- (BOOL)hasNoContent;
- (BOOL)hasBeenDeleted;

- (void)addComment:(Comment *)comment;
- (void)deleteComment:(Comment *)comment;
- (void)addGift:(Gift *)gift;
- (void)like;

+ (void)deleteDynamic:(Dynamic *)dynamic;

+ (void)dynamicWithGuid:(NSString *)guid completion:(SearchCompletion)block;
//+ (void)dynamicWithLocalid:(NSString *)localid completion:(SearchCompletion)block;
//+ (void)dynamicsWithUploadState:(BBQDynamicUploadState)state completion:(SearchCompletion)block;
+ (void)dynamicsNeedUploadWithCompletion:(SearchCompletion)block;
//+ (void)dynamicsAtBeginningWithCompletion:(SearchCompletion)block;
//+ (void)dynamicsAfterDynamic:(Dynamic *)dynamic completion:(SearchCompletion)block;
//+ (void)dynamicsWhere:(NSString *)where count:(NSInteger)count completion:(SearchCompletion)block;
+ (void)dynamicsWithParams:(NSDictionary *)dic completion:(SearchCompletion)block;

@end
