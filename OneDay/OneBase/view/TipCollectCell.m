//
//  TipCollectCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TipCollectCell.h"

@implementation TipCollectCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTaps:)];
    doubleTap.numberOfTapsRequired = 2;
    [_zoomView addGestureRecognizer:doubleTap];
}

- (IBAction)doubleTaps:(id)sender
{
    if (_zoomView.zoomScale != 1.0) {
        [_zoomView setZoomScale:1.0 animated:YES];
    }
    else {
        [_zoomView setZoomScale:_zoomView.maximumZoomScale  animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _tipImageView;
}

//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
//{
//    NSLog(@"begin");
//}
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    NSLog(@"end:%f", scale);
//}
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    NSLog(@"did zoom:%f", scrollView.zoomScale);
//}
@end
