//
//  MoreCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-17.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "MoreCell.h"
#import "KMViewBase.h"

@interface CellNewView : KMViewBase
@property (nonatomic) UILabel *badgeLabel;
@end
@implementation CellNewView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.badgeLabel = [[UILabel alloc] init];
    _badgeLabel.backgroundColor = [UIColor clearColor];
    _badgeLabel.text = NSLocalizedString(@"new", nil);
    _badgeLabel.textColor = [UIColor redColor];
    _badgeLabel.font = [UIFont systemFontOfSize:11.f];
    _badgeLabel.frame = self.bounds;
}
@end

@interface MoreCell ()
@property (nonatomic) IBOutlet CellNewView *cellNewView;
@end

@implementation MoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - public

- (void)setHasNew:(BOOL)hasNew
{
    _hasNew = hasNew;
    _cellNewView.hidden = !_hasNew;
}
@end
