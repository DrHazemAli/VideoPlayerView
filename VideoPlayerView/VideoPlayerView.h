//
//  VideoPlayerView.h
//  VideoPlayerView
//
//  Created by Sam Lau on 4/28/15.
//  Copyright (c) 2015 Sam Lau. All rights reserved.
//

#import "SHPAbstractView.h"

@interface VideoPlayerView : SHPAbstractView

@property (strong, nonatomic) UIButton *playOrPauseButton;  // 播放或暂停按钮
@property (strong, nonatomic) UISlider *progressSlider;     // 拖放进度条
@property (strong, nonatomic) UIButton *zoomInOrOutButton;  // 放大或缩小按钮

@end
