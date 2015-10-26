//
//  KMTracker.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-17.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMTracker.h"

@implementation KMTracker

static KMTracker *_sharedTracker = nil;
+ (KMTracker *)sharedTracker
{
    @synchronized(self) {
        if (_sharedTracker == nil) {
            _sharedTracker = [[KMTracker alloc] init];
        }
        return _sharedTracker;
    }
}

//- (void)dealloc
//{
//    [[GANTracker sharedTracker] stopTracker];
//    
//    [super dealloc];
//}

- (void)startTrack
{
    [MobClick startWithAppkey:[self umengAppKey] reportPolicy:REALTIME channelId:[KMCommon channelName]];
    [UMFeedback checkWithAppkey:[self umengAppKey]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umCheck:) name:UMFBCheckFinishedNotification object:nil];
    
    // track start
//    NSString *appKey = [self umTrackAppKey];
//    NSString *deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
//    NSString *urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&udid=%@", appKey, deviceName, udid];
//    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] delegate:nil];
    
//    [self performSelectorInBackground:@selector(reportAppOpenToAdMob) withObject:nil];  // admob
    
//    [self googleTrackCode];
    
//    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-27818855-1"
//                                           dispatchPeriod:-1
//                                                 delegate:nil];
//    [[GANTracker sharedTracker] dispatch];
//    [SSTracker startWithAppKey:[self appKey]];
    
//    [SSWeixin registerWithID:[self weixinAppID]];
//    
//    NSString *dmTrackerID = [self dmTrackerID];
//    if(!KMEmptyString(dmTrackerID)) {
//        [DMConversionTracker startAsynchronousConversionTrackingWithDomobAppId:dmTrackerID];
//    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (_rootController) {
            [UMFeedback showFeedback:_rootController withAppkey:[self umengAppKey]];
        }
    }
}

- (void)umCheck:(NSNotification *)notification
{
    if (notification.userInfo) {
        NSArray * newReplies = [notification.userInfo objectForKey:@"newReplies"];
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"_hasFeedbacks", nil), [newReplies count]];
        NSMutableString *content = [NSMutableString string];
        
        for (int i = 0; i < [newReplies count]; i++) {
            NSString * dateTime = [[newReplies objectAtIndex:i] objectForKey:@"datetime"];
            NSString *_content = [[newReplies objectAtIndex:i] objectForKey:@"content"];
            [content appendString:[NSString stringWithFormat:@"%d .......%@.......\r\n", i+1,dateTime]];
            [content appendString:_content];
            [content appendString:@"\r\n\r\n"];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"See", nil), nil];
        ((UILabel *) [[alertView subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentLeft ;
        [alertView show];
    }
}

#pragma mark - private

- (NSString *)umengAppKey
{
    return SSLogicStringNODefault(@"kUmengAppKey");
}

//- (NSString *)umTrackAppKey
//{
//    return @"a2a24d67d62c3dada40ab22b53ca78de";
//}
//
//- (NSString *)weixinAppID
//{
//    return @"wx933ba5d3c4875496";
//}
//
//- (NSString *)dmTrackerID
//{
//    return @"";
//}
//
//- (void)googleTrackCode
//{
//    [GoogleConversionPing pingWithConversionId:@"997698241" label:@"XM-6CL-KxgMQwdXe2wM" value:@"0" isRepeatable:NO idfaOnly:NO];
//}

#pragma mark - Admob

// This method requires adding #import <CommonCrypto/CommonDigest.h> to your source file.
//- (NSString *)hashedISU
//{
//    NSString *result = nil;
//    NSString *isu = [UIDevice currentDevice].uniqueIdentifier;
//    
//    if(isu) {
//        unsigned char digest[16];
//        NSData *data = [isu dataUsingEncoding:NSASCIIStringEncoding];
//        CC_MD5([data bytes], [data length], digest);
//        
//        result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//                  digest[0], digest[1],
//                  digest[2], digest[3],
//                  digest[4], digest[5],
//                  digest[6], digest[7],
//                  digest[8], digest[9],
//                  digest[10], digest[11],
//                  digest[12], digest[13],
//                  digest[14], digest[15]];
//        result = [result uppercaseString];
//    }
//    return result;
//}
//
//- (void)reportAppOpenToAdMob
//{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool
//    // Have we already reported an app open?
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                                        NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"admob_app_open"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if(![fileManager fileExistsAtPath:appOpenPath]) {
//        // Not yet reported -- report now
//        NSString *appOpenEndpoint = [NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&md5=1&app_id=%@",
//                                     [self hashedISU], @"550931978"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
//        NSURLResponse *response;
//        NSError *error = nil;
//        
//        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
//            [fileManager createFileAtPath:appOpenPath contents:nil attributes:nil]; // successful report, mark it as such
//            NSLog(@"App download successfully reported.");
//        } else {
//            NSLog(@"WARNING: App download not successfully reported. %@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
//        }
//    }
//    [pool release];
//}
@end
