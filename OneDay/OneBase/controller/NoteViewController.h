//
//  NoteViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-4.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"
#import "KMTextView.h"

@class DailyDoBase;

@interface NoteViewController : KMViewControllerBase

@property (nonatomic) IBOutlet KMTextView *textView;
@property (nonatomic) DailyDoBase *dailyDo;
@property (nonatomic) NSMutableDictionary *propertiesDict;
@property (nonatomic) NSString *propertyKey;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@end
