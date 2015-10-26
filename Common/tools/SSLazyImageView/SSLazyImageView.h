//
//  SSLazyImageView.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/*
    The SSLazyImageView class use for download and show image by image URL.
    There are three way for download and show image:
        1.setNetImageURL: set no header image URL.
        2.setNetImageURL: requestHeader: set URL with header.
        3.setNetImageURLAndHeaders:  set a URL and Header Array, the array parameter formate like the following:
             {
                 url: "xxxx.jpg",
                 header: {
                     Referer: "xxxx",
                     User-Agent: "xxxx"
                 }
             },
             {
                url: "xxxx"
             }
 */

#import <UIKit/UIKit.h>

@protocol SSLazyImageViewDelegate;

typedef enum {
    //default
    SSLazyImageViewClipTypeNone = 0,
    SSLazyImageViewClipTypeRemainTop = 1,
    SSLazyImageViewClipTypeRemainCenter = 2
}SSLazyImageViewClipType;

@interface SSLazyImageView : UIView

@property(nonatomic, retain) UIView * defaultView;
@property(nonatomic, assign) float borderWidth;
@property(nonatomic, assign) SSLazyImageViewClipType clipType;
@property(nonatomic, retain) NSString * netImageUrl;
@property(nonatomic, assign) id<SSLazyImageViewDelegate> delegate;
@property(nonatomic, retain) NSArray * netImageURLAndHeaders;
@property (nonatomic, assign) CGFloat cornerRadius;

- (void)setBorderColor:(UIColor *)borderColor;
- (void)cancelImageRequest;
- (void)setNetImageURL:(NSString *)netImageURL requestHeader:(NSDictionary *)dict;

+ (CGSize)CaculateImageMatchCurrentDevice:(CGSize)imageSize;

@end

@protocol SSLazyImageViewDelegate <NSObject>

@optional

- (void)lazyImageView:(SSLazyImageView *)imageView didDownloadImageData:(NSData *)data;
- (void)lazyImageView:(SSLazyImageView *)imageView requestFailed:(NSError *)error;
- (void)lazyImageView:(SSLazyImageView *)imageView requestProgress:(float)progress;


@end