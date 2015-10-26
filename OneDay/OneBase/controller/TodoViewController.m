//
//  InputViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-30.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TodoViewController.h"
#import "TipViewController.h"
#import "ToolbarButton.h"

#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "DailyDoBase.h"
#import "TodoData.h"
#import "AddonData.h"
#import "Smark.h"
#import "HintHelper.h"
#import "NSString+NSStringAdditions.h"

#define HelperWordButtonTagPrefix 10000

@interface TodoViewController () <UITextViewDelegate> {
    
    NSRange _changeTextIndexRange;
    NSRange _appendTextIndexRange;
}
@property (nonatomic) NSMutableArray *todos;
@property (nonatomic, weak) SMDetector *detector;
@property (nonatomic) HintHelper *hint;
@end

@implementation TodoViewController

- (NSString *)pageNameForTrack
{
    return [NSString stringWithFormat:@"TodoPage_%@", _dailyDo.addon.dailyDoName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"todoPushToTipPage"]) {
        TipViewController *tController = segue.destinationViewController;
        tController.currentAddon = _dailyDo.addon;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(5.f, 0, 44.f, 44.f);
        [leftButton setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [leftButton addTarget:tController action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        tController.navigationItem.leftBarButtonItem = leftItem;
    }
}

- (void)reportKeyboardDidChangeFrame:(NSNotification *)notification
{
    CGFloat duration = 0.3f; //[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    keyboardFrame = [mainWindow.rootViewController.view convertRect:keyboardFrame fromView:mainWindow];
    
    CGRect vFrame = self.view.frame;
    CGRect tFrame = _inputView.frame;
    tFrame.size.height = vFrame.size.height - keyboardFrame.size.height - SSHeight(_inputHelperBar);
    
    CGRect barFrame = _inputHelperBar.frame;
    barFrame.origin.y = CGRectGetMaxY(tFrame);
    
    [UIView animateWithDuration:duration animations:^{
        _inputView.frame = tFrame;
        _inputHelperBar.frame = barFrame;
    }];
}

#pragma mark - Viewliftcycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detector = [SMDetector defaultDetector];
    self.hint = [[HintHelper alloc] initWithViewController:self dialogsPathPrefix:_dailyDo.addon.dailyDoName];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateInputHelperWords];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportKeyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
//    [_dailyDo makeSnapshot];
    [self refreshText];
    
    if (![_hint show]) {
        [_inputView becomeFirstResponder];
    }
    else {
        [_hint setDidCloseTarget:self selector:@selector(handleHintClosed)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_inputView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - private

- (void)handleHintClosed
{
    [_inputView becomeFirstResponder];
}

- (void)rematchText
{
    NSArray *tContents = [_inputView.text componentsSeparatedByString:SMSeparator];
    NSMutableArray *mutContents = [NSMutableArray arrayWithCapacity:[tContents count]];
    [tContents enumerateObjectsUsingBlock:^(NSString *content, NSUInteger idx, BOOL *stop) {
        NSString *pureContent = content;
        NSRange lineNumberRange = [content rangeOfString:@"."];
        if (lineNumberRange.length > 0) {
            if (NSMaxRange(lineNumberRange) < 4) {  // 此判断在 index < 999 时有效
                if (NSMaxRange(lineNumberRange) < content.length) {
                    NSString *nextLetter = [content substringWithRange:NSMakeRange(NSMaxRange(lineNumberRange), 1)];
                    if ([nextLetter isEqualToString:@" "]) {
                        pureContent = [content substringFromIndex:NSMaxRange(lineNumberRange) + 1];
                    }
                    else {
                        pureContent = [content substringFromIndex:NSMaxRange(lineNumberRange)];
                    }
                }
                else {
                    pureContent = @"";
                }
            }
        }
        
        if (idx < [tContents count] - 1) {
            pureContent = [pureContent stringByAppendingString:SMSeparator];
        }
        [mutContents addObject:pureContent];
    }];
    
    NSArray *contents = [mutContents copy];
    
    if ([contents count] == [_todos count]) {
        [_todos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
            todo.content = [contents objectAtIndex:idx];
        }];
    }
    else if ([contents count] > [_todos count]) {
        [contents enumerateObjectsUsingBlock:^(NSString *content, NSUInteger idx, BOOL *stop) {
            NSRange insertRange = NSMakeRange(NSMaxRange(_changeTextIndexRange),
                                              _appendTextIndexRange.length - _changeTextIndexRange.length);
            if (idx < insertRange.location) {
                TodoData *todo = [_todos objectAtIndex:idx];
                todo.content = content;
            }
            else if (idx >= insertRange.location && idx < NSMaxRange(insertRange)) {
                TodoData *insertTodo = [_dailyDo insertNewTodoAtIndex:idx];
                insertTodo.content = content;
            }
            else {
                TodoData *todo = [_todos objectAtIndex:idx - insertRange.length];
                todo.content = content;
            }
        }];
    }
    else {
        [_todos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
            NSRange removeRange = NSMakeRange(NSMaxRange(_appendTextIndexRange),
                                              _changeTextIndexRange.length - _appendTextIndexRange.length);
            if (idx < removeRange.location) {
                todo.content = [contents objectAtIndex:idx];
            }
            else if (idx >= removeRange.location && idx < NSMaxRange(removeRange)) {
                [_dailyDo removeTodos:@[todo]];
            }
            else {
                todo.content = [contents objectAtIndex:idx - removeRange.length];
            }
        }];
    }
    [[KMModelManager sharedManager] saveContext:nil];
}

