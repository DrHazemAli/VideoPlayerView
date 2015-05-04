//
//  VideoPlayerView.m
//  VideoPlayerView
//
//  Created by Sam Lau on 4/28/15.
//  Copyright (c) 2015 Sam Lau. All rights reserved.
//

@import AVFoundation;

#import "VideoPlayerView.h"
#import <Masonry/Masonry.h>
#import <Classy/Classy.h>
#import <ClassyLiveLayout/ClassyLiveLayout.h>

#define kMainColor [UIColor colorWithRed:253 / 255.0f green:92 / 255.0f blue:2 / 255.0f alpha:1.0f]

@interface VideoPlayerView ()

@property (strong, nonatomic) NSArray* videosURL;
@property (strong, nonatomic) AVQueuePlayer* queuePlayer;
@property (strong, nonatomic) AVPlayerLayer* playerLayer;
@property (strong, nonatomic) NSMutableArray* playerItems; // This array for hold the every player items, or application will crash
@property (strong, nonatomic) id queuePlayerTimerObserver;
@property (assign, nonatomic) BOOL isZoomIn;
// handle pan gesture
@property (assign, nonatomic) CGPoint beginPoint;

@end

@implementation VideoPlayerView

#pragma mark - Initialization
- (instancetype)initWithVideosURL:(NSArray*)videosURL
{
    self = [super init];
    if (!self) {
        return self;
    }

    _videosURL = videosURL;
    // display video on player layer
    AVPlayerLayer* playerLayer = (AVPlayerLayer*)self.layer;
    playerLayer.player = self.queuePlayer;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

    return self;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

#pragma mark - Lazy Initialization
- (AVQueuePlayer*)queuePlayer
{
    if (!_queuePlayer) {
        _queuePlayer = [AVQueuePlayer new];
        for (NSString* url in self.videosURL) {
            AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
            // Add player item to queue player
            if ([_queuePlayer canInsertItem:playerItem afterItem:nil]) {
                [_queuePlayer insertItem:playerItem afterItem:nil];
            }
            // Observe player item property to update UI
            [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            ;
            [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

            [self.playerItems addObject:playerItem];
        }
        [_queuePlayer seekToTime:kCMTimeZero];
    }

    return _queuePlayer;
}

- (NSMutableArray*)playerItems
{
    if (!_playerItems) {
        _playerItems = [NSMutableArray new];
    }

    return _playerItems;
}

#pragma mark - Build view hierarchies
- (void)addSubviews
{
    // setup root view background
    self.backgroundColor = [UIColor blackColor];
    // add all the subviews
    [self addSubview:self.titleLabel];
    [self addSubview:self.bottomView];
    [self addSubview:self.playOrPauseButton];
    [self addSubview:self.progressSlider];
    [self addSubview:self.zoomInOrOutButton];
    [self addSubview:self.timeLabel];
    // attach gesture recognizers
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (UIView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [UIColor blackColor];
        _bottomView.alpha = 0.5;
    }

    return _bottomView;
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
        // respond to action
        [_playOrPauseButton addTarget:self action:@selector(playOrPauseButtonDidTouched:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _playOrPauseButton;
}

- (UISlider*)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [UISlider new];

        _progressSlider.cas_styleClass = @"progressSlider";
        [_progressSlider setThumbImage:[UIImage imageNamed:@"video_time"] forState:UIControlStateNormal];
        // respond to action
        [_progressSlider addTarget:self action:@selector(progressSliderDidPulled:) forControlEvents:UIControlEventValueChanged];
    }

    return _progressSlider;
}

- (UIButton*)zoomInOrOutButton
{
    if (!_zoomInOrOutButton) {
        _zoomInOrOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _zoomInOrOutButton.cas_styleClass = @"zoomInOrOutButton";
        [_zoomInOrOutButton setImage:[UIImage imageNamed:@"fullscreen_button"] forState:UIControlStateNormal];
        // respond to action
        [_zoomInOrOutButton addTarget:self action:@selector(zoomInOrOutButtonDidTouched:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _zoomInOrOutButton;
}

- (UILabel*)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:10.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.text = @"00:00:00 / 00:00:00";
    }

    return _timeLabel;
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"测试视频";
    }

    return _titleLabel;
}

#pragma mark - Define Layout
- (void)defineLayout
{
    // Root view layout
    [self mas_makeConstraints:^(MASConstraintMaker* make) {
        // when superview is not nil
        if (self.superview) {
            make.top.equalTo(self.superview.mas_top).offset(20);
            make.left.equalTo(self.superview.mas_left);
            make.right.equalTo(self.superview.mas_right);
            make.height.equalTo(@212);

        }
    }];

    // bottomView layout
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@50.0f);
    }];

    // playOrPauseButton layout
    [self.playOrPauseButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(self.mas_left).offset(_playOrPauseButton.cas_marginLeft);
        make.bottom.equalTo(self.mas_bottom).offset(_playOrPauseButton.cas_marginBottom);
        make.size.equalTo(_playOrPauseButton);
    }];

    // progressSlider layout
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(_playOrPauseButton.mas_right).offset(_progressSlider.cas_marginLeft);
        make.right.equalTo(_zoomInOrOutButton.mas_left).offset(_progressSlider.cas_marginRight);
        make.centerY.equalTo(_playOrPauseButton.mas_centerY);

    }];

    // zoomInOrOutButton layout
    [self.zoomInOrOutButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(self.mas_right).offset(-_zoomInOrOutButton.cas_marginRight);
        make.centerY.equalTo(_progressSlider.mas_centerY);
    }];

    // timeLabel layout
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(_progressSlider.mas_bottom);
        make.right.equalTo(_progressSlider.mas_right);
    }];

    // titleLabel layout
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(_progressSlider.mas_left);
    }];

    // user press zoomInButton or not
    if (self.isZoomIn) {
        [self defineLandscapeLeftLayout];
    }
    else {
        [self definePortraitLayout];
    }
}

