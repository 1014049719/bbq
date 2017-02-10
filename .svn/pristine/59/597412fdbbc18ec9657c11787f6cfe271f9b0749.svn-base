//
//  Attachment.h
//  BBQ
//
//  Created by 朱琨 on 15/12/6.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Dynamic;

typedef NS_ENUM(NSInteger, BBQAttachmentType) {
    BBQAttachmentTypePhoto,
    BBQAttachmentTypeVideo
};

typedef NS_ENUM(NSInteger, BBQAttachmentUploadState) {
    BBQAttachmentUploadStateSuccess,
    BBQAttachmentUploadStateInit,
    BBQAttachmentUploadStateIng,
    BBQAttachmentUploadStateFail
};

typedef NS_ENUM(NSInteger, BBQAttachmentRemoteType) {
    BBQAttachmentRemoteTypeLocal,
    BBQAttachmentRemoteTypeServer,
    BBQAttachmentRemoteTypeQiniu
};

@interface Attachment : NSObject

@property (copy, nonatomic) NSDictionary *data;
@property (copy, nonatomic) NSString *attachid;
@property (strong, nonatomic) NSNumber *remote;
@property (copy, nonatomic) NSString *filepath;
@property (copy, nonatomic) NSString *guid;
@property (copy, nonatomic) NSString *localid;
@property (strong, nonatomic) NSNumber *graphtime;
@property (strong, nonatomic) NSNumber *itype;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSNumber *height;

@property (assign, nonatomic) BBQAttachmentUploadState uploadState;
@property (strong, nonatomic) NSURL *assetURL;

- (NSURL *)filepathURL;
- (NSURL *)thumbpathURL;
- (NSString *)thumbpath;

- (NSString *)videoLocalPath;

+ (instancetype)attachmentWithAsset:(ALAsset *)asset dynamic:(Dynamic *)dynamic;
+ (instancetype)attachWithAssetURL:(NSURL *)assetURL dynamic:(Dynamic *)dynamic;
- (void)deleteLocalFile;
- (void)deleteLocalThumb;

@end
