
#import "RNItunesMusicExport.h"
#import <MediaPlayer/MediaPlayer.h>


@implementation RNItunesMusicExport

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(findEvents:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], @"Hi"]);
}
RCT_EXPORT_METHOD(getList:(RCTResponseSenderBlock)callback) {
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        switch (status) {
            case MPMediaLibraryAuthorizationStatusRestricted: {
                callback(@[@"Permission Restricted"]);
                // restricted
                break;
            }
            case MPMediaLibraryAuthorizationStatusDenied: {
                callback(@[@"Permission Denied"]);
                break;
            }
            case MPMediaLibraryAuthorizationStatusAuthorized: {
                callback(@[[NSNull null], [self GetAllTrackList]]);
                break;
            }
            default: {
                break;
            }
        }
    }];
}

-(NSMutableArray *)GetAllTrackList {
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    NSArray *tracksArray = [query items];
    NSMutableArray *trackList = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracksArray) {
        NSLog(@"item: %@",item);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        NSString *title = [item valueForProperty: MPMediaItemPropertyTitle]; // filterable
        NSString *albumTitle = [item valueForProperty: MPMediaItemPropertyAlbumTitle]; // filterable
        NSString *albumArtist = [item valueForProperty: MPMediaItemPropertyAlbumArtist]; // filterable
        NSString *genre = [item valueForProperty: MPMediaItemPropertyGenre]; // filterable
        NSString *duration = [item valueForProperty: MPMediaItemPropertyPlaybackDuration];
        NSString *playCount = [item valueForProperty: MPMediaItemPropertyPlayCount];
        NSString *albumArtWork = [item valueForProperty:MPMediaItemPropertyArtwork];
        NSString *trackCount = [item valueForProperty:MPMediaItemPropertyAlbumTrackCount];
        NSString *trackNumber = [item valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
        NSString *isCloudItem = [item valueForProperty:MPMediaItemPropertyIsCloudItem];
        NSString *rating = [item valueForProperty:MPMediaItemPropertyRating];
        NSString *lyrics = [item valueForProperty:MPMediaItemPropertyLyrics];
        
        if(title != nil || [title isKindOfClass:[NSNull class]]) {
            [dict setObject:title forKey:@"title"];
        }
        if(albumTitle != nil || [albumTitle isKindOfClass:[NSNull class]]) {
            [dict setObject:albumTitle forKey:@"albumTitle"];
        }
        if(albumArtist != nil || [albumArtist isKindOfClass:[NSNull class]]) {
            [dict setObject:albumArtist forKey:@"albumArtist"];
        }
        if(genre != nil || [genre isKindOfClass:[NSNull class]]) {
            [dict setObject:genre forKey:@"genre"];
        }
        if(duration != nil || [duration isKindOfClass:[NSNull class]]) {
            [dict setObject:duration forKey:@"duration"];
        }
        if(playCount != nil || [playCount isKindOfClass:[NSNull class]]) {
            [dict setObject:playCount forKey:@"playCount"];
        }
        if(albumArtWork != nil || [albumArtWork isKindOfClass:[NSNull class]]) {
            [dict setObject:albumArtWork forKey:@"albumArtWork"];
        }
        if(trackCount != nil || [trackCount isKindOfClass:[NSNull class]]) {
            [dict setObject:trackCount forKey:@"trackCount"];
        }
        if(trackNumber != nil || [trackNumber isKindOfClass:[NSNull class]]) {
            [dict setObject:trackNumber forKey:@"trackNumber"];
        }
        if(isCloudItem != nil || [isCloudItem isKindOfClass:[NSNull class]]) {
            [dict setObject:isCloudItem forKey:@"isCloudItem"];
        }
        if(rating != nil || [rating isKindOfClass:[NSNull class]]) {
            [dict setObject:rating forKey:@"rating"];
        }
        if(lyrics != nil || [lyrics isKindOfClass:[NSNull class]]) {
            [dict setObject:lyrics forKey:@"lyrics"];
        }
        [trackList addObject:dict];
    }
    return trackList;
}

@end
  
