//
//  HintHelper.h
//  HintMakerExample
//
//  Created by Eric McConkie on 3/16/12.

#import <Foundation/Foundation.h>
#import "EMHint.h"

#define kHasHintsUserDefaultKey @"kHasHintsUserDefaultKey"
static inline bool hasHintForKey(NSString *hintKey) {
    NSDictionary *hasHintsDict = [[NSUserDefaults standardUserDefaults] objectForKey:kHasHintsUserDefaultKey];
    if (!hasHintsDict) {
        hasHintsDict = [NSDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:hasHintsDict forKey:kHasHintsUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [[hasHintsDict objectForKey:hintKey] boolValue];
}

static inline void setHasHintForKey(NSString *hintKey) {
    NSMutableDictionary *hasHintsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:kHasHintsUserDefaultKey] mutableCopy];
    if (!hasHintsDict) {
        hasHintsDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [hasHintsDict setObject:@YES forKey:hintKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:[hasHintsDict copy] forKey:kHasHintsUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline void resetHasHintForKey(NSString *hintKey) {
    NSMutableDictionary *hasHintsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:kHasHintsUserDefaultKey] mutableCopy];
    if (!hasHintsDict) {
        hasHintsDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [hasHintsDict setObject:@NO forKey:hintKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:[hasHintsDict copy] forKey:kHasHintsUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@interface HintHelper : NSObject

@property (nonatomic, readonly) BOOL shown;

- (id)initWithViewController:(UIViewController *)vc dialogsPathPrefix:(NSString *)prefix;
- (void)setDidCloseTarget:(id)target selector:(SEL)selector;
- (BOOL)show;
@end
