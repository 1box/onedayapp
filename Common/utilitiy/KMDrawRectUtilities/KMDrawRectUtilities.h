//
//  KMDrawRectUtilities.h
//  Drawus
//
//  Created by Tianhang Yu on 12-4-3.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 清空
static inline void clearDraw (CGContextRef context, CGRect rect, UIColor *backgroundColor)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColorWithColor(context, backgroundColor.CGColor);
    CGContextSetFillColorSpace(context, space);
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);

    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));

    CGContextClosePath(context);

    CGContextDrawPath(context, kCGPathFillStroke);
}

// 渐变背景
static inline void drawGradient (CGContextRef context, CGRect rect, CGFloat *components, size_t count) 
{
	CGGradientRef myGradient;
	CGColorSpaceRef myColorSpace;
    
	myColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat l1[] = {0.0, 0.1, 0.5, 1.0};
    CGFloat l2[] = {0.0, 0.1, 1.0};
    
    CGFloat *locations = NULL;
    
    if (count == 4)
    {
        locations = l1;
    }
    else
    {
        locations = l2;
    }
    
    myGradient = CGGradientCreateWithColorComponents(myColorSpace, 
                                                     components,
                                                     locations, 
                                                     count);
    
//    CFArrayRef *colorArray = CFArrayCreate(<#CFAllocatorRef allocator#>, <#const void **values#>, <#CFIndex numValues#>, <#const CFArrayCallBacks *callBacks#>)
//    CGGradientCreateWithColors(myColorSpace, <#CFArrayRef colors#>, <#const CGFloat *locations#>)
    
	CGPoint startPoint, endPoint;
    startPoint.x = CGRectGetMaxX(rect) / 2;
    startPoint.y = 0;
    endPoint.x = CGRectGetMaxX(rect) / 2;
    endPoint.y = CGRectGetMaxY(rect);
    
    CGContextDrawLinearGradient(context, myGradient, startPoint, endPoint, 0);
    
    CGColorSpaceRelease(myColorSpace);
    CGGradientRelease(myGradient);
}

// 在指定位置加入圆角
typedef enum {
	CORNER_TYPE_TOP_LEFT,
	CORNER_TYPE_TOP_RIGHT,
	CORNER_TYPE_BOTTOM_LEFT,
	CORNER_TYPE_BOTTOM_RIGHT
} CORNER_TYPE;

static inline void drawRoundCorner (CGContextRef context, CGRect rect, CGFloat radius, CORNER_TYPE cornerType, UIColor *cornerColor)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
	CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColorWithColor(context, cornerColor.CGColor);
    CGContextSetFillColorSpace(context, space);
    CGContextSetFillColorWithColor(context, cornerColor.CGColor);
    
    CGContextSetLineWidth(context, 0.1f);
    
    CGPoint cornerPoint = CGPointZero;
    if (cornerType == CORNER_TYPE_TOP_LEFT)
    {
    	cornerPoint = CGPointMake(0, 0);
        
    	CGContextMoveToPoint(context, cornerPoint.x + radius, cornerPoint.y);
    	CGContextAddLineToPoint(context, cornerPoint.x, cornerPoint.y);
    	CGContextAddLineToPoint(context, cornerPoint.x, cornerPoint.y + radius);
    	CGContextAddArcToPoint(context, cornerPoint.x, cornerPoint.y, cornerPoint.x + radius, cornerPoint.y, radius);	
    }
    else if (cornerType == CORNER_TYPE_TOP_RIGHT)
    {
    	cornerPoint = CGPointMake(rect.size.width, 0);
        
    	CGContextMoveToPoint(context, cornerPoint.x, cornerPoint.y + radius);
    	CGContextAddLineToPoint(context, cornerPoint.x, cornerPoint.y);
    	CGContextAddLineToPoint(context, cornerPoint.x - radius, cornerPoint.y);
    	CGContextAddArcToPoint(context, cornerPoint.x, cornerPoint.y, cornerPoint.x, cornerPoint.y + radius, radius);	
    }
    else if (cornerType == CORNER_TYPE_BOTTOM_RIGHT)
    {
    	cornerPoint = CGPointMake(0, 0);
        
    	CGContextMoveToPoint(context, cornerPoint.x + radius, cornerPoint.y);
    	CGContextAddLineToPoint(context, cornerPoint.x, cornerPoint.y);
    	CGContextAddLineToPoint(context, cornerPoint.x, cornerPoint.y + radius);
    	CGContextAddArcToPoint(context, cornerPoint.x, cornerPoint.y, cornerPoint.x + radius, cornerPoint.y, radius);	
    }
    else if (cornerType == CORNER_TYPE_BOTTOM_LEFT)
    {
    	cornerPoint = CGPointMake(0, 0);
        
    	CGContextMoveToPoint(context, cornerPoint.x, cornerPoint.y - radius);
    	CGContextAddLineToPoint(context, cornerPoint.x, cornerPoint.y);
    	CGContextAddLineToPoint(context, cornerPoint.x + radius, cornerPoint.y);
    	CGContextAddArcToPoint(context, cornerPoint.x, cornerPoint.y, cornerPoint.x, cornerPoint.y - radius, radius);	
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGColorSpaceRelease(space);
}

