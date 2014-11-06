//
//  JHViewController.m
//  JHAvatarAggregation
//
//  Created by caojianhua on 11/06/2014.
//  Copyright (c) 2014 caojianhua. All rights reserved.
//

#import "JHViewController.h"
#import "JHAvatarAggregation.h"

@interface JHViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *testImageView;

@end

@implementation JHViewController

- (void)viewDidLoad {
  [super viewDidLoad];


  __weak JHViewController *weakSelf = self;
  [[JHAvatarAggregation shareInstance] aggreationAvatarWithUrls:@[@"http://www.gravatar.com/avatar?d=identicon",
                                                                  @"http://www.gravatar.com/avatar?d=identicon",
                                                                  @"http://www.gravatar.com/avatar?d=identicon",
                                                                  @"http://www.gravatar.com/avatar?d=identicon",
                                                                  @"http://www.gravatar.com/avatar?d=identicon",
                                                                  @"http://www.gravatar.com/avatar?d=identicon",
                                                                  @"http://www.gravatar.com/avatar?d=identicon",
                                                                  @"http://www.gravatar.com/avatar?d=identicon"]
                                                 withCompletion:^(UIImage *image) {
                                                   weakSelf.testImageView.image = image;
                                                 }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
