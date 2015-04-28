//
//  VideoPlayerView.m
//  VideoPlayerView
//
//  Created by Sam Lau on 4/28/15.
//  Copyright (c) 2015 Sam Lau. All rights reserved.
//

#import "VideoPlayerView.h"
#import <Masonry/Masonry.h>
#import <Classy/Classy.h>
#import <ClassyLiveLayout/ClassyLiveLayout.h>

@implementation VideoPlayerView

#pragma mark - Build view hierarchies
- (void)addSubviews
{
    self.backgroundColor = [UIColor grayColor];
    [self addSubview:self.playOrPauseButton];
    [self addSubview:self.progressSlider];
    [self addSubview:self.zoomInOrOutButton];
}

- (UIButton*)playOrPauseButton
{
    if (!_playOrPauseButton) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPauseButton.cas_styleClass = @"playOrPauseButton";

        UIImage* playImage = [UIImage imageNamed:@"video_play_button"];
        [_playOrPauseButton setImage:playImage forState:UIControlStateNormal];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"video_pause_button"] forState:UIControlStateSelected];

        _playOrPauseButton.cas_size = playImage.size;
    }

    return _playOrPauseButton;
}

- (UISlider*)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [UISlider new];
        _progressSlider.cas_styleClass = @"progressSlider";
    }

    return _progressSlider;
}

- (UIButton*)zoomInOrOutButton
{
    if (!_zoomInOrOutButton) {
        _zoomInOrOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _zoomInOrOutButton.cas_styleClass = @"zoomInOrOutButton";
        [_zoomInOrOutButton setImage:[UIImage imageNamed:@"fullscreen_button"] forState:UIControlStateNormal];
    }

    return _zoomInOrOutButton;
}

#pragma mark - Define Layout
- (void)defineLayout
{
    // Root view layout
    [self mas_updateConstraints:^(MASConstraintMaker* make) {
        // when superview is not nil
        if (self.superview) {
            make.top.equalTo(self.superview.mas_top).offset(20);
            make.left.equalTo(self.superview.mas_left);
            make.right.equalTo(self.superview.mas_right);
            make.height.equalTo(@200);

        }
    }];

    // playOrPauseButton layout
    [self.playOrPauseButton mas_updateConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(self.mas_left).offset(_playOrPauseButton.cas_marginLeft);
        make.bottom.equalTo(self.mas_bottom).offset(_playOrPauseButton.cas_marginBottom);
        make.size.equalTo(_playOrPauseButton);
    }];

    // progressSlider layout
    [self.progressSlider mas_updateConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(_playOrPauseButton.mas_right).offset(_progressSlider.cas_marginLeft);
        make.right.equalTo(_zoomInOrOutButton.mas_left).offset(_progressSlider.cas_marginRight);
        make.centerY.equalTo(_playOrPauseButton.mas_centerY);
    }];

    // zoomInOrOutButton layout
    [self.zoomInOrOutButton mas_updateConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(self.mas_right).offset(-_zoomInOrOutButton.cas_marginRight);
        make.centerY.equalTo(_progressSlider.mas_centerY);
    }];
}

@end
