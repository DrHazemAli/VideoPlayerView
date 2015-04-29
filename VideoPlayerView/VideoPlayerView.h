//
//  VideoPlayerView.h
//  VideoPlayerView
//
//  Created by Sam Lau on 4/28/15.
//  Copyright (c) 2015 Sam Lau. All rights reserved.
//

#import "SHPAbstractView.h"

@interface VideoPlayerView : SHPAbstractView

// Initialize
- (instancetype)initWithVideosURL:(NSArray*)videosURL;

// UI properties
@property (strong, nonatomic) UIButton* playOrPauseButton; // 播放或暂停按钮
@property (strong, nonatomic) UISlider* progressSlider; // 拖放进度条
@property (strong, nonatomic) UIButton* zoomInOrOutButton; // 放大或缩小按钮
@property (strong, nonatomic) UILabel* timeLabel; // 已播放时间和视频时长
@property (strong, nonatomic) UILabel* titleLabel; // 视频标题
@property (strong, nonatomic) UIView *bottomView;  // 底部视图，用作背景

@end
