//
//  FeedCollectCell.m
//  OneDay
//
//  Created by Kimi on 12-10-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "RootCollectCell.h"
#import "AddonData.h"
#import "DailyDoManager.h"

#define TopPadding 12.f

@implementation RootCollectCell

- (void)setAddon:(AddonData *)addon
{
    _addon = addon;
    if (_addon) {
        _titleLabel.text = NSLocalizedString(addon.title, nil);
        NSString *cartoonName = [NSString stringWithFormat:@"2_s_%@_0001.png", _addon.cartoon];
        _titleImage.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:cartoonName]];
    }
}

- (void)startCartoon
{
    if(!_cartoonImage.isAnimating) {
        NSMutableArray *cartoons = [NSMutableArray arrayWithCapacity:[_addon.numberOfCartoons intValue]];
        for (int i=0; i<[_addon.numberOfCartoons intValue]; i++) {
            NSString *cartoonName = [NSString stringWithFormat:@"2_s_%@_%04d.png", _addon.cartoon, i+1];
            UIImage *cartoon = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:cartoonName]];
            [cartoons addObject:cartoon];
        }
        
        _cartoonImage.animationImages = cartoons;
        
        [_cartoonImage startAnimating];
        _titleImage.hidden = YES;
        _cartoonImage.hidden = NO;
    }
}

- (void)stopCartoon
{
    if(_cartoonImage.isAnimating) {
        [_cartoonImage stopAnimating];
        _cartoonImage.animationImages = nil;
        _titleImage.hidden = NO;
        _cartoonImage.hidden = YES;
    }
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    if (_editing) {
        _removeButton.hidden = NO;
        _quickButton.hidden = YES;
        _backgroundImage.alpha = 0.4f;
    }
    else {
        _removeButton.hidden = YES;
        _quickButton.hidden = ![[[[DailyDoManager sharedManager] configurationsForDoName:_addon.dailyDoName] objectForKey:kConfigurationShowQuickEntry] boolValue];
        _backgroundImage.alpha = 0.7f;
    }
}

- (void)refreshUI
{
    self.backgroundView = _backgroundImage;
    
    _removeButton.hidden = YES;
    _quickButton.hidden = ![[[[DailyDoManager sharedManager] configurationsForDoName:_addon.dailyDoName] objectForKey:kConfigurationShowQuickEntry] boolValue];
}

- (void)setHighlighted:(BOOL)highlighted
{
    // must implement this method to protect system change the UI
}

- (void)setSelected:(BOOL)selected
{
    // must implement this method to protect system change the UI
}
@end
