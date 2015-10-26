//
//  FeedbackViewController.m
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "FeedbackViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "L_FeedbackTableViewCell.h"
#import "R_FeedbackTableViewCell.h"


@implementation FeedbackViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [feedbackClient get];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _mFeedbackDatas = [[NSArray alloc] init];
    
    feedbackClient = [UMFeedback sharedInstance];
    [feedbackClient setAppkey:SSLogicStringNODefault(@"kUmengAppKey") delegate:(id<UMFeedbackDataDelegate>)self];

//    从缓存取topicAndReplies
    self.mFeedbackDatas = feedbackClient.topicAndReplies;
    [self updateTableView:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mTextField resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark keyboard notification

- (void)keyboardWillShow:(NSNotification *) notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat height = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size.height;
    
    CGRect bottomBarFrame = self.mToolBar.frame;
    {
        [UIView beginAnimations:@"bottomBarUp" context:nil];
        [UIView setAnimationDuration: animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        bottomBarFrame.origin.y = self.view.bounds.size.height - 44 - height;
        self.mToolBar.frame = bottomBarFrame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat height = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size.height;
    
    CGRect bottomBarFrame = self.mToolBar.frame;
    if (bottomBarFrame.origin.y < 300)
    {
        [UIView beginAnimations:@"bottomBarDown" context:nil];
        [UIView setAnimationDuration: animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        bottomBarFrame.origin.y += height;
        self.mToolBar.frame = bottomBarFrame;
        [UIView commitAnimations];
    }
}

- (IBAction)sendFeedback:(id)sender
{
    if ([self.mTextField.text length])
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:self.mTextField.text forKey:@"content"];
//        [dictionary setObject:@"2" forKey:@"age_group"];
//        [dictionary setObject:@"female" forKey:@"gender"];
        
        [feedbackClient post:dictionary];
        [self.mTextField resignFirstResponder];
    }
}

- (IBAction)back:(id)sender
{
    [self.mTextField resignFirstResponder];
    [super back:sender];
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_mFeedbackDatas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *content = [[self.mFeedbackDatas objectAtIndex:indexPath.row] objectForKey:@"content"];
    CGSize labelSize = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                               constrainedToSize:CGSizeMake(250.0f, MAXFLOAT)
                                   lineBreakMode:NSLineBreakByWordWrapping];


    return labelSize.height + 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *L_CellIdentifier = @"L_UMFBTableViewCell";
    static NSString *R_CellIdentifier = @"R_UMFBTableViewCell";
    
    NSDictionary *data = [self.mFeedbackDatas objectAtIndex:indexPath.row];
    
    if ([[data valueForKey:@"type"] isEqualToString:@"dev_reply"]) {
        L_FeedbackTableViewCell *cell = (L_FeedbackTableViewCell *) [tableView dequeueReusableCellWithIdentifier:L_CellIdentifier];
        if (cell == nil) {
            cell = [[L_FeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:L_CellIdentifier];
        }
        
        cell.textLabel.text = [data valueForKey:@"content"];
        
        return cell;
    }
    else {
        
        R_FeedbackTableViewCell *cell = (R_FeedbackTableViewCell *) [tableView dequeueReusableCellWithIdentifier:R_CellIdentifier];
        if (cell == nil) {
            cell = [[R_FeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:R_CellIdentifier];
        }
        
        cell.textLabel.text = [data valueForKey:@"content"];
        
        return cell;
        
    }
}

#pragma mark Umeng Feedback delegate

- (void)updateTableView:(NSError *)error
{
    if ([self.mFeedbackDatas count])
    {
        [self.mTableView reloadData];
        
        int lastRowNumber = [self.mTableView numberOfRowsInSection:0] - 1;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.mTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        

    }
    else
    {

    }
}

- (void)updateTextField:(NSError *)error
{
    self.mTextField.text = @"";
    [feedbackClient get];
}

- (void)getFinishedWithError:(NSError *)error
{
    if (!error)
    {
        [self updateTableView:error];
    }
}

- (void)postFinishedWithError:(NSError *)error
{
    UIAlertView *alertView;
    if (!error) {
        // do nothing
    } else{
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_feedbackSendFail", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    }
    [alertView show];

    [self updateTextField:error];
}

#pragma mark scrollow delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self.mTextField resignFirstResponder];
}

@end
