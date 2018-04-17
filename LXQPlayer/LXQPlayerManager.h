//
//  LXQPlayerManager.h
//  LXQPlayer
//
//  Created by bsj－mac1 on 2018/4/15.
//  Copyright © 2018年 bsj－mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LXQPlayer.h"

@protocol LXQPlayerManagerDelegate<NSObject>

- (void)xq_PlayerStautsChangeWithPlayer:(LXQPlayer *)player status:(AVPlayerStatus)status;

@end

@interface LXQPlayerManager : NSObject
@property (nonatomic, assign)     BOOL        isPlay;
@property (nonatomic, weak)                 id<LXQPlayerManagerDelegate>delegate;
@property (nonatomic, assign)               CMTime      currentTime;

- (void)xq_playWithPlayProgress:(void(^)(float playProgress,float duration))progressBlock complete:(void(^)(LXQPlayer *player))complete;
- (void)xq_pause;
- (void)xq_playWithURL:(NSURL *)url progress:(void(^)(float loadProgress,float duration))progressBlock;
@end
