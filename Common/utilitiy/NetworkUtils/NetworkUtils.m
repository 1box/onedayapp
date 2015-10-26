//
//  NetworkUtils.m
//  Drawus
//
//  Created by Tianhang Yu on 12-3-30.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <pthread.h>

#import "Reachability.h"
#import "NetworkUtils.h"

static Reachability * gHostReach = nil;
static pthread_mutex_t  gHostReachMutex = PTHREAD_MUTEX_INITIALIZER;
static BOOL gNotifier = NO;

BOOL KMNetworkConnected(void) 
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [[Reachability reachabilityForInternetConnection] retain];
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
    
	NetworkStatus netStatus = [gHostReach currentReachabilityStatus];	

	return !(netStatus == NotReachable);
}

BOOL KMNetworkWiFiConnected(void)
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [[Reachability reachabilityForInternetConnection] retain];
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
    
    NetworkStatus netStatus = [gHostReach currentReachabilityStatus];
    if(netStatus == NotReachable) {
        return NO;
    }
    if (netStatus == ReachableViaWiFi) {
        return YES; 
    }
    return NO;
}

BOOL SSNetowrkWWANConnected(void)
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [[Reachability reachabilityForInternetConnection] retain];
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
    
    NetworkStatus netStatus = [gHostReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        return NO;
    }
    if (netStatus == ReachableViaWWAN) {
        return YES; 
    }
    return NO;
}

void KMNetworkStartNotifier(void)
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [[Reachability reachabilityForInternetConnection] retain];
            //gNotifier = [gHostReach startNotifier];
            //[gHostReach performSelectorOnMainThread:@selector(startNotifier) withObject:nil waitUntilDone:YES];
            NSMethodSignature *sig = [gHostReach methodSignatureForSelector:@selector(startNotifier)];
            
            if (sig) {
                NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
                [invo setTarget:gHostReach];
                [invo setSelector:@selector(startNotifier)];
                [invo performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
                NSUInteger length = [[invo methodSignature] methodReturnLength];
                void * buffer = (void *)malloc(length);
                [invo getReturnValue:buffer];
                gNotifier = (BOOL)(*((BOOL *)buffer));
                free(buffer);
            }
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
    if(!gNotifier)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(!gNotifier)
        {
            NSMethodSignature *sig = [gHostReach methodSignatureForSelector:@selector(startNotifier)];
            
            if (sig) {
                NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
                [invo setTarget:gHostReach];
                [invo setSelector:@selector(startNotifier)];
                [invo performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
                NSUInteger length = [[invo methodSignature] methodReturnLength];
                void * buffer = (void *)malloc(length);
                [invo getReturnValue:buffer];
                gNotifier = (BOOL)(*((BOOL *)buffer));
                free(buffer);
            }
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
}

void KMNetworkStopNotifier(void)
{
    if(gHostReach == nil)
    {
        return;
    }
    if(gNotifier)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gNotifier)
        {
            //[gHostReach stopNotifier];
            [gHostReach performSelectorOnMainThread:@selector(stopNotifier) withObject:nil waitUntilDone:YES];
            [gHostReach release];
            gHostReach = nil;
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
}
