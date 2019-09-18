//
//  RDVolumeChanger.m
//  radio2
//
//  Created by Alexander Buharsky on 14/11/2018.
//  Copyright © 2018 abuharsky. All rights reserved.
//

#import "RDVolumeChanger.h"
#import <MediaPlayer/MediaPlayer.h>

@interface RDVolumeChanger ()
{
    UIView *_view;
    MPVolumeView *_volumeView;
}
@end

@implementation RDVolumeChanger

- (id) init
{
    self = [super init];
    if (self)
    {
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _volumeView = [[MPVolumeView alloc] initWithFrame: _view.bounds];
                       
        [_view addSubview:_volumeView];
        
        [[self _volumeSlider] addTarget:self action:@selector(_volumeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)setVolume:(float)value
{
    [[self _volumeSlider] setValue:value animated:NO];
}

- (float)volume
{
#if TARGET_IPHONE_SIMULATOR
    return 0.8;
#endif
    
    return [[self _volumeSlider] value];
}

- (void)_volumeChanged:(UISlider*)slider
{
    if ([_delegate respondsToSelector:@selector(volumeChanged:)])
        [_delegate volumeChanged:[self volume]];
}

- (UISlider*)_volumeSlider
{
    for (UIView *subview in _volumeView.subviews)
    {
        if ([NSStringFromClass([subview classForCoder]) hasSuffix:@"VolumeSlider"])
        {
            return (UISlider*)subview;
        }
    }
    
    return nil;
}
@end