// 圆角背景
static inline void drawRoundRect (CGContextRef context, CGRect rect, CGFloat radius, UIColor *bgColor)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
	CGContextSetStrokeColorSpace(context, space);
	CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetFillColorSpace(context, space);
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    
    CGContextSetLineWidth(context, 0.1f);
    
    CGFloat minX = CGRectGetMinX(rect), maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect), maxY = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minX, rect.origin.x + radius);
    
    CGContextAddArcToPoint(context, minX, minY, rect.origin.x + radius, minY, radius);
    CGContextAddArcToPoint(context, maxX, minY, maxX, rect.origin.y + radius, radius);
    CGContextAddArcToPoint(context, maxX, maxY, rect.origin.x + radius, maxY, radius);
    CGContextAddArcToPoint(context, minX, maxY, minX, rect.origin.y + radius, radius);
    
	CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFill);
    
    CGColorSpaceRelease(space);
}

static inline void drawBorderRoundRect (CGContextRef context, CGRect rect, CGFloat radius, UIColor *bgColor, UIColor *borderColor, CGFloat borderWidth)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetFillColorSpace(context, space);
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    
    CGContextSetLineWidth(context, borderWidth);
    
    CGFloat minX = CGRectGetMinX(rect), maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect), maxY = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minX, rect.origin.x + radius);
    
    CGContextAddArcToPoint(context, minX, minY, rect.origin.x + radius, minY, radius);
    CGContextAddArcToPoint(context, maxX, minY, maxX, rect.origin.y + radius, radius);
    CGContextAddArcToPoint(context, maxX, maxY, rect.origin.x + radius, maxY, radius);
    CGContextAddArcToPoint(context, minX, maxY, minX, rect.origin.y + radius, radius);
    
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFill);
    
    CGColorSpaceRelease(space);
}

// 关闭按钮
static inline void drawCloseButton (CGContextRef context, CGRect rect, UIColor *strokeColor, UIColor *backgroundColor)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetFillColorSpace(context, space);
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);

    CGContextSetLineWidth(context, 2.f);

    CGFloat radius = (rect.size.width - 4) / 2;

    CGFloat minX = CGRectGetMinX(rect) + 2, midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect) - 2;
    CGFloat minY = CGRectGetMinY(rect) + 2, midY = CGRectGetMidY(rect), maxY = CGRectGetMaxY(rect) - 2;

    CGContextMoveToPoint(context, minX, midY);

    CGContextAddArcToPoint(context, minX, minY, midX, minY, radius);
    CGContextAddArcToPoint(context, maxX, minY, maxX, midY, radius);
    CGContextAddArcToPoint(context, maxX, maxY, midX, maxY, radius);
    CGContextAddArcToPoint(context, minX, maxY, minX, midY, radius);

    CGContextClosePath(context);

    CGContextDrawPath(context, kCGPathFillStroke);
    
    // X in center
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2.f);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);

    CGFloat centerRect = 10;
    
    CGFloat startX = rect.origin.x + (rect.size.width - centerRect) / 2; 
    CGFloat startY = rect.origin.y + (rect.size.width - centerRect) / 2;
    CGFloat endX = startX + centerRect;
    CGFloat endY = startY + centerRect;

    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);

    startX = rect.origin.x + (rect.size.width + centerRect) / 2; 
    startY = rect.origin.y + (rect.size.width - centerRect) / 2;
    endX = startX - centerRect;
    endY = startY + centerRect;

    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);

    CGColorSpaceRelease(space);
}

