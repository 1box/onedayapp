//
//  PopViewController.h
//  Drawus
//
//  Created by Tianhang Yu on 12-4-1.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CLOSE_BUTTON_FRAME CGRectMake(0, 0, 30, 30)

@protocol KMPopViewControllerDelegate;

@interface KMPopViewController : UIViewController

@property (nonatomic, assign) id<KMPopViewControllerDelegate> kmDelegate;

- (void)pop;
- (void)hide;
- (void)setClosable:(BOOL)closable;
- (void)setCloseBtnFrame:(CGRect)cFrame;    // always set it after all subviews have been added, so we can bring close button front

@end

@protocol KMPopViewControllerDelegate <NSObject>

- (void)didHidePopViewController:(KMPopViewController *)popViewControler;

@end