- (void)refreshText
{
    self.todos = [[_dailyDo todosSortedByIndex] mutableCopy];
    NSString *text = [_dailyDo todosTextWithLineNumber:YES];
    if ([text length] == 0 || [[text substringWithRange:NSMakeRange([text length] - 1, 1)] isEqualToString:SMSeparator]) {
        int index = [_todos count];
        TodoData *todo = [_dailyDo insertNewTodoAtIndex:index];
        todo.content = @"";
        [[KMModelManager sharedManager] saveContext:nil];
        
        [_todos addObject:todo];
        text = [NSString stringWithFormat:@"%@%d. ", text, index + 1];
    }
    
    _inputView.text = text;
    
    if ([_inputView.text length] <= 3) {
        NSString *tString = [[[DailyDoManager sharedManager] configurationsForDoName:_dailyDo.addon.dailyDoName] objectForKey:kConfigurationPlaceHolder];
        _inputView.placeholder = NSLocalizedString(tString, nil);
    }
    else {
        _inputView.placeholder = nil;
    }
}

- (void)updateInputHelperWords
{
    NSArray *words = [[DailyDoManager sharedManager] inputHelperWordsForDoName:_dailyDo.addon.dailyDoName];
    
    CGRect tFrame = _inputHelperBar.frame;
    
    if ([words count] > 0) {
        tFrame.size.height = 40.f;
        _inputHelperBar.hidden = NO;
        
        NSMutableArray *mutItems = [NSMutableArray arrayWithCapacity:5];
        [mutItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        [words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
            ToolbarButton *tButton = [ToolbarButton buttonWithType:UIButtonTypeCustom];
            [tButton addTarget:self action:@selector(helperWordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            tButton.tag = HelperWordButtonTagPrefix + idx;
            [tButton setTitle:word forState:UIControlStateNormal];
            tButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.f];
            [tButton sizeToFit];
            setFrameWithWidth(tButton, SSWidth(tButton) + 20.f);
            
            UIBarButtonItem *tItem = [[UIBarButtonItem alloc] initWithCustomView:tButton];
            [mutItems addObject:tItem];
        }];
        
        _inputHelperBar.items = [mutItems copy];
    }
    else {
        tFrame.size.height = 0.f;
        _inputHelperBar.hidden = YES;
    }
    
    _inputHelperBar.frame = tFrame;
}

#pragma mark - Actions

- (void)helperWordButtonClicked:(id)sender
{
    ToolbarButton *tButton = (ToolbarButton *)sender;
    NSArray *words = [[DailyDoManager sharedManager] inputHelperWordsForDoName:_dailyDo.addon.dailyDoName];
    
    int idx = tButton.tag - HelperWordButtonTagPrefix;
    if (idx < [words count]) {
        NSString *word = [words objectAtIndex:idx];
        
        if ([self textView:_inputView shouldChangeTextInRange:_inputView.selectedRange replacementText:word]) {
            _inputView.text = [_inputView.text stringByAppendingString:word];
            [self textViewDidChange:_inputView];
        }
    }
}

- (IBAction)cancel:(id)sender
{
//    [_dailyDo recoveryToSnapshot];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [_dailyDo removeBlankTodos];
    [_dailyDo detectTodos];
}

#pragma mark - TextView Methods

- (NSUInteger)indexForRange:(NSRange)range
{
    __block NSUInteger ret = 0;
    __block NSRange compareRange = NSMakeRange(0, 0);
    
    [_todos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        int length = [todo.content length];
        length += [todo lineNumberStringLength];
        
        compareRange = NSMakeRange(NSMaxRange(compareRange), length);
        if (range.location >= compareRange.location && NSMaxRange(range) <= NSMaxRange(compareRange)) {
            ret = idx;
            *stop = YES;
        }
    }];
    
    if (NSMaxRange(range) > NSMaxRange(compareRange)) {
        return [_todos count];
    }
    else {
        return ret;
    }
}

