//
//  UIColor+UIColorAddtions.h
//  Drawus
//
//  Created by Tianhang Yu on 12-3-23.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColorAddtions)

/**
 * @brief 由一个以＃开头的16进至的色彩字串产生一个UIColor类实例，静态方法
 * @param ＃开头的色彩字符串
 * @return 返回UIColor类，autorelease的。
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
