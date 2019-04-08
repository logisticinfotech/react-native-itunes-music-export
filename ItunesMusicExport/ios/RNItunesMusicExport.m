
#import "RNItunesMusicExport.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@implementation RNItunesMusicExport

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getList:(NSString *)type callback:(RCTResponseSenderBlock)callback ) {
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        switch (status) {
            case MPMediaLibraryAuthorizationStatusRestricted: {
                callback(@[@"Permission Restricted"]);
                // restricted
                break;
            }
            case MPMediaLibraryAuthorizationStatusDenied: {
                callback(@[@"Permission Denied"]);
                // Denied
                break;
            }
            case MPMediaLibraryAuthorizationStatusAuthorized: {
                if([type isEqualToString: @"tracks"]) {
                    callback(@[[NSNull null], [self GetAllTrackList]]);
                }else if([type isEqualToString: @"playlists"]){
                    callback(@[[NSNull null], [self GetAllPlayList]]);
                }else if([type isEqualToString: @"albums"]){
                    callback(@[[NSNull null], [self GetAllAlbumList]]);
                }else if([type isEqualToString: @"artists"]){
                    callback(@[[NSNull null], [self GetAllArtistList]]);
                }else if([type isEqualToString: @"podcasts"]){
                    callback(@[[NSNull null], [self GetAllPodcast]]);
                }else if([type isEqualToString: @"audioBooks"]){
                    callback(@[[NSNull null], [self GetAllAudioBook]]);
                }
                // Authorised
                break;
            }
            default: {
                break;
            }
        }
    }];
}

//MARK:- GET ALL SONG/Track List

-(NSMutableArray *)GetAllTrackList {
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    NSArray *tracksArray = [query items];
    NSMutableArray *trackList = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracksArray) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [trackList addObject:trackData];
    }
    return trackList;
}
-(NSMutableArray *)GetAllPodcast {
    MPMediaQuery *query = [MPMediaQuery podcastsQuery];
    NSArray *tracksArray = [query items];
    NSMutableArray *trackList = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracksArray) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [trackList addObject:trackData];
    }
    return trackList;
}
-(NSMutableArray *)GetAllAudioBook {
    MPMediaQuery *query = [MPMediaQuery audiobooksQuery];
    NSArray *tracksArray = [query items];
    NSMutableArray *trackList = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracksArray) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [trackList addObject:trackData];
    }
    return trackList;
}
//MARK:- GET ALL PlayList

-(NSMutableArray *)GetAllPlayList {
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    NSArray *playListItems = [query collections];
    NSMutableArray *playListArray = [[NSMutableArray alloc]init];
    for(MPMediaPlaylist *playList in playListItems) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        NSString *playListName = [playList valueForProperty: MPMediaPlaylistPropertyName];
        NSString *persistentID = [playList valueForProperty: MPMediaPlaylistPropertyPersistentID];
        NSString *description = [playList valueForProperty: MPMediaPlaylistPropertyDescriptionText];
        NSString *authorName = [playList valueForProperty: MPMediaPlaylistPropertyAuthorDisplayName];
        NSMutableArray *tracksArray = [[NSMutableArray alloc]init];
        NSArray *tracks = [playList items];
        for(MPMediaItem *item in tracks) {
            NSMutableDictionary *trackData = [self getMediaItemDetail:item];
            [tracksArray addObject:trackData];
        }
        if(playListName != nil || [playListName isKindOfClass:[NSNull class]]) {
            [dict setObject:playListName forKey:@"playListName"];
        }
        if(persistentID != nil || [persistentID isKindOfClass:[NSNull class]]) {
            [dict setObject:persistentID forKey:@"persistentID"];
        }
        if(description != nil || [description isKindOfClass:[NSNull class]]) {
            [dict setObject:description forKey:@"description"];
        }
        if(authorName != nil || [authorName isKindOfClass:[NSNull class]]) {
            [dict setObject:authorName forKey:@"authorName"];
        }
        if(tracksArray.count > 0) {
            [dict setObject:tracksArray forKey:@"trackList"];
        }
        if(dict.count > 0){
            [playListArray addObject:dict];
        }
    }
    return playListArray;
}


//MARK:- Get All Album List

-(NSMutableArray *)GetAllAlbumList {
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    NSArray *albumList = [query collections];
    NSMutableArray *albumArray = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *Album in albumList) {
        NSMutableDictionary *albumData = [self getMediaAlbumDetail:Album];
        [albumArray addObject:albumData];
        
    }
    return albumArray;
}

//MARK:- Get All Artist List

