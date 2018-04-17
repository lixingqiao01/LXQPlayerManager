//
//  LXQPlayer.m
//  JuducualBigData
//
//  Created by bsj－mac1 on 2018/4/16.
//  Copyright © 2018年 bsj. All rights reserved.
//

#import "LXQPlayer.h"

static LXQPlayer    *player = nil;
@interface LXQPlayer ()


@end

@implementation LXQPlayer

+ (instancetype)sharePlayer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[self alloc]init];
    });
    return player;
}

- (void)xq_addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block{
    _timeObserver = [self addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
}

- (void)xq_removeTimeObserver{
    [self removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}

@end
