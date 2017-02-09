//
//  BBQAlbumCell.m
//  BBQ
//
//  Created by 朱琨 on 15/9/6.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQAlbumCell.h"

@implementation BBQAlbumCell

- (void)setBorderWidth:(CGFloat)borderWidth {
  _borderWidth = borderWidth;

  self.imageView1.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.imageView1.layer.borderWidth = borderWidth;

  self.imageView2.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.imageView2.layer.borderWidth = borderWidth;

  self.imageView3.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.imageView3.layer.borderWidth = borderWidth;
}

@end
