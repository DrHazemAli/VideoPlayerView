//
//  ViewController.m
//  VideoPlayerView
//
//  Created by Sam Lau on 4/28/15.
//  Copyright (c) 2015 Sam Lau. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerView.h"

@interface ViewController ()

@property (strong, nonatomic) VideoPlayerView* rootView;

@end

@implementation ViewController

#pragma mark - View hierarchy
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.rootView];
}

- (VideoPlayerView*)rootView
{
    if (!_rootView) {
        _rootView = [VideoPlayerView new];
    }

    return _rootView;
}

@end
