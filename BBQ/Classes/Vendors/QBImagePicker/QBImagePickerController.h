//
//  QBImagePicker.h
//  QBImagePicker
//
//  Created by Tanaka Katsuma on 2013/12/30.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class QBImagePickerController, Dynamic;

@protocol QBImagePickerControllerDelegate <NSObject>

@optional
- (void)qb_imagePickerController:
(QBImagePickerController *)imagePickerController
                  didSelectAsset:(ALAsset *)asset;
- (void)qb_imagePickerController:
(QBImagePickerController *)imagePickerController
            didSelectAttachments:(NSArray *)attachments selectedAssetURLs:(NSMutableArray *)selectedAssetURLs;

- (void)qb_imagePickerController:
(QBImagePickerController *)imagePickerController
                 didSelectAssets:(NSArray *)assets;
- (void)qb_imagePickerControllerDidCancel:
(QBImagePickerController *)imagePickerController;

- (BOOL)qb_imagePickerController:
(QBImagePickerController *)imagePickerController
               shouldSelectAsset:(ALAsset *)asset;
- (NSArray *)preSelectedAssetURLs;

@end

typedef NS_ENUM(NSUInteger, QBImagePickerControllerFilterType) {
    QBImagePickerControllerFilterTypeNone = 0,
    QBImagePickerControllerFilterTypePhotos,
    QBImagePickerControllerFilterTypeVideos
};

@interface QBImagePickerController : UIViewController

@property(nonatomic, weak) id<QBImagePickerControllerDelegate> delegate;

@property(nonatomic, copy) NSArray *groupTypes;
@property(nonatomic, assign) QBImagePickerControllerFilterType filterType;

@property(nonatomic, assign) BOOL allowsMultipleSelection;
@property(nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property(nonatomic, assign) NSUInteger maximumNumberOfSelection;
@property (assign, nonatomic) BOOL isBatch;
@property(nonatomic, copy) NSString *prompt;
@property(nonatomic, assign) BOOL showsNumberOfSelectedAssets;

@property(nonatomic, assign) NSUInteger numberOfColumnsInPortrait;
@property(nonatomic, assign) NSUInteger numberOfColumnsInLandscape;

@property(nonatomic, strong) NSMutableArray *selectedAssetURLs;
@property (copy, nonatomic) NSArray *preSelectedAssetURLs;
@property (copy, nonatomic) NSString *navTitle;
@property (strong, nonatomic) Dynamic *dynamic;

- (instancetype)initWithDynamic:(Dynamic *)dynamic;
- (instancetype)initWithFilterType:(QBImagePickerControllerFilterType)filterType;

@end
