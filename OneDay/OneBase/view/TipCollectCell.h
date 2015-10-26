//
//  TipCollectCell.h
//  OneDay
//
//  Created by Yu Tianhang on 12-12-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipCollectCell : UICollectionViewCell <UIScrollViewDelegate>
@property (nonatomic) IBOutlet UIScrollView *zoomView;
@property (nonatomic) IBOutlet UIImageView *tipImageView;

- (IBAction)doubleTaps:(id)sender;
@end