- (BOOL)availableRange:(NSRange)range
{
    // 不允许单独删除换行符
    if ([[_inputView.text substringWithRange:range] isEqualToString:SMSeparator]) {
        return NO;
    }
    
    NSUInteger index = [self indexForRange:range];
    if (index >= [_todos count]) {
        return NO;
    }
    
    TodoData *tmpTodo = [_todos objectAtIndex:index];
    NSUInteger beforeIndexLength = [_dailyDo todoTextLengthFromIndex:0 beforeIndex:index autoNumber:YES];
    
    NSRange unavailabelRange;
    if (range.length > 0) {
        // line number without space is unavailable range when remove text
        unavailabelRange = NSMakeRange(beforeIndexLength, [tmpTodo lineNumberStringLength] - 1);
    }
    else {
        // line number containing space is unavailable range when only append text
        unavailabelRange = NSMakeRange(beforeIndexLength, [tmpTodo lineNumberStringLength]);
    }
    
    NSRange intersectionRange = NSIntersectionRange(range, unavailabelRange);
    if (NSMaxRange(intersectionRange) > 0) {
        if ((range).length < unavailabelRange.length) {
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        return YES;
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView markedRange].length > 0) {
        return YES;
    }
    
    NSUInteger beginIndex = [self indexForRange:range];
    
    NSUInteger changeEndIndex = [self indexForRange:NSMakeRange(NSMaxRange(range) - 1, 1)];
    _changeTextIndexRange = NSMakeRange(beginIndex, changeEndIndex - beginIndex);
    
    NSArray *appendContents = [text componentsSeparatedByString:SMSeparator];
    _appendTextIndexRange = NSMakeRange(beginIndex, [appendContents count] - 1);
    
    BOOL availabel = [self availableRange:range];
    return availabel;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView markedRange].length > 0) {
        return;
    }
    
    NSRange selectRange = textView.selectedRange;
    
    [self rematchText];
    [self refreshText];
    
    NSUInteger index = [self indexForRange:NSMakeRange(NSMaxRange(selectRange) + 1, 0)];
    if (index < [_todos count]) {
        TodoData *tTodo = [_todos objectAtIndex:index];
        NSRange lineNumberRange = [textView.text rangeOfString:[tTodo lineNumberString]];
        if (selectRange.location >= lineNumberRange.location && selectRange.location < NSMaxRange(lineNumberRange)) {
            selectRange.location = NSMaxRange(lineNumberRange);
        }
    }
    textView.selectedRange = selectRange;
}

@end
