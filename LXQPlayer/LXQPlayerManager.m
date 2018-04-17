//
//  LXQPlayerManager.m
//  LXQPlayer
//
//  Created by bsj－mac1 on 2018/4/15.
//  Copyright © 2018年 bsj－mac1. All rights reserved.
//

#import "LXQPlayerManager.h"

@interface LXQPlayerManager ()

@property (nonatomic, strong)   LXQPlayer       *player;
@property (nonatomic, strong)   AVPlayerItem    *playItem;
@property (nonatomic, copy)     void(^progressBlock)(float loadProgress,float duration);
@property (nonatomic, copy)     void(^playProgressBlock)(float playProgress,float duration);
@property (nonatomic, copy)     void(^completeBlock)(LXQPlayer *player);
@property (nonatomic, strong)   NSMutableDictionary<NSString *,AVPlayerItem *>*playItemDict;

@property (nonatomic, strong)   NSTimer         *timer;

@end

@implementation LXQPlayerManager

- (LXQPlayer *)player{
    if (!_player) {
        _player = [LXQPlayer sharePlayer];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _player;
}

- (AVPlayerItem *)xq_createPlayerItemWithURL:(NSURL *)url{
    if (!self.playItem) {
        self.playItem = [[AVPlayerItem alloc]initWithURL:url];
        [self.playItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self.playItem;
//    AVPlayerItem *playItem = [[AVPlayerItem alloc]initWithURL:url];
//    [playItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//    return playItem;
}

- (void)xq_playWithURL:(NSURL *)url progress:(void(^)(float loadProgress,float duration))progressBlock{
    if (self.player.timeObserver) {
        [self.player xq_removeTimeObserver];
        [self xq_pause];
    }
    [self.player replaceCurrentItemWithPlayerItem:[self xq_createPlayerItemWithURL:url]];
    self.progressBlock = progressBlock;
}

- (void)xq_playWithPlayProgress:(void(^)(float playProgress,float duration))progressBlock complete:(void(^)(LXQPlayer *player))complete{
    [self.player play];
    self.completeBlock = complete;
    [self getProgesaa:progressBlock];
    
    //监听播放是否完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)getProgesaa:(void(^)(float playProgress,float duration))progressBlock{
    __weak typeof(self)weakSelf = self;
    [self.player xq_addPeriodicTimeObserverForInterval:CMTimeMake(1, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        if (current) {
            progressBlock(current,total);
        }
    }];
}

- (void)xq_pause{
    [self.player pause];
}

- (void)playFinished{
    //播放完成后需要移除监听
    [self.player seekToTime:CMTimeMake(0, 1)];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.completeBlock(self.player);
    if (self.player.timeObserver) {
        [self.player xq_removeTimeObserver];
    }
//    [self.playItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:@"loadedTimeRanges"];
//    [self removeObserver:self forKeyPath:@"status"];
    //播放完成后还需要移除播放进度的监听
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{

    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {//监听缓存进度
        AVPlayerItem *item = object;
        NSArray *array = item.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        self.progressBlock(totalBuffer, CMTimeGetSeconds(item.duration));
        if (round(totalBuffer) == round(CMTimeGetSeconds(item.duration))) {
//            NSLog(@"缓存进度监听已经移除");
            [item removeObserver:self forKeyPath:keyPath];
        }
    }
    if ([keyPath isEqualToString:@"rate"]) {
        int new = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
//        NSLog(@"new == %d",new);
        if (new == 1) {//播放中
            _isPlay = YES;
        } else {//未播放
            _isPlay = NO;
        }
    }
}

- (void)dealloc{
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player pause];
}

@end
