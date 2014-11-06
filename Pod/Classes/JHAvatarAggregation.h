//
//  JHAvatarAggregation.h
//  JHAvatarAggregation
//
//  Created by caojianhua on 14/11/6.
//  Copyright (c) 2014年 caojianhua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHAvatarAggregation : NSObject

+ (JHAvatarAggregation *)shareInstance;

// try to get the aggregated avatrs from cache, if not found it will create a new one.
- (void)aggreationAvatarWithUrls:(NSArray *)urls withCompletion:(void(^)(UIImage *image))completion;


@end
