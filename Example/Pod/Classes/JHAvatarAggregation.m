//
//  JHAvatarAggregation.m
//  JHAvatarAggregation
//
//  Created by caojianhua on 14/11/6.
//  Copyright (c) 2014年 caojianhua. All rights reserved.
//

#import "JHAvatarAggregation.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

static CGFloat kAvatarIconMargin = 2;

@implementation JHAvatarAggregation

+ (JHAvatarAggregation *)shareInstance {
  static dispatch_once_t once;
  static JHAvatarAggregation *instance;

  dispatch_once(&once, ^{
    instance = [[JHAvatarAggregation alloc] init];
  });

  return instance;
}

- (void)aggreationAvatarWithUrls:(NSArray *)urls withCompletion:(void(^)(UIImage *image))completion {

  if (!completion) {
    return;
  }

  // 9 avatar support maximum
  NSMutableArray *sortedUrlList = [[NSMutableArray alloc] initWithCapacity:9];
  [sortedUrlList addObjectsFromArray:urls];

  // sort url
  [sortedUrlList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return [obj1 compare:obj2 options:NSLiteralSearch];
  }];

  // search local cache
  NSString *cachedKey = [sortedUrlList componentsJoinedByString:@","];
  UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cachedKey];

  if (cachedImage) {
    completion(cachedImage);
    return;
  }

  dispatch_group_t group = dispatch_group_create();
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

  NSMutableArray *avatarImages = [[NSMutableArray alloc] init];
  NSMutableArray *sortedAvatarKeys = [[NSMutableArray alloc] init];

  [sortedUrlList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
    [avatarImages addObject:[UIImage imageNamed:@"user_icon"]];
    [sortedAvatarKeys addObject:obj];
  }];

  // not found the image in cache, build a new one
  [urls enumerateObjectsUsingBlock:^(NSString *urlStr, NSUInteger idx, BOOL *stop) {

    dispatch_group_enter(group);
    dispatch_async(queue, ^{
      UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cachedKey];

      if (cachedImage) {
        dispatch_group_leave(group);
      } else {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr]
                                                              options:SDWebImageDownloaderLowPriority
                                                             progress:nil
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {

                                                              if (image) {
                                                                // 下载成功, 保存到缓存
                                                                [avatarImages replaceObjectAtIndex:idx withObject:image];

                                                                [[SDImageCache sharedImageCache] storeImage:image
                                                                                                     forKey:urlStr];
                                                              } else {
                                                                // 下载失败, 从缓存key中移除
                                                                [sortedAvatarKeys replaceObjectAtIndex:idx withObject:@""];
                                                              }
                                                              dispatch_group_leave(group);
                                                            }];
      }

    });


  }];

  __weak JHAvatarAggregation *weakSelf = self;
  dispatch_group_notify(group, queue, ^{
    NSLog(@"All download tasks done");

    UIImage *completionImage = [weakSelf drawAvatars:avatarImages];

    // 生成的头像保存到缓存中
    [[SDImageCache sharedImageCache] storeImage:completionImage forKey:[sortedAvatarKeys componentsJoinedByString:@","]];
    
    //所有头像下载完成, 绘制头像到一张图片中
    dispatch_async(dispatch_get_main_queue(), ^{
      
      completion(completionImage);
    });
  });

}

- (UIImage *)drawAvatars:(NSArray *)images {

  CGSize drawSize = CGSizeMake(90, 90);

  UIGraphicsBeginImageContext(drawSize);

  if (images.count >= 9) {
    [self drawNineImages:images inSize:drawSize];
  } else if (images.count >= 8) {
    [self drawEightImages:images inSize:drawSize];
  } else if (images.count >= 7) {
    [self drawSevenImages:images inSize:drawSize];
  } else if (images.count >= 6) {
    [self drawSixImages:images inSize:drawSize];
  } else if (images.count >= 5) {
    [self drawFiveImages:images inSize:drawSize];
  } else if (images.count >= 4) {
    [self drawFourImages:images inSize:drawSize];
  } else if (images.count >= 3) {
    [self drawThreeImages:images inSize:drawSize];
  } else if (images.count >= 2) {
    [self drawTwoImages:images inSize:drawSize];
  } else if (images.count >= 1) {
    [self drawOneImages:images inSize:drawSize];
  }

  UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return endImage;
}

