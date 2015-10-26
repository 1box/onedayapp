//
//  HomeCoverViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-4-5.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCoverCellView : UICollectionViewCell
@property (nonatomic) IBOutlet UIImageView *contentImage;
@end

@interface HomeCoverViewController : UICollectionViewController
@property (nonatomic) IBOutlet UIImageView *checkmark;
- (IBAction)dismiss:(id)sender;
@end
