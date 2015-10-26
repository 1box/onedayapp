//
//  UMANWebViewDemo.h
//  UMAppNetwork
//
//  Created by liu yu on 1/9/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMUFPWebView.h"

@interface UMWebViewController : UIViewController {
    
    UMUFPWebView *_mWebView;

    UIView *_mLoadingWaitView;
    UILabel *_mLoadingStatusLabel;
    UIImageView *_mNoNetworkImageView;
    UIActivityIndicatorView *_mLoadingActivityIndicator; 
}

@property (nonatomic, retain) UMUFPWebView *mWebView;

@end
