
#import "RNItunesMusicExport.h"


@implementation RNItunesMusicExport
RCTResponseSenderBlock CallBack;
BOOL saveToLocal = false;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getList:(NSDictionary *)param callback:(RCTResponseSenderBlock)callback ) {
    CallBack=callback;
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        switch (status) {
            case MPMediaLibraryAuthorizationStatusRestricted: {
                CallBack(@[@"Permission Restricted"]);
                // restricted
                break;
            }
            case MPMediaLibraryAuthorizationStatusDenied: {
                CallBack(@[@"Permission Denied"]);
                // Denied
                break;
            }
            case MPMediaLibraryAuthorizationStatusAuthorized: {
                if([param objectForKey:@"saveToLocal"] != nil) {
                    BOOL value = [[param objectForKey:@"saveToLocal"] boolValue];
                    saveToLocal = value;
                }
                [self presentMediaPlayer];
                // Authorised
                break;
            }
            default: {
                break;
            }
        }
    }];
}

-(void)presentMediaPlayer{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *topViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UIViewController *presentedVC = [[[UIApplication sharedApplication]keyWindow]rootViewController];
        if(presentedVC.presentedViewController) {
            presentedVC = presentedVC.presentedViewController;
        }else if([presentedVC isKindOfClass:[UINavigationController class]]){
            UINavigationController *navVc = (UINavigationController *)topViewController;
            presentedVC = navVc.topViewController;
        }else if([presentedVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabVc = (UITabBarController *)topViewController;
            presentedVC = tabVc.selectedViewController;
        }
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.showsCloudItems = NO;
        [mediaPicker setDelegate:self];
        [presentedVC presentViewController:mediaPicker animated:true completion:^{}];
    });
}

//MARK:- MPMEDIA Delegate Methods

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:true completion:^{
        CallBack(@[[NSNull null],@[]]);
    }];
}
-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSArray *tracks = [mediaItemCollection items];
    NSMutableArray *trackListData = [[NSMutableArray alloc]init];
    for(MPMediaItem *item in tracks) {
        NSMutableDictionary *trackData = [self getMediaItemDetail:item];
        [trackListData addObject:trackData];
    }
    [mediaPicker dismissViewControllerAnimated:true completion:nil];
    if(saveToLocal) {
        if(tracks.count > 0){
            [self saveTracksToDocucmentDirectory:tracks exporting:^(int progress) {
                if(progress == tracks.count) {
                    CallBack(@[[NSNull null], trackListData]);
                }
            }];
        }else{
            CallBack(@[[NSNull null], trackListData]);
        }
    }else{
        CallBack(@[[NSNull null], trackListData]);
    }
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
    
    if(title != nil || [title isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",title] forKey:@"title"];
    }
    if(albumTitle != nil || [albumTitle isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",albumTitle] forKey:@"albumTitle"];
    }
    if(albumArtist != nil || [albumArtist isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",albumArtist] forKey:@"albumArtist"];
    }
    if(genre != nil || [genre isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",genre] forKey:@"genre"];
    }
    if(duration != nil || [duration isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",duration] forKey:@"duration"];
    }
    if(playCount != nil || [playCount isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",playCount] forKey:@"playCount"];
    }
    if(trackCount != nil || [trackCount isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",trackCount] forKey:@"trackCount"];
    }
    if(trackNumber != nil || [trackNumber isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",trackNumber] forKey:@"trackNumber"];
    }
    if(isCloudItem != nil || [isCloudItem isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",isCloudItem] forKey:@"isCloudItem"];
    }
    if(rating != nil || [rating isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",rating] forKey:@"rating"];
    }
    if(lyrics != nil || [lyrics isKindOfClass:[NSNull class]]) {
        [dict setObject:[NSString stringWithFormat:@"%@",lyrics] forKey:@"lyrics"];
    }
    if(url != nil || [url isKindOfClass:[NSNull class]]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@",url];
        [dict setObject:urlStr forKey:@"url"];
        NSArray *idArray = [urlStr componentsSeparatedByString:@"id="];
        if(idArray.count > 1) {
            [dict setObject:[NSString stringWithFormat:@"%@",idArray[1]] forKey:@"trackID"];
        }
        
    }
    return dict;
    
    // For ArtWork Image
    
    //  MPMediaItemArtwork *albumArtWork = [item valueForProperty:MPMediaItemPropertyArtwork];
    //    if(albumArtWork != nil || [albumArtWork isKindOfClass:[NSNull class]]) {
    //        UIImage *artWorkImage = [albumArtWork imageWithSize:CGSizeMake(150, 150)];
    //        NSData *artWorkData = UIImagePNGRepresentation(artWorkImage);
    //        [dict setObject:[artWorkData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"albumArtWork"];
    //    }
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

