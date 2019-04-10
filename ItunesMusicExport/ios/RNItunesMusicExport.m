
#import "RNItunesMusicExport.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@implementation RNItunesMusicExport

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getList:(NSString *)type:(NSDictionary *)param callback:(RCTResponseSenderBlock)callback ) {
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
                BOOL saveToLocal = false;
                if([param objectForKey:@"saveToLocal"] != nil) {
                    BOOL value = [[param objectForKey:@"saveToLocal"] boolValue];
                    saveToLocal = value;
                }
                if([type isEqualToString: @"tracks"]) {
                    [self GetAllTrackList:saveToLocal trackList:^(NSArray *trackList) {
                        callback(@[[NSNull null], trackList]);
                    }];
                }else if([type isEqualToString: @"playlists"]){
                    [self GetAllPlayList:saveToLocal playList:^(NSArray *playList) {
                        callback(@[[NSNull null], playList]);
                    }];
                }else if([type isEqualToString: @"albums"]){
                    [self GetAllAlbumList:saveToLocal albumList:^(NSArray *albumList) {
                        callback(@[[NSNull null], albumList]);
                    }];
                }else if([type isEqualToString: @"artists"]){
                    [self GetAllArtistList:saveToLocal artistList:^(NSArray *artistList) {
                        callback(@[[NSNull null], artistList]);
                    }];
                }else if([type isEqualToString: @"podcasts"]){
                    [self GetAllPodcast:saveToLocal trackList:^(NSArray *trackList) {
                        callback(@[[NSNull null], trackList]);
                    }];
                }else if([type isEqualToString: @"audioBooks"]){
                    [self GetAllAudioBook:saveToLocal trackList:^(NSArray *trackList) {
                        callback(@[[NSNull null], trackList]);
                    }];
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

-(void)GetAllTrackList:(BOOL)saveToLocal  trackList:(void (^) (NSArray *trackList))exportCompleted  {
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    NSArray *tracksArray = [query items];
    NSMutableArray *trackListData = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracksArray) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [trackListData addObject:trackData];
    }
    if(saveToLocal) {
        if(tracksArray.count > 0) {
//            [self saveTracksToDocucmentDirectory:tracksArray exporting:^(int progress) {
//                float value = (((float)progress/tracksArray.count) * 100);
//                NSLog(@"%f",value);
//                if(progress == tracksArray.count) {
//                    exportCompleted(trackListData);
//                }else{
//                    storedProgress([NSString stringWithFormat:@"%.2f",value]);
//                }
//            }];
            [self saveTracksToDocucmentDirectory:tracksArray exporting:^(int progress) {
                if(progress == tracksArray.count) {
                    exportCompleted(trackListData);
                }
            }];
        }else{
            exportCompleted(trackListData);
        }
    }else{
        exportCompleted(trackListData);
    }
}

//MARK:- GET ALL PodCast List

-(void)GetAllPodcast:(BOOL)saveToLocal trackList:(void (^) (NSArray *trackList))exportCompleted{
    MPMediaQuery *query = [MPMediaQuery podcastsQuery];
    NSArray *tracksArray = [query items];
    NSMutableArray *trackListData = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracksArray) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [trackListData addObject:trackData];
    }
    if(saveToLocal) {
        if(tracksArray.count > 0) {
            [self saveTracksToDocucmentDirectory:tracksArray exporting:^(int progress) {
                if(progress == tracksArray.count) {
                    exportCompleted(trackListData);
                }
            }];
        }else{
            exportCompleted(trackListData);
        }
    }else{
        exportCompleted(trackListData);
    }
}

//MARK:- GET ALL AudioBook List

