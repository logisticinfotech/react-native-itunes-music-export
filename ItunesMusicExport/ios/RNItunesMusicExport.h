
//#if __has_include("RCTBridgeModule.h")
//#import "RCTBridgeModule.h"
//#else
//#import "React/RCTBridgeModule.h"
//#endif

#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface RNItunesMusicExport : RCTEventEmitter <RCTBridgeModule,MPMediaPickerControllerDelegate>

@end

