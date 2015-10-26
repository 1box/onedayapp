//
//  FeedCollectCell.h
//  OneDay
//
//  Created by Kimi on 12-10-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddonData;

@interface RootCollectCell : UICollectionViewCell
@property (nonatomic) IBOutlet UIImageView *backgroundImage;
//@property (nonatomic) IBOutlet UIImageView *selectedBackgroundImage;
@property (nonatomic) IBOutlet UIButton *removeButton;
@property (nonatomic) IBOutlet UIButton *quickButton;
@property (nonatomic) IBOutlet UIImageView *cartoonImage;
@property (nonatomic) IBOutlet UIImageView *titleImage;
@property (nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) AddonData *addon;
@property (nonatomic, getter = isEditing) BOOL editing;
@property (nonatomic, getter = isReordering) BOOL reordering;

- (void)refreshUI;
- (void)startCartoon;
- (void)stopCartoon;
@end
