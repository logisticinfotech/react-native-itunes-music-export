
#import "RNItunesMusicExport.h"


@implementation RNItunesMusicExport
RCTResponseSenderBlock CallBack;
BOOL saveToLocal = false;
float totalProgress;
UILabel *lblProgress;
UILabel *lblTitle;
int currentIndex;
AVAssetExportSession *exportSession;
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


- (NSArray<NSString *> *)supportedEvents
{
    return @[@"ProgressEvent"];
}



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
-(UIViewController *)GetPresentedVC {
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
    return presentedVC;
}
-(void)presentMediaPlayer{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *presentedVC = [self GetPresentedVC];
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
    [mediaPicker.view addSubview:[self createProgressView]];
    
    if(saveToLocal) {
        if(tracks.count > 0){
            [self SaveTracksToLocal:tracks mediaPicker:mediaPicker trackListData:trackListData];
        }else{
            CallBack(@[[NSNull null], trackListData]);
        }
    }else{
        CallBack(@[[NSNull null], trackListData]);
    }
}


-(void)SaveTracksToLocal:(NSArray *)tracks mediaPicker:(MPMediaPickerController *)mediaPicker trackListData:(NSMutableArray *)trackListData {
    if(tracks.count > currentIndex) {
        MPMediaItem *item = tracks[currentIndex];
        [self saveTracksToDocucmentDirectory:item exporting:^(NSString *result) {
            currentIndex++;
            [self SaveTracksToLocal:tracks mediaPicker:mediaPicker trackListData:trackListData];
        }];
    }else{
        currentIndex = 0;
        [mediaPicker dismissViewControllerAnimated:true completion:^{
            CallBack(@[[NSNull null], trackListData]);
        }];
    }
}

//Create Progress View

-(UIView *)createProgressView{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    //Progress View
    UIView *progressView = [[UIView alloc]initWithFrame:CGRectMake(40, (height - 100)/2, width - 80, 120)];
    progressView.layer.cornerRadius = 10;
    progressView.backgroundColor = [UIColor colorWithRed:(180.0f/255.0f) green:(180.0f/255.0f) blue:(180.0f/255.0f) alpha:1.0];
    
    //ProgressLabel
    lblProgress = [[UILabel alloc]initWithFrame:CGRectMake(0, 17, width - 80, 25)];
    lblProgress.textColor = [UIColor whiteColor];
    lblProgress.font = [UIFont systemFontOfSize:20];
    lblProgress.textAlignment = NSTextAlignmentCenter;
    [progressView addSubview:lblProgress];
    
    //Import Label
    lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 57, width - 80, 50)];
    lblTitle.numberOfLines = 2;
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont systemFontOfSize:16];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [progressView addSubview:lblTitle];
    return progressView;
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

-(void)saveTracksToDocucmentDirectory:(MPMediaItem *)item exporting:(void (^) (NSString *result))handler {
    [self CreateMusicFolder];
    //    __block int progress = 0;
    //    __block int i = 0;
    //    __block BOOL isFirstTime = true;
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    if(url != nil || [url isKindOfClass:[NSNull class]]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@",url];
        NSArray *idArray = [urlStr componentsSeparatedByString:@"id="];
        if(idArray.count > 1) {
            NSString *trackID = idArray[1];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentURL = [paths objectAtIndex:0];
            NSString *outputUrl = [documentURL stringByAppendingString:[NSString stringWithFormat:@"/Music/%@.m4a",trackID]];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:item forKey:@"mediaItem"];
            [dict setObject:[NSNumber numberWithInt:currentIndex] forKey:@"index"];
            NSTimer *exportProgressBarTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateExportDisplay:) userInfo:dict repeats:YES];
            if ([[NSFileManager defaultManager] fileExistsAtPath:outputUrl]){
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [exportProgressBarTimer invalidate];
                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [exportProgressBarTimer invalidate];
                        handler(@"File Exist");
                    });
                });
            }
            exportSession = [[AVAssetExportSession alloc]initWithAsset:[AVAsset assetWithURL:url] presetName:AVAssetExportPresetAppleM4A];
            exportSession.shouldOptimizeForNetworkUse = true;
            exportSession.outputFileType = AVFileTypeAppleM4A;
            exportSession.outputURL = [NSURL fileURLWithPath:outputUrl];
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                if (exportSession.status == AVAssetExportSessionStatusCompleted)  {
                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [exportProgressBarTimer invalidate];
                        handler(@"Export Success");
                    });
                } else if(exportSession.status == AVAssetExportSessionStatusFailed) {
                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [exportProgressBarTimer invalidate];
                        handler(@"Export Failed");
                    });
                }
            }];
        }
    }
}

-(void)updateExportDisplay:(NSTimer*)timer {
    NSDictionary *dict = (NSDictionary *)[timer userInfo];
    MPMediaItem *item = [dict objectForKey:@"mediaItem"];
    NSString *title = [item valueForProperty: MPMediaItemPropertyTitle];
    float progress = exportSession.progress;
    if(title != nil || [title isKindOfClass:[NSNull class]]) {
        if(![lblTitle.text isEqualToString:title]) {
            lblTitle.text = title;
        }
    }
    NSString *strProgress = [NSString stringWithFormat:@"%.2f%@",progress * 100,@"%"];
    if(![lblProgress.text isEqualToString:strProgress]) {
        lblProgress.text = strProgress;
    }
    if (progress > .99) {
        lblProgress.text = @"100%";
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [timer invalidate];
        });
    }
}

@end

