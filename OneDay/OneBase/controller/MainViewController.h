//
//  ViewController.h
//  OneDay
//
//  Created by Kimi on 12-10-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"

@class RootVerticalToolbar;

@interface MainViewController : KMViewControllerBase
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) IBOutlet UIImageView *backgroundView;
@property (nonatomic) IBOutlet RootVerticalToolbar *toolbar;
@property (nonatomic) IBOutlet UITapGestureRecognizer *backgroundSingleTap;

- (IBAction)quickButtonClicked:(id)sender;
- (IBAction)removeButtonClicked:(id)sender;
- (IBAction)clearButtonClicked:(id)sender;
@end