- (void)drawNineImages:(NSArray *)images inSize:(CGSize)size {

  CGFloat itemImageWidth = size.width / 3;
  CGFloat itemImageHeigth = size.height / 3;
  itemImageWidth = itemImageHeigth = MIN(itemImageWidth, itemImageHeigth);

  for (int i = 0; i < 3; i ++) {
    for (int j = 0; j < 3; j++) {

      [self drawWithWidth:itemImageWidth - kAvatarIconMargin
               withHeight:itemImageHeigth - kAvatarIconMargin
              withCenterX:size.width / 3 * j  + itemImageWidth / 2
              withCenterY:size.height / 3 * i + itemImageHeigth / 2
                withImage:(UIImage *)images[3 * i + j]];
    }
  }
}

- (void)drawEightImages:(NSArray *)images inSize:(CGSize)size {

  CGFloat itemImageWidth = size.width / 3;
  CGFloat itemImageHeigth = size.height / 3;
  itemImageWidth = itemImageHeigth = MIN(itemImageWidth, itemImageHeigth);

  // 0
  [self drawWithWidth:itemImageWidth - kAvatarIconMargin
           withHeight:itemImageHeigth - kAvatarIconMargin
          withCenterX:size.width / 2 - itemImageWidth / 2
          withCenterY:itemImageHeigth / 2
            withImage:(UIImage *)images[0]];

  // 1
  [self drawWithWidth:itemImageWidth - kAvatarIconMargin
           withHeight:itemImageHeigth - kAvatarIconMargin
          withCenterX:size.width / 2 + itemImageWidth / 2
          withCenterY:itemImageHeigth / 2
            withImage:(UIImage *)images[1]];

  // 2 - 7
  for (int i = 1; i < 3; i ++) {
    for (int j = 0; j < 3; j++) {
      [self drawWithWidth:itemImageWidth - kAvatarIconMargin
               withHeight:itemImageHeigth - kAvatarIconMargin
              withCenterX:size.width / 3 * j  + itemImageWidth / 2
              withCenterY:size.height / 3 * i + itemImageHeigth / 2
                withImage:(UIImage *)images[3 * i + j - 1]];
    }
  }
}


- (void)drawSevenImages:(NSArray *)images inSize:(CGSize)size {
  CGFloat itemImageWidth = size.width / 3;
  CGFloat itemImageHeigth = size.height / 3;
  itemImageWidth = itemImageHeigth = MIN(itemImageWidth, itemImageHeigth);

  // 0
  [self drawWithWidth:itemImageWidth - kAvatarIconMargin
           withHeight:itemImageHeigth - kAvatarIconMargin
          withCenterX:size.width / 2
          withCenterY:itemImageHeigth / 2
            withImage:(UIImage *)images[0]];

  // 1 - 6
  for (int i = 1; i < 3; i ++) {
    for (int j = 0; j < 3; j++) {
      [self drawWithWidth:itemImageWidth - kAvatarIconMargin
               withHeight:itemImageHeigth - kAvatarIconMargin
              withCenterX:size.width / 3 * j  + itemImageWidth / 2
              withCenterY:size.height / 3 * i + itemImageHeigth / 2
                withImage:(UIImage *)images[3 * i + j - 2]];
    }
  }
}


- (void)drawSixImages:(NSArray *)images inSize:(CGSize)size {
  CGFloat itemImageWidth = size.width / 3;
  CGFloat itemImageHeigth = size.height / 3;
  itemImageWidth = itemImageHeigth = MIN(itemImageWidth, itemImageHeigth);

  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 3; j++) {
      [self drawWithWidth:itemImageWidth - kAvatarIconMargin
               withHeight:itemImageHeigth - kAvatarIconMargin
              withCenterX:size.width / 3 * j + itemImageWidth / 2
              withCenterY:(size.height / 2 - itemImageHeigth / 2) + i * itemImageHeigth
                withImage:(UIImage *)images[3 * i + j]];
    }
  }
}

