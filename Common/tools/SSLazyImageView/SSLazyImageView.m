//
//  SSLazyImageView.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SSLazyImageView.h"
#import "SSSimpleCache.h"
#import "ASIHTTPRequest.h"
#import "NetworkUtilities.h"
#import <QuartzCore/QuartzCore.h>

#define DefaultBorderWidth 7.f
#define kSampleNumberForDownloadTime    10


@interface SSLazyImageViewBorderView : UIView
{
    float           _boundLineWidth;
    BOOL            needClean;
}
@property(nonatomic, retain) UIColor * borderColor;

void drawLine(CGContextRef c, CGFloat originX, CGFloat originY, CGFloat positionX, CGFloat positionY);

- (void)setViewBorderColor:(UIColor *)borderColor;
- (void)setLineWidth:(CGFloat)boundLineWidth;

@end

@implementation SSLazyImageViewBorderView

@synthesize borderColor = _borderColor;

- (void)dealloc
{
    self.borderColor = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        needClean = NO;
        self.backgroundColor = [UIColor clearColor];
        self.borderColor = [UIColor clearColor];
        _boundLineWidth = 0.f;
    }
    return self;
}

- (void)setViewBorderColor:(UIColor *)borderColor
{
    self.borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)boundLineWidth
{
    needClean = YES;
    _boundLineWidth = boundLineWidth;
}

void drawLine(CGContextRef c, CGFloat originX, CGFloat originY, CGFloat positionX, CGFloat positionY)
{
    CGContextMoveToPoint(c, originX, originY);
    CGContextAddLineToPoint(c, positionX, positionY);
    CGContextStrokePath(c);
}

- (void)drawBoundeLine
{
    if (needClean) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, self.frame);
        UIGraphicsEndImageContext();
    }
    needClean = NO;
    
    if (_boundLineWidth > 0) {//draw bound line
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
        CGContextSetLineWidth(context, _boundLineWidth);
                
        drawLine(context, 0, 0, self.frame.size.width, 0);
        drawLine(context, self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
        drawLine(context, self.frame.size.width, self.frame.size.height, 0, self.frame.size.height);
        drawLine(context, 0, self.frame.size.height, 0, 0);
    }
}

- (void)drawRect:(CGRect)rect
{
    [self drawBoundeLine];
}

@end


@interface SSLazyImageView()<ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    BOOL            _requestOnLoading;
    NSTimeInterval  start;
    BOOL            _failOvered;
}
@property(nonatomic, retain) NSDictionary * requestHeader;
@property (nonatomic, retain) SSLazyImageViewBorderView * borderView;
@property (nonatomic, retain) UIImage * netImage;
@property (nonatomic, retain) UIImageView * netImageView;
@property (nonatomic, retain) NSOperationQueue * operationQueue;
@property (nonatomic, retain) ASIHTTPRequest * imageRequest;


@end

@implementation SSLazyImageView
@synthesize requestHeader = _requestHeader;
@synthesize defaultView = _defaultView;
@synthesize netImage = _netImage;
@synthesize borderWidth = _borderWidth;
@synthesize clipType = _clipType;
@synthesize netImageUrl = _netImageUrl;
@synthesize borderView = _borderView;
@synthesize netImageView = _netImageView;
@synthesize operationQueue = _operationQueue;
@synthesize imageRequest = _imageRequest;
@synthesize delegate = _delegate;
@synthesize netImageURLAndHeaders = _netImageURLAndHeaders;
@synthesize cornerRadius = _cornerRadius;

static int s_sampledNumber;

+ (int)sampledNumber
{
    return s_sampledNumber;
}

+ (void)setSampledNumber:(int)number
{
    s_sampledNumber = number;
}

