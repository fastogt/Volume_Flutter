#import "VolumePlugin.h"
#import "RDVolumeChanger.h"

@interface VolumePlugin () <RDVolumeChangerDelegate>
{
    RDVolumeChanger *_volumeChanger;
    NSMutableArray *_ignoredVolumeLevels;
}
@property (nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation VolumePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"volume"
                                     binaryMessenger:[registrar messenger]];
    
    VolumePlugin* instance = [[VolumePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [instance setChannel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _volumeChanger = [[RDVolumeChanger alloc] init];
        [_volumeChanger setDelegate:self];
        
        _ignoredVolumeLevels = [NSMutableArray new];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([call.method isEqualToString:@"controlVolume"]) {
        result(nil);
    }
    else if ([call.method isEqualToString:@"getMaxVol"]) {
        result(@((int)(_volumeChanger.maxVolume * 100)));
    }
    else if ([call.method isEqualToString:@"getVol"]) {
        NSNumber *vol = @((int)(_volumeChanger.volume * 100));
        result(vol);
    }
    else if ([call.method isEqualToString:@"setVol"]) {
        NSDictionary *args = call.arguments;
        
        float volume = [args[@"newVol"] floatValue] / 100.0;
        
        [_ignoredVolumeLevels addObject:@(volume)];
        [NSObject cancelPreviousPerformRequestsWithTarget:_ignoredVolumeLevels];
        [_ignoredVolumeLevels performSelector:@selector(removeAllObjects) withObject:nil afterDelay:1.0];
        
        [_volumeChanger setVolume:volume];
        
        result(@((int)(volume * 100.0)));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)volumeChanged:(float)volumeLevel {
    
    if ([_ignoredVolumeLevels containsObject:@(volumeLevel)]) {
        [_ignoredVolumeLevels removeObject:@(volumeLevel)];
        return;
    }

    [self.channel invokeMethod:@"volumeChanged"
                     arguments:@{@"currentVolume" : @((int)(_volumeChanger.volume * 100)),
                                 @"maxVolume" : @((int)(_volumeChanger.maxVolume * 100))}];
}

@end