- (void)defineLandscapeLeftLayout
{

    [self mas_remakeConstraints:^(MASConstraintMaker* make) {
        // when superview is not nil
        if (self.superview) {
            make.top.equalTo(self.superview.mas_top).offset(20);
            make.left.equalTo(self.superview.mas_left);
            make.right.equalTo(self.superview.mas_right);
            make.bottom.equalTo(self.superview.mas_bottom);
        }
    }];
}

- (void)definePortraitLayout
{
    [self mas_remakeConstraints:^(MASConstraintMaker* make) {
        // when superview is not nil
        if (self.superview) {
            make.top.equalTo(self.superview.mas_top).offset(20);
            make.left.equalTo(self.superview.mas_left);
            make.right.equalTo(self.superview.mas_right);
            make.height.equalTo(@212);
        }
    }];
}

#pragma mark - Key Value Observing
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(AVPlayerItem*)playerItem change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            [self addTimeObserverToUpdateUI:playerItem];
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
    }
}

- (void)addTimeObserverToUpdateUI:(AVPlayerItem*)playerItem
{
    // remove last timer observer
    if (_queuePlayerTimerObserver) {
        [_queuePlayer removeTimeObserver:_queuePlayerTimerObserver];
        _queuePlayerTimerObserver = nil;
    }

    // setup queuePlayer timer observer
    __weak __typeof(self) weakSelf = self;
    _queuePlayerTimerObserver = [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        // get the time seconds
        CGFloat currentTimeSeconds = CMTimeGetSeconds(playerItem.currentTime);
        CGFloat durationTimeSeconds = CMTimeGetSeconds(playerItem.duration);
        // update UI
        if (!isnan(durationTimeSeconds)) {
            __strong __typeof(self) stongSelf = weakSelf;
            [stongSelf.progressSlider setMaximumValue:durationTimeSeconds];
            [stongSelf.progressSlider setValue:currentTimeSeconds animated:YES];
            stongSelf.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [stongSelf changeDurationToTime:currentTimeSeconds], [stongSelf changeDurationToTime:durationTimeSeconds]];
        }
    }];
}

#pragma mark - Respond to action
- (void)playOrPauseButtonDidTouched:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.queuePlayer play];
    }
    else {
        [self.queuePlayer pause];
    }
}

- (void)progressSliderDidPulled:(UISlider*)sender
{
    [self seekToTime:CMTimeMakeWithSeconds(sender.value, self.queuePlayer.currentTime.timescale)];
}

- (void)seekToTime:(CMTime)time
{
    // first pause the video
    [self.queuePlayer pause];
    //    NSLog(@"调整前时间: %f", CMTimeGetSeconds(self.queuePlayer.currentItem.currentTime));
    [self.queuePlayer seekToTime:time completionHandler:^(BOOL finished) {
        //        NSLog(@"调整后时间: %f", CMTimeGetSeconds(self.queuePlayer.currentItem.currentTime));
        // after seek to time, play the video
        [self.queuePlayer play];
        // add time observer to update ui
        [self addTimeObserverToUpdateUI:self.queuePlayer.currentItem];
    }];
}

