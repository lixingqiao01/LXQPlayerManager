//
//  LXQPlayer.h
//  JuducualBigData
//
//  Created by bsj－mac1 on 2018/4/16.
//  Copyright © 2018年 bsj. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface LXQPlayer : AVPlayer

@property (nonatomic, strong, readonly) id timeObserver;
+ (instancetype)sharePlayer;
- (void)xq_addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block;
- (void)xq_removeTimeObserver;
@end