-(void)GetAllAudioBook:(BOOL)saveToLocal trackList:(void (^) (NSArray *trackList))exportCompleted{
    MPMediaQuery *query = [MPMediaQuery audiobooksQuery];
    NSArray *tracksArray = [query items];
    NSMutableArray *trackListData = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracksArray) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [trackListData addObject:trackData];
    }
    if(saveToLocal) {
        if(tracksArray.count > 0) {
            [self saveTracksToDocucmentDirectory:tracksArray exporting:^(int progress) {
                if(progress == tracksArray.count) {
                    exportCompleted(trackListData);
                }
            }];
        }else{
            exportCompleted(trackListData);
        }
    }else{
        exportCompleted(trackListData);
    }
}
//MARK:- GET ALL PlayList

-(void)GetAllPlayList:(BOOL)saveToLocal playList:(void (^) (NSArray *playList))exportCompleted {
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    NSArray *playListItems = [query collections];
    NSMutableArray *playListArray = [[NSMutableArray alloc]init];
    NSMutableArray *totalPlayListTracks = [[NSMutableArray alloc]init];
    for(MPMediaPlaylist *playList in playListItems) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        NSString *playListName = [playList valueForProperty: MPMediaPlaylistPropertyName];
        NSString *persistentID = [playList valueForProperty: MPMediaPlaylistPropertyPersistentID];
        NSString *description = [playList valueForProperty: MPMediaPlaylistPropertyDescriptionText];
        NSString *authorName = [playList valueForProperty: MPMediaPlaylistPropertyAuthorDisplayName];
        NSMutableArray *tracksArray = [[NSMutableArray alloc]init];
        NSArray *tracks = [playList items];
        [totalPlayListTracks addObjectsFromArray:tracks];
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
    if(saveToLocal) {
        if(totalPlayListTracks.count > 0){
            [self saveTracksToDocucmentDirectory:totalPlayListTracks exporting:^(int progress) {
                if(progress == totalPlayListTracks.count) {
                    exportCompleted(playListArray);
                }
            }];
        }else{
            exportCompleted(playListArray);
        }
    }else{
        exportCompleted(playListArray);
    }
}


//MARK:- Get All Album List

-(void)GetAllAlbumList:(BOOL)saveToLocal albumList:(void (^) (NSArray *albumList))exportCompleted{
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    NSArray *albumList = [query collections];
    NSMutableArray *albumArray = [[NSMutableArray alloc]init];
    NSMutableArray *totalAlbumTracks = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *Album in albumList) {
        NSArray *tracks = [Album items];
        [totalAlbumTracks addObjectsFromArray:tracks];
        NSMutableDictionary *albumData = [self getMediaAlbumDetail:Album saveToLocal:saveToLocal];
        [albumArray addObject:albumData];
    }
    if(saveToLocal) {
        if(totalAlbumTracks.count > 0) {
            [self saveTracksToDocucmentDirectory:totalAlbumTracks exporting:^(int progress) {
                if(progress == totalAlbumTracks.count) {
                    exportCompleted(albumArray);
                }
            }];
        }else{
             exportCompleted(albumArray);
        }
    }else{
        exportCompleted(albumArray);
    }
}

//MARK:- Get All Artist List