- (void)drawFiveImages:(NSArray *)images inSize:(CGSize)size {
  CGFloat itemImageWidth = size.width / 3;
  CGFloat itemImageHeigth = size.height / 3;
  itemImageWidth = itemImageHeigth = MIN(itemImageWidth, itemImageHeigth);

  // 0
  [self drawWithWidth:itemImageWidth - kAvatarIconMargin
           withHeight:itemImageHeigth - kAvatarIconMargin
          withCenterX:size.width / 2 - itemImageWidth / 2
          withCenterY:size.height / 2 - itemImageHeigth / 2
            withImage:(UIImage *)images[0]];

  // 1
  [self drawWithWidth:itemImageWidth - kAvatarIconMargin
           withHeight:itemImageHeigth - kAvatarIconMargin
          withCenterX:size.width / 2 + itemImageWidth / 2
          withCenterY:size.height / 2 - itemImageHeigth / 2
            withImage:(UIImage *)images[1]];

  // 2 - 4
  for (int i = 0; i < 3; i ++) {
    [self drawWithWidth:itemImageWidth - kAvatarIconMargin
             withHeight:itemImageHeigth - kAvatarIconMargin
            withCenterX:size.width / 3 * i + itemImageWidth / 2
            withCenterY:(size.height / 2 - itemImageHeigth / 2) + itemImageHeigth
              withImage:(UIImage *)images[i + 2]];
  }
}


- (void)drawFourImages:(NSArray *)images inSize:(CGSize)size {

  CGFloat itemImageWidth = size.width / 2;
  CGFloat itemImageHeigth = size.height / 2;
  itemImageWidth = itemImageHeigth = MIN(itemImageWidth, itemImageHeigth);

  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      [self drawWithWidth:itemImageWidth - kAvatarIconMargin
               withHeight:itemImageHeigth - kAvatarIconMargin
              withCenterX:itemImageWidth / 2 + itemImageWidth * j
              withCenterY:itemImageHeigth /2 + itemImageHeigth * i
                withImage:(UIImage *)images[2 * i + j]];
    }
  }

}


- (void)drawThreeImages:(NSArray *)images inSize:(CGSize)size {
  CGFloat itemImageWidth = size.width / 2;
  CGFloat itemImageHeigth = size.height / 2;
  itemImageWidth = itemImageHeigth = MIN(itemImageWidth, itemImageHeigth);

  [self drawWithWidth:itemImageWidth - kAvatarIconMargin
           withHeight:itemImageHeigth - kAvatarIconMargin
          withCenterX:size.width / 2
          withCenterY:itemImageHeigth / 2
            withImage:(UIImage *)images[0]];

  for (int i = 0; i < 2; i++) {
    [self drawWithWidth:itemImageWidth - kAvatarIconMargin
             withHeight:itemImageHeigth - kAvatarIconMargin
            withCenterX:itemImageWidth / 2 + itemImageWidth * i
            withCenterY:itemImageHeigth /2 + itemImageHeigth
              withImage:(UIImage *)images[i + 1]];
  }
}


- (void)drawTwoImages:(NSArray *)images inSize:(CGSize)size {
  CGFloat itemImageWidth = size.width / 2;
  CGFloat itemImageHeigth = size.height / 2;

  for (int i = 0; i < 2; i++) {
    [self drawWithWidth:itemImageWidth - kAvatarIconMargin
             withHeight:itemImageHeigth - kAvatarIconMargin
            withCenterX:itemImageWidth / 2 + itemImageWidth * i
            withCenterY:size.height / 2
              withImage:(UIImage *)images[i]];
  }
}


- (void)drawOneImages:(NSArray *)images inSize:(CGSize)size {
  CGFloat itemImageWidth = size.width;
  CGFloat itemImageHeigth = size.height;

  [self drawWithWidth:itemImageWidth
           withHeight:itemImageHeigth
          withCenterX:size.width / 2
          withCenterY:size.height / 2
            withImage:(UIImage *)images[0]];
}

- (void)drawWithWidth:(CGFloat)width
           withHeight:(CGFloat)height
          withCenterX:(CGFloat)x
          withCenterY:(CGFloat)y
            withImage:(UIImage *)image {

  [image drawInRect:CGRectMake(x - width / 2, y - height / 2, width, height)
          blendMode:kCGBlendModeNormal alpha:1.0];
}



@end