+ (CGSize)CaculateImageMatchCurrentDevice:(CGSize)imageSize
{
#warning adjust the number
    const float iPodMaxHeight =   5000;
    const float iPhoneMaxHeight = 13700; //test
    const float iPadMaxHeight =   16000; //test
    
    float currentDeviceMaxHeith = iPhoneMaxHeight;
    
    NSString* deviceType = [UIDevice currentDevice].model;
    
    if ([deviceType rangeOfString:@"iPod"].length > 0) {//iPod
        currentDeviceMaxHeith = iPodMaxHeight;
    }
    else if([deviceType rangeOfString:@"iPhone"].length > 0) {//iPhone
        currentDeviceMaxHeith = iPhoneMaxHeight;
    }
    else if ([deviceType rangeOfString:@"iPad"].length > 0) {//iPad
        currentDeviceMaxHeith = iPadMaxHeight;
    }
    
    const float imageWidth = 296;
    float imageHeight = imageSize.height * imageWidth / imageSize.width;
    
    if (imageHeight <= currentDeviceMaxHeith) {
        return imageSize;
    }
    return CGSizeMake(150, 150 * imageHeight / imageWidth);
}

#pragma mark -- init & dealloc

- (void)dealloc
{
    self.netImageURLAndHeaders = nil;
    self.requestHeader = nil;
    self.delegate = nil;
    [_imageRequest clearDelegatesAndCancel];
    self.imageRequest = nil;
    [_operationQueue cancelAllOperations];
    self.operationQueue = nil;
    self.borderView = nil;
    self.netImageUrl = nil;
    self.netImage = nil;
    self.defaultView = nil;
    self.netImageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _clipType = SSLazyImageViewClipTypeNone;
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
        self.netImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:_netImageView];
        
        self.borderView = [[[SSLazyImageViewBorderView alloc] initWithFrame:self.bounds] autorelease];
        [self.borderView setLineWidth:DefaultBorderWidth];
        [self addSubview:_borderView];
        
        self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
        [_operationQueue setMaxConcurrentOperationCount:1];
        
        _requestOnLoading = NO;
        _failOvered = NO;
    }
    return self;
}

#pragma mark -- setter

- (void)setNetImageURLAndHeaders:(NSArray *)netImageURLAndHeaders
{
    if (netImageURLAndHeaders != _netImageURLAndHeaders) {
        [netImageURLAndHeaders retain];
        [_netImageURLAndHeaders release];
        _netImageURLAndHeaders = netImageURLAndHeaders;
        
        [self cleanNetImageAndView];
        [self cancelNetRequest];
        [self cancelResizeOperation];
        
        if ([_netImageURLAndHeaders count] == 0) {
            return;
        }
        
        NSString * url = [[_netImageURLAndHeaders objectAtIndex:0] objectForKey:@"url"];
        
        [_netImageUrl release];
        _netImageUrl = [[NSString stringWithString:url] retain];
        
        self.requestHeader = [[_netImageURLAndHeaders objectAtIndex:0] objectForKey:@"header"];
        
        [self downloadResizeAndDisplayImageAsynchronized];
    }
}

//private
- (void)setNetImageUrlWithoutHeader:(NSString *)netImageUrl
{
    if (netImageUrl != _netImageUrl) {
        [netImageUrl retain];
        [_netImageUrl release];
        _netImageUrl = netImageUrl;
        
        [self cleanNetImageAndView];
        
        [self cancelNetRequest];
        [self cancelResizeOperation];
        
        if (_netImageUrl == nil) return;
        
        [_netImageURLAndHeaders release];
        _netImageURLAndHeaders = nil;
        
        [self downloadResizeAndDisplayImageAsynchronized];
    }
}

- (void)setNetImageURL:(NSString *)netImageURL requestHeader:(NSDictionary *)dict
{
    self.requestHeader = dict;
    [self setNetImageUrlWithoutHeader:netImageURL];
}

- (void)setNetImageUrl:(NSString *)netImageUrl//set headerDict nil
{
    self.requestHeader = nil;
    [self setNetImageUrlWithoutHeader:netImageUrl];
}

