//
//  DailyDoView.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-26.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMViewBase.h"

@class AddonData;
@class KMTableView;

@interface DailyDoView : KMViewBase <UITableViewDataSource, UITableViewDelegate> {
@private
//    BOOL _todayDoUnfold;
//    BOOL _tomorrowDoUnfold;
//    int _loggedDoUnfoldIndex;
    
    NSInteger _todaySectionIndex;
    NSInteger _tomorrowSectionIndex;
    NSInteger _loggedSectionIndex;
}

@property (nonatomic) IBOutlet KMTableView *listView;
@property (nonatomic) IBOutlet UIButton *unfoldButton;
@property (nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) AddonData *addon;

- (IBAction)edit:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)checkbox:(id)sender;
- (IBAction)moveTodoToTomorrow:(id)sender;
- (IBAction)addTodo:(id)sender;
- (IBAction)unfoldAll:(id)sender;
- (IBAction)otherActions:(id)sender;

@end
