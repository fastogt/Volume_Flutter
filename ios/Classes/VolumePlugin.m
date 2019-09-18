#import "VolumePlugin.h"
#import "RDVolumeChanger.h"

@interface VolumePlugin ()
{
    RDVolumeChanger *_volumeChanger;
}
@end

@implementation VolumePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"volume"
            binaryMessenger:[registrar messenger]];
  VolumePlugin* instance = [[VolumePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([call.method isEqualToString:@"controlVolume"]) {
        _volumeChanger = [[RDVolumeChanger alloc] init];
        result(nil);
    }
    else if ([call.method isEqualToString:@"getMaxVol"]) {
        result(@(100));
    }
    else if ([call.method isEqualToString:@"getVol"]) {
        NSNumber *vol = @((int)([_volumeChanger volume] * 100));
        result(vol);
    }
    else if ([call.method isEqualToString:@"setVol"]) {
        NSDictionary *args = call.arguments;
        float volume = [args[@"newVol"] floatValue];
        
        [_volumeChanger setVolume:volume / 100.0];
        result(@(volume));
    } else {
        result(FlutterMethodNotImplemented);
    }

}

@end