- (void)zoomInOrOutButtonDidTouched:(UIButton*)sender
{
    self.isZoomIn = !self.isZoomIn;

    if (self.isZoomIn) {
        // change device orientation
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
    }
    else {
        // change device orientation
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }
    // tell view to update constraint
    [self setNeedsUpdateConstraints];
    // animate the view
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer*)gesture
{
    CGPoint endPoint = CGPointZero;
    CGFloat offset = CGRectGetHeight(self.frame) / 10.0;

    switch (gesture.state) {
    case UIGestureRecognizerStateBegan: {
        _beginPoint = [gesture locationInView:self];
    } break;

    case UIGestureRecognizerStateChanged: {
        endPoint = [gesture locationInView:self];

        if ([self isFastForwardWithBeginPoint:_beginPoint endPoint:endPoint offset:offset]) { // fast forward
            NSLog(@"fast forward");
        }
        else if ([self isFastBackwardWithBeginPoint:_beginPoint endPoint:endPoint offset:offset]) { // back forward
            NSLog(@"fast backward");
        }
        else if ([self isVolumeUpWithBeginPoint:_beginPoint endPoint:endPoint offset:offset viewWidth:CGRectGetWidth(self.frame)]) { //volume up
            NSLog(@"volume up");
        }
        else if ([self isVolumeDownWithBeginPoint:_beginPoint endPoint:endPoint offset:offset viewWidth:CGRectGetWidth(self.frame)]) { //volume down
            NSLog(@"volume down");
        }
        else if ([self isBrightnessUpWithBeginPoint:_beginPoint endPoint:endPoint offset:offset viewWidth:CGRectGetWidth(self.frame)]) { // brightness up
            NSLog(@"brightness up");
        }
        else if ([self isBrightnessDownWithBeginPoint:_beginPoint endPoint:endPoint offset:offset viewWidth:CGRectGetWidth(self.frame)]) { // brightness down
            NSLog(@"brightness down");
        }
    } break;
    case UIGestureRecognizerStateEnded: {

    } break;

    default:
        break;
    }
}

#pragma mark - Handle pan gesture helper methods
- (BOOL)isFastForwardWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint offset:(CGFloat)offset
{
    return (endPoint.x - beginPoint.x) > offset && fabs(endPoint.y - beginPoint.y) <= offset;
}

- (BOOL)isFastBackwardWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint offset:(CGFloat)offset
{
    return (beginPoint.x - endPoint.x) > offset && fabs(endPoint.y - beginPoint.y) <= offset;
}

- (BOOL)isVolumeUpWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint offset:(CGFloat)offset viewWidth:(CGFloat)viewWidth
{
    return (beginPoint.y - endPoint.y) > offset && fabs(endPoint.x - beginPoint.x) <= offset && endPoint.x >= viewWidth / 2.0;
}

- (BOOL)isVolumeDownWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint offset:(CGFloat)offset viewWidth:(CGFloat)viewWidth
{
    return (endPoint.y - beginPoint.y) > offset && fabs(endPoint.x - beginPoint.x) <= offset && endPoint.x >= viewWidth / 2.0;
}

- (BOOL)isBrightnessUpWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint offset:(CGFloat)offset viewWidth:(CGFloat)viewWidth
{
    return (beginPoint.y - endPoint.y) > offset && fabs(endPoint.x - beginPoint.x) <= offset && endPoint.x < viewWidth / 2.0;
}

- (BOOL)isBrightnessDownWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint offset:(CGFloat)offset viewWidth:(CGFloat)viewWidth
{
    return (endPoint.y - beginPoint.y) > offset && fabs(endPoint.x - beginPoint.x) <= offset && endPoint.x < viewWidth / 2.0;
}

#pragma mark - Release resources
- (void)dealloc
{
    // remove all the observers
    for (AVPlayerItem* playerItem in self.playerItems) {
        [playerItem removeObserver:self forKeyPath:@"status"];
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
    // remove last timer observer
    if (_queuePlayerTimerObserver) {
        [_queuePlayer removeTimeObserver:_queuePlayerTimerObserver];
    }
}

#pragma mark - UI helper methods

- (NSString*)changeDurationToTime:(CGFloat)duration
{
    NSInteger time = duration;
    NSString* hour = [NSString stringWithFormat:@"%02ld", time / 3600];
    NSString* min = [NSString stringWithFormat:@"%02ld", (time - [hour integerValue] * 3600) / 60];
    NSString* sec = [NSString stringWithFormat:@"%02ld", time - [hour integerValue] * 3600 - [min integerValue] * 60];
    return [NSString stringWithFormat:@"%@:%@:%@", hour, min, sec];
}

@end