- (void)setDefaultView:(UIView *)defaultView
{
    if (defaultView != _defaultView) {
        [defaultView retain];
        [_defaultView removeFromSuperview];
        [_defaultView release];
        _defaultView = defaultView;
        [self addSubview:_defaultView];
        [self sendSubviewToBack:_defaultView];
    }
}

- (void)setBorderWidth:(float)borderWidth
{
    _borderWidth = borderWidth;
    [_borderView setLineWidth:_borderWidth];
}

- (void)setFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, self.frame)) {
        return;
    }
    
    [super setFrame:frame];
    _netImageView.frame = self.bounds;
    _borderView.frame = self.bounds;
    
    [self cleanNetImageAndView];
    
    if (_requestOnLoading) {
        //? whether do nothing?
    }
    else {
        [self downloadResizeAndDisplayImageAsynchronized];
    }
}

#pragma mark -- public

- (void)cancelImageRequest
{
    [self cancelNetRequest];
#warning whether need?
    [self cancelResizeOperation];
}


- (void)setBorderColor:(UIColor *)borderColor
{
    [_borderView setViewBorderColor:borderColor];
}

#pragma mark -- private util

-(BOOL)imageNeedClip:(CGSize)size
{
    return !CGSizeEqualToSize(size, self.frame.size);
}

#pragma mark -- private


- (void)cancelNetRequest
{
    if (self.imageRequest) {
        [_imageRequest clearDelegatesAndCancel];
        self.imageRequest = nil;
        _requestOnLoading = NO;
    }
}

- (void)cancelResizeOperation
{
    [_operationQueue cancelAllOperations];
}

- (void)cleanNetImageAndView
{
    self.netImage = nil;
    self.netImageView.image = nil;
    [_defaultView setHidden:NO];
}

- (void)resizeDataAndDisplayAsynchronized:(UIImage *)image
{
    if (CGRectEqualToRect(self.frame, CGRectZero)) return;
    
    [_operationQueue cancelAllOperations];
    
    NSInvocation * loadInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(resizeDataAndDisplay:)]];
    [loadInvocation setTarget:self];
    [loadInvocation setSelector:@selector(resizeDataAndDisplay:)];
    [loadInvocation setArgument:&image atIndex:2];
    
    NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithInvocation:loadInvocation];
    [_operationQueue addOperation:operation];
    [operation release];
}

- (void)resizeDataAndDisplay:(UIImage *)image
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [self resizeNetImage:image];
    [self performSelectorOnMainThread:@selector(displayNetImage) withObject:nil waitUntilDone:YES];
    [pool release];
}

- (void)downloadResizeAndDisplayImageAsynchronized
{
    if ((_requestOnLoading && ([_netImageUrl length] > 0 || [_netImageURLAndHeaders count] > 0)) || ([_netImageUrl length] == 0 && [_netImageURLAndHeaders count] == 0)) {
        return;
    }
    
    if ([_netImageURLAndHeaders count] > 0) {
        BOOL dataExist = NO;
        
        for (NSDictionary * dict in _netImageURLAndHeaders) {
            if ([[SSSimpleCache sharedCache] quickCheckIsCacheExist:[dict objectForKey:@"url"]]) {
                [_netImageUrl release];
                _netImageUrl = [[NSString stringWithString:[dict objectForKey:@"url"]] retain];
                self.requestHeader = [dict objectForKey:@"header"];
                dataExist = YES;
                break;
            }
        }
    }
    
    NSData * data = [[SSSimpleCache sharedCache] dataForUrl:_netImageUrl];
    if (data) {//data cached
        [self resizeDataAndDisplayAsynchronized:[UIImage imageWithData:data]];
    }
    else {
        [self downloadImage];
    }
}


- (BOOL)isCurrentImageDataCached
{
    BOOL isExist = [[SSSimpleCache sharedCache] isCacheExist:_netImageUrl];
    return isExist;
}

