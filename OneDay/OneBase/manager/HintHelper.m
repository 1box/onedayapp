//
//  HintHelper.m
//  HintMakerExample
//
//  Created by Eric McConkie on 3/16/12.

#import "HintHelper.h"

#define kHintDialogFramesKey @"kHintDialogFramesKey"
#define kHintDialogFrames568Key @"kHintDialogFramesKey-568"
#define kHintDialogMessageKey @"kHintDialogMessageKey"
#define kHintDialogImageKey @"kHintDialogImageKey"

@interface HintHelper () <EMHintDelegate> {
    EMHint *_modalState;
    __weak UIViewController *_vc;
    NSString *_prefix;
    NSUInteger _offset;
    
    __weak id _closeTarget;
    SEL _closeSelector;
}
@property (nonatomic, readwrite) BOOL shown;
@property (nonatomic) NSArray *dialogs;
@end

@implementation HintHelper

- (id)initWithViewController:(UIViewController *)vc dialogsPathPrefix:(NSString *)prefix
{
    self = [super init];
    if (self) {
        if (!(!prefix || KMEmptyString(prefix) || hasHintForKey(prefix) || [KMCommon isPadDevice])) {
            
            NSString *fileName = nil;
            if ([prefix hasSuffix:[KMCommon versionName]]) {
                fileName = [NSString stringWithFormat:@"%@HintDialogs", [prefix substringToIndex:[prefix length] - [[KMCommon versionName] length] - 1]];   // substract 1 for '_'
            }
            else {
                fileName =  [NSString stringWithFormat:@"%@HintDialogs", prefix];
            }
            NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
            NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
            self.dialogs = [root objectForKey:@"HintDialogs"];
            
            if (_dialogs) {
                _prefix = [prefix copy];
                _vc = vc;
                _offset = 0;
                
                _modalState = [[EMHint alloc] init];
                [_modalState setHintDelegate:self];
            }
        }
    }
    return self;
}

#pragma mark - public

- (void)setDidCloseTarget:(id)target selector:(SEL)selector
{
    _closeTarget = target;
    _closeSelector = selector;
}

- (BOOL)show
{
    if ([_dialogs count] > 0) {
        _shown = YES;
        [self loadNext];
    }
    return [_dialogs count] > 0;
}

#pragma mark - private

- (BOOL)loadNext
{
    if (_offset < [_dialogs count]) {
        NSDictionary *dialog = [_dialogs objectAtIndex:_offset];
        [_modalState presentModalMessage:[dialog objectForKey:kHintDialogMessageKey] where:_vc.navigationController.view];
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - ENHintDelegate

- (BOOL)hintStateShouldCloseIfPermitted:(id)hintState
{
    _offset ++;
    return ![self loadNext];
}

- (NSArray*)hintStateRectsToHint:(id)hintState
{
    NSString *frameKey = nil;
    if ([KMCommon is568Screen]) {
        frameKey = kHintDialogFrames568Key;
    }
    else {
        frameKey = kHintDialogFramesKey;
    }
    NSArray *frameStrings = [[_dialogs objectAtIndex:_offset] objectForKey:frameKey];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[frameStrings count]];
    
    [frameStrings enumerateObjectsUsingBlock:^(NSString *tString, NSUInteger idx, BOOL *stop) {
        CGRect tFrame = CGRectFromString(tString);
        [ret addObject:[NSValue valueWithCGRect:tFrame]];
    }];
    return ret;
}

- (UIView*)hintStateViewForDialog:(id)hintState
{
    NSString *imageName = [[_dialogs objectAtIndex:_offset] objectForKey:kHintDialogImageKey];
    
    UIImageView *tImageView = nil;
    if (imageName && !KMEmptyString(imageName)) {
        tImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    }
    return tImageView;
}

- (void)hintStateWillClose:(id)hintState
{
    setHasHintForKey(_prefix);
}

- (void)hintStateDidClose:(id)hintState
{
    _shown = NO;
    
    if (_closeTarget && [_closeTarget respondsToSelector:_closeSelector]) {
        NSMethodSignature *ms = [_closeTarget methodSignatureForSelector:_closeSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:ms];
        [invocation setTarget:_closeTarget];
        [invocation setSelector:_closeSelector];
        [invocation invoke];
    }
}
@end