// 画笔按钮
static inline void drawBrush (CGContextRef context, CGRect rect, UIColor *brushColor)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorSpace(context, space);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);

    CGContextSetLineWidth(context, 0.1f);
    CGContextSetLineCap(context, kCGLineCapRound);

    CGFloat startX = rect.origin.x + rect.size.width * 3/4;
    CGFloat startY = rect.origin.y;

    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height * 1/4);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * 17/32, rect.origin.y + rect.size.height * 23/32);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * 9/32, rect.origin.y + rect.size.height * 15/32);
    CGContextAddLineToPoint(context, startX, startY);

    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);

    CGContextSetStrokeColorWithColor(context, brushColor.CGColor);
    CGContextSetFillColorWithColor(context, brushColor.CGColor);

    startX = rect.origin.x + rect.size.width * 7/16;
    startY = rect.origin.y + rect.size.height * 13/16;

    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * 1/8, rect.origin.y + rect.size.height * 7/8);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * 3/16, rect.origin.y + rect.size.height * 9/16);
    CGContextAddLineToPoint(context, startX, startY);

    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);

    CGColorSpaceRelease(space);
}

// 橡皮按钮
static inline void drawEraser (CGContextRef context, CGRect rect)
{
    // (0, 3/4)   (1/2, 3/4) (1/2, 1/2) (0, 1/2)
    // (0, 1/2)   (5/8, 0)   (1, 0)     (1/2, 1/2)
    // (1/2, 1/2) (1/2, 3/4) (1, 1/8)   (1, 0)

    UIColor *lightColor = [UIColor colorWithHexString:@"9d927d"];
    UIColor *midColor   = [UIColor colorWithHexString:@"d0be8c"];
    UIColor *darkColor  = [UIColor colorWithHexString:@"a08c43"];

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 0.1f);

    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColorWithColor(context, lightColor.CGColor);
    CGContextSetFillColorSpace(context, space);
    CGContextSetFillColorWithColor(context, lightColor.CGColor);

    CGFloat offsetX = 0;
    CGFloat offsetY = 0.125;
    
    CGFloat pointX[] = {
        0, 0.5, 0.5, 0,
        0, 0.625, 1, 0.5,
        0.5, 0.5, 1, 1
    };
    
    CGFloat pointY[] = {
        0.75, 0.75, 0.5, 0.5,
        0.5, 0, 0, 0.5,
        0.5, 0.75, 0.125, 0
    };

    int pointCount = 12;
    
    CGFloat startX = 0.f;
    CGFloat startY = 0.f;

    for (int i = 0; i < pointCount; ++i)
    {
        if (i % 4 == 0)
        {
            startX = rect.origin.x + rect.size.width * (pointX[i] + offsetX);
            startY = rect.origin.y + rect.size.height * (pointY[i] + offsetY);

            CGContextMoveToPoint(context, startX, startY);
        }
        else if (i % 4 != 3)
        {
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * (pointX[i] + offsetX), rect.origin.y + rect.size.height * (pointY[i] + offsetY));
        }
        else if (i % 4 == 3)
        {
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * (pointX[i] + offsetX), rect.origin.y + rect.size.height * (pointY[i] + offsetY));
            CGContextAddLineToPoint(context, startX, startY);

            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke);

            if (i / 4 != 2)
            {
                UIColor *tmpColor = nil;

                switch (i / 4) {
                    case 0:
                        tmpColor = midColor;
                    break;
                    case 1:
                        tmpColor = darkColor;
                    break;
                }            

                CGContextSetStrokeColorWithColor(context, tmpColor.CGColor);
                CGContextSetFillColorWithColor(context, tmpColor.CGColor);   
            }
        }
    }

    CGColorSpaceRelease(space);
}

// 斜纹背景
static inline void drawTwill (CGContextRef context, CGRect rect)
{
	CGColorSpaceRef myColorSpace;
    
	myColorSpace = CGColorSpaceCreateDeviceRGB();
    
	CGContextSetStrokeColorSpace(context, myColorSpace);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, 0.5);
	CGFloat components[] = {65/255.0, 74/255.0, 87/255.0, 1.0};
	CGContextSetStrokeColor(context, components);
    
	CGFloat startX = 0, startY = 0, endX = -40, endY = rect.size.height * 3/4;
	CGFloat gapX = 5.f;
    //	CGFloat gapY = 1.f;
    
	do {
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        CGContextStrokePath(context);
        
        startX += gapX;
        endX += gapX;
        
        //	   if (startX < rect.size.width)
        //	   {
        //	   		endY += gapY;
        //	   }
        //	   else
        //	   {
        //	   		endY -= gapY;
        //	   }
	} while (startX < rect.size.width + 40);
    
    CGColorSpaceRelease(myColorSpace);
}

@interface KMDrawRectUtilities : NSObject

@end
