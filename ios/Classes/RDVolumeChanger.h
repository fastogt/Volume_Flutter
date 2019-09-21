//
//  RDVolumeChanger.h
//  radio2
//
//  Created by Alexander Buharsky on 14/11/2018.
//  Copyright © 2018 abuharsky. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RDVolumeChangerDelegate;
@interface RDVolumeChanger : NSObject

@property(nonatomic, weak) id<RDVolumeChangerDelegate> delegate;

- (void)setVolume:(float)value;
- (float)volume;
- (float)maxVolume;

@end

@protocol RDVolumeChangerDelegate <NSObject>

- (void)volumeChanged:(float)volumeLevel;

@end

NS_ASSUME_NONNULL_END