-(void)GetAllArtistList:(BOOL)saveToLocal artistList:(void (^) (NSArray *artistList))exportCompleted {
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    artistsQuery.groupingType = MPMediaGroupingAlbumArtist;
    NSArray *artistList = [artistsQuery collections];
    NSMutableArray *artistArray = [[NSMutableArray alloc]init];
    NSMutableArray *totalAlbumTracks = [[NSMutableArray alloc]init];
    for (MPMediaItemCollection *artist in artistList) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        MPMediaItem *albumArtist = [artist representativeItem];
        MPMediaQuery *albumQuery = [MPMediaQuery albumsQuery];
        MPMediaPropertyPredicate* albumPredicate = [MPMediaPropertyPredicate predicateWithValue: [albumArtist valueForProperty: MPMediaItemPropertyAlbumArtist] forProperty: MPMediaItemPropertyAlbumArtist];
        [albumQuery addFilterPredicate: albumPredicate];
        
        NSArray *artistsAblums = [albumQuery collections];
        NSMutableArray *albumArray = [[NSMutableArray alloc]init];
        for(MPMediaItemCollection *Album in artistsAblums) {
            NSArray *tracks = [Album items];
            [totalAlbumTracks addObjectsFromArray:tracks];
            NSMutableDictionary *albumData = [self getMediaAlbumDetail:Album saveToLocal:saveToLocal];
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
    if(saveToLocal) {
        if(totalAlbumTracks.count > 0) {
            [self saveTracksToDocucmentDirectory:totalAlbumTracks exporting:^(int progress) {
                if(progress == totalAlbumTracks.count) {
                    exportCompleted(artistArray);
                }
            }];
        }else{
            exportCompleted(artistArray);
        }
    }else{
        exportCompleted(artistArray);
    }
}

//MARK:- Set Albumn List Raw Data

-(NSMutableDictionary *)getMediaAlbumDetail:(MPMediaItemCollection *)album saveToLocal:(BOOL)saveToLocal  {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    MPMediaItem *mainItem    = [album representativeItem];
    NSString *albumTitle = [mainItem valueForProperty: MPMediaItemPropertyAlbumTitle];
    NSString *artistName = [mainItem valueForProperty: MPMediaItemPropertyAlbumArtist];
    //    MPMediaItemArtwork *albumArtWork = [mainItem valueForProperty:MPMediaItemPropertyArtwork];
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
        NSString *urlStr = [NSString stringWithFormat:@"%@",url];
        [dict setObject:urlStr forKey:@"url"];
        NSArray *idArray = [urlStr componentsSeparatedByString:@"id="];
        if(idArray.count > 1) {
            [dict setObject:idArray[1] forKey:@"trackID"];
        }
        
    }
    return dict;
}

//MARK:- Create Music Folder

-(void)CreateMusicFolder{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/Music"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
}

//MARK:- Save Track To Document Directory

-(void)saveTracksToDocucmentDirectory:(NSArray *)items exporting:(void (^) (int progress))handler {
    [self CreateMusicFolder];
    __block int progress = 0;
    int i = 0;
    for(i=0;i<=items.count;i++){
        if(items.count > i) {
            MPMediaItem *item = items[i];
            NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            if(url != nil || [url isKindOfClass:[NSNull class]]) {
                NSString *urlStr = [NSString stringWithFormat:@"%@",url];
                NSArray *idArray = [urlStr componentsSeparatedByString:@"id="];
                if(idArray.count > 1) {
                    NSString *trackID = idArray[1];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentURL = [paths objectAtIndex:0];
                    NSString *outputUrl = [documentURL stringByAppendingString:[NSString stringWithFormat:@"/Music/%@.m4a",trackID]];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:outputUrl]){
                        progress++;
                        NSLog(@"%@", [NSString stringWithFormat:@"File Exist : %d",progress]);
                        handler(progress);
                        continue;
                    }
                    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:[AVAsset assetWithURL:url] presetName:AVAssetExportPresetAppleM4A];
                    exportSession.shouldOptimizeForNetworkUse = true;
                    exportSession.outputFileType = AVFileTypeAppleM4A;
                    exportSession.outputURL = [NSURL fileURLWithPath:outputUrl];
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        if (exportSession.status == AVAssetExportSessionStatusCompleted)  {
                            progress++;
                            NSLog(@"%@", [NSString stringWithFormat:@"Export Successfull : %d",progress]);
                            handler(progress);
                        } else if(exportSession.status == AVAssetExportSessionStatusFailed) {
                            progress++;
                            NSLog(@"%@", [NSString stringWithFormat:@"Export failed : %d",progress]);
                            NSLog(@"%@", exportSession.error);
                            handler(progress);
                        }else if (exportSession.status == AVAssetExportSessionStatusExporting) {
                            NSLog(@"Progress : %f",exportSession.progress);
                        }
                    }];
                }
            }
        }
    }
}


@end
  