-(NSMutableArray *)GetAllArtistList {
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    artistsQuery.groupingType = MPMediaGroupingAlbumArtist;
    NSArray *artistList = [artistsQuery collections];
    NSMutableArray *artistArray = [[NSMutableArray alloc]init];
    for (MPMediaItemCollection *artist in artistList) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        MPMediaItem *albumArtist = [artist representativeItem];
        MPMediaQuery *albumQuery = [MPMediaQuery albumsQuery];
        MPMediaPropertyPredicate* albumPredicate = [MPMediaPropertyPredicate predicateWithValue: [albumArtist valueForProperty: MPMediaItemPropertyAlbumArtist] forProperty: MPMediaItemPropertyAlbumArtist];
        [albumQuery addFilterPredicate: albumPredicate];
        
        NSArray *artistsAblums = [albumQuery collections];
        NSMutableArray *albumArray = [[NSMutableArray alloc]init];
        for(MPMediaItemCollection *Album in artistsAblums) {
            NSMutableDictionary *albumData = [self getMediaAlbumDetail:Album];
            [albumArray addObject:albumData];
            MPMediaItem *mainItem  = [Album representativeItem];
            NSString *artistName = [mainItem valueForProperty: MPMediaItemPropertyAlbumArtist];
            if(artistName != nil || [artistName isKindOfClass:[NSNull class]]) {
                [dict setObject:artistName forKey:@"artistName"];
            }
            if(albumArray.count > 0){
                [dict setObject:albumArray forKey:@"album"];
            }
        }
        [artistArray addObject:dict];
    }
    NSLog(@"artistArray : %@",artistArray);
    return artistArray;
}

//MARK:- Set Albumn List Raw Data

-(NSMutableDictionary *)getMediaAlbumDetail:(MPMediaItemCollection *)album  {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    MPMediaItem *mainItem    = [album representativeItem];
    NSString *albumTitle = [mainItem valueForProperty: MPMediaItemPropertyAlbumTitle];
//    MPMediaItemArtwork *albumArtWork = [mainItem valueForProperty:MPMediaItemPropertyArtwork];
    NSString *artistName = [mainItem valueForProperty: MPMediaItemPropertyAlbumArtist];
    NSMutableArray *tracksArray = [[NSMutableArray alloc]init];
    NSArray *tracks = [album items];
    for(MPMediaItem *item in tracks) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [tracksArray addObject:trackData];
    }
    if(albumTitle != nil || [albumTitle isKindOfClass:[NSNull class]]) {
        [dict setObject:albumTitle forKey:@"albumTitle"];
    }
    if(artistName != nil || [artistName isKindOfClass:[NSNull class]]) {
        [dict setObject:artistName forKey:@"artistName"];
    }
    if(tracksArray.count > 0) {
        [dict setObject:tracksArray forKey:@"trackList"];
    }
//    if(albumArtWork != nil || [albumArtWork isKindOfClass:[NSNull class]]) {
//        UIImage *artWorkImage = [albumArtWork imageWithSize:CGSizeMake(150, 150)];
//        NSData *artWorkData = UIImagePNGRepresentation(artWorkImage);
//        [dict setObject:[artWorkData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"albumArtWork"];
//    }
    return dict;
}


//MARK:- Set Track List Raw Data

-(NSMutableDictionary *)getMediaItemDetail:(MPMediaItem *)item  {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSString *title = [item valueForProperty: MPMediaItemPropertyTitle];
    NSString *albumTitle = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
    NSString *albumArtist = [item valueForProperty: MPMediaItemPropertyAlbumArtist];
    NSString *genre = [item valueForProperty: MPMediaItemPropertyGenre];
    NSString *duration = [item valueForProperty: MPMediaItemPropertyPlaybackDuration];
    NSString *playCount = [item valueForProperty: MPMediaItemPropertyPlayCount];
    NSString *trackCount = [item valueForProperty:MPMediaItemPropertyAlbumTrackCount];
    NSString *trackNumber = [item valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
    NSString *isCloudItem = [item valueForProperty:MPMediaItemPropertyIsCloudItem];
    NSString *rating = [item valueForProperty:MPMediaItemPropertyRating];
    NSString *lyrics = [item valueForProperty:MPMediaItemPropertyLyrics];
    NSString *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
//  MPMediaItemArtwork *albumArtWork = [item valueForProperty:MPMediaItemPropertyArtwork];
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
//    if(albumArtWork != nil || [albumArtWork isKindOfClass:[NSNull class]]) {
//        UIImage *artWorkImage = [albumArtWork imageWithSize:CGSizeMake(150, 150)];
//        NSData *artWorkData = UIImagePNGRepresentation(artWorkImage);
//        [dict setObject:[artWorkData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"albumArtWork"];
//    }
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
    if(url != nil || [url isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",url] forKey:@"url"];
    }
    return dict;
}
@end
  