- (void)downloadImage
{
    if (!_requestOnLoading) {
        
        start = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
        [_imageRequest clearDelegatesAndCancel];
        self.imageRequest = nil;
        
        NSURL * url = [NSURL URLWithString:_netImageUrl];
        if (url != nil) {
            self.imageRequest = [ASIHTTPRequest requestWithURL:url];
        }
        else {
            self.imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[_netImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
        [_imageRequest setDelegate:self];
        [_imageRequest setDownloadProgressDelegate:self];
        if (_requestHeader != nil) {
            for (int i = 0; i < [[_requestHeader allKeys] count]; i++) {
                NSString * key = [[_requestHeader allKeys] objectAtIndex:i];
                NSString * value = [_requestHeader objectForKey:key];
                [_imageRequest addRequestHeader:key value:value];
            }
        }
        [_imageRequest startAsynchronous];

        _requestOnLoading = YES;
    }
}



- (void)displayNetImage
{
    //    if (_netImage != nil && _netImage.imageOrientation != UIImageOrientationUp) {
    //        _netImage = [UIImage imageWithCGImage:_netImage.CGImage scale:1.f orientation:UIImageOrientationUp];
    //    }
    [_netImageView setImage:_netImage];
    if (_cornerRadius > 0) {
        _netImageView.layer.masksToBounds = YES;
        _netImageView.layer.cornerRadius = _cornerRadius;
    }    
    [_defaultView setHidden:YES];
}

- (void)resizeNetImage:(UIImage *)imageData
{
    CGFloat borderSizeW = self.frame.size.width;
    CGFloat borderSizeH = self.frame.size.height;
    CGFloat imageWidth = imageData.size.width;
    CGFloat imageHeight = imageData.size.height;
    
    UIImage * fixImageData;
    
    if (imageData && _clipType != SSLazyImageViewClipTypeNone && [self imageNeedClip:imageData.size]) {
        
        CGRect imgRect = CGRectZero;
        
        if ((borderSizeW / borderSizeH) < (imageWidth / imageHeight)) {
            // ___________
            //|   |////|  |
            //------------
            imgRect = CGRectMake((imageWidth - (borderSizeW * imageHeight / borderSizeH)) / 2, 0, (borderSizeW * imageHeight / borderSizeH), imageHeight);
        }
        else if((borderSizeW / borderSizeH) >= (imageWidth / imageHeight) && _clipType == SSLazyImageViewClipTypeRemainTop){
            //the image w/h is less than border w/h like the
            //   -- --
            //   |////|
            //   __ __
            //    | |
            //    | |
            //    --   cow!!! don`t delete this annotation
            CGFloat clipH = imageWidth * borderSizeH / borderSizeW;
            //                    CGFloat clipY = (imageHeight - clipH) / 2;
            imgRect = CGRectMake(0, 0, imageWidth, clipH);
        }
        else {
            //the image w/h is less than border w/h like the
            //    --
            //    | |
            //   -- --
            //   |////|
            //   __ __
            //    | |
            //    --   cow!!! don`t delete this annotation
            CGFloat clipH = imageWidth * borderSizeH / borderSizeW;
            CGFloat clipY = (imageHeight - clipH) / 2;
            
            imgRect = CGRectMake(0, clipY, imageWidth, clipH);
        }
        
        CGImageRef sourceImageRef = [imageData CGImage];
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, imgRect);
        UIImage * newImage = [UIImage imageWithCGImage:newImageRef];
        fixImageData = newImage;
        CGImageRelease(newImageRef);
    }
    else {
        fixImageData = imageData;
    }
    UIImage * fImageData = nil;
    if (fixImageData.imageOrientation != UIImageOrientationUp) {
        fImageData = [UIImage imageWithCGImage:fixImageData.CGImage scale:1.f orientation:UIImageOrientationUp];
        self.netImage = fImageData;
    }
    else {
        self.netImage = fixImageData;
    }
}

#pragma mark -- ASIHTTPRequestDelegate

- (void)requestFailed:(ASIHTTPRequest *)request
{
    _requestOnLoading = NO;
    int connect = 4;
    
    if (!SSNetworkWifiConnected()) {
        connect = 1;
    }
    
    if(SSNetworkConnected())
    {
        [SSTracker eventData:[NSDictionary dictionaryWithObjectsAndKeys:@"image", @"category",
                              @"fail", @"tag",
                              [request.url absoluteString], @"label",
                              [NSNumber numberWithInt:connect], @"value", nil]
                      policy:SSTrackPolicyCritical];
        [SSTracker eventKey:[NSDictionary dictionaryWithObjectsAndKeys:@"image", @"category", @"stats_fail", @"tag", nil] acc:1];
    }
    
    NSDictionary * nextURLHeaderDict = [self nextURLAndHeaderDictForURL:request.url.absoluteString];
    
    if ([_netImageURLAndHeaders count] == 0 || nextURLHeaderDict == nil) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(lazyImageView:requestFailed:)]) {
            [_delegate lazyImageView:self requestFailed:request.error];
        }
        return;
    }
    
    [_netImageUrl release];
    _netImageUrl = [[NSString stringWithString:[nextURLHeaderDict objectForKey:@"url"]] retain];
    
    self.requestHeader = [nextURLHeaderDict objectForKey:@"header"];
    [self downloadResizeAndDisplayImageAsynchronized];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [SSTracker eventKey:[NSDictionary dictionaryWithObjectsAndKeys:@"image", @"category", @"stats_succeed", @"tag", nil] acc:1];
    if ([SSCommon random:2] == 1 && [SSLazyImageView sampledNumber] < kSampleNumberForDownloadTime && start > 0) {
        int connect = 4;
        if(!SSNetworkWifiConnected())
        {
            connect = 1;
        }
        
        NSTimeInterval duration = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] - start;
        int intDuration = (int)floor(duration);
        [SSTracker eventData:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"image", @"category",
                              @"sample", @"tag",
                              [request.url absoluteString], @"label",
                              [NSNumber numberWithInt:connect], @"value",
                              [NSNumber numberWithInt:intDuration], @"ext_value", nil]];
        [SSLazyImageView setSampledNumber:[SSLazyImageView sampledNumber] + 1];
        start = 0;
    }
    
    if (request != _imageRequest) return;
    
    NSData * responseData = [request responseData];
    
    if (responseData != nil) {
        [[SSSimpleCache sharedCache] setData:responseData forKey:request.url.absoluteString];
    }
    
    if (responseData != nil) {
        [self resizeDataAndDisplayAsynchronized:[UIImage imageWithData:responseData]];
    }
    
    if (responseData != nil && _delegate != nil && [_delegate respondsToSelector:@selector(lazyImageView:didDownloadImageData:)]) {
        [_delegate lazyImageView:self didDownloadImageData:responseData];
    }
    
    _requestOnLoading = NO;
}

#pragma mark -- ASIProgressDelegate
- (void)setProgress:(float)newProgress
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(lazyImageView:requestProgress:)]) {
        [_delegate lazyImageView:self requestProgress:newProgress];
    }
}

#pragma mark -- url util

- (NSDictionary *)nextURLAndHeaderDictForURL:(NSString *)previousURL
{
    int previousIndex = -1;
    for (int i = 0; i < [_netImageURLAndHeaders count]; i++) {
        if ([[[_netImageURLAndHeaders objectAtIndex:i] objectForKey:@"url"] isEqualToString:previousURL]) {
            previousIndex = i;
            break;
        }
    }
    
    if (previousIndex == -1 || previousIndex >= [_netImageURLAndHeaders count] - 1) {
        return nil;
    }
    
    ++previousIndex;
    
    return [_netImageURLAndHeaders objectAtIndex:previousIndex];
}

@end
