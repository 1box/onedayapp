//
//  KMFrameUtilities.h
//  Drawus
//
//  Created by Tianhang Yu on 12-4-3.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#ifndef KMFrameUtilities_h
#define KMFrameUtilities_h

static CGSize s_screenSize;
static inline CGSize screenSize() {
    if(CGSizeEqualToSize(s_screenSize, CGSizeZero)) {
        s_screenSize = [[UIScreen mainScreen] bounds].size;
    }
    
    return s_screenSize;
}

static inline CGRect rectWithPadding (CGRect rect, CGFloat padding) {    
    
    return CGRectMake(rect.origin.x + padding,
                      rect.origin.y + padding,
                      rect.size.width - 2*padding,
                      rect.size.height - 2*padding);
}

static inline CGRect rectWithSizePadding (CGRect rect, CGFloat padding_top, CGFloat padding_left) {
    
    return CGRectMake(rect.origin.x + padding_left, 
                      rect.origin.y + padding_top, 
                      rect.size.width - 2*padding_left, 
                      rect.size.height - 2*padding_top);
}

#ifndef SSMinX
#define SSMinX(view) CGRectGetMinX(view.frame)
#endif

#ifndef SSMinY
#define SSMinY(view) CGRectGetMinY(view.frame)
#endif

#ifndef SSMaxX
#define SSMaxX(view) CGRectGetMaxX(view.frame)
#endif

#ifndef SSMaxY
#define SSMaxY(view) CGRectGetMaxY(view.frame)
#endif

#ifndef SSWidth
#define SSWidth(view) view.frame.size.width
#endif

#ifndef SSHeight
#define SSHeight(view) view.frame.size.height
#endif

static inline void setAutoresizingMaskFlexibleWidthAndHeight(UIView *view){
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

static inline void setFrameWithX(UIView *view, float originX){
    CGRect rect = view.frame;
    rect.origin.x = originX;
    view.frame = rect;
}

static inline void setFrameWithY(UIView *view, float originY){
    CGRect rect = view.frame;
    rect.origin.y = originY;
    view.frame = rect;
}

static inline void setFrameWithOrigin(UIView *view, float originX, float originY){
    CGRect rect = view.frame;
    rect.origin.x = originX;
    rect.origin.y = originY;
    view.frame = rect;
}

static inline void setFrameWithWidth(UIView *view, float width){
    CGRect rect = view.frame;
    rect.size.width = width;
    view.frame = rect;
}

static inline void setFrameWithHeight(UIView *view, float height){
    CGRect rect = view.frame;
    rect.size.height = height;
    view.frame = rect;
}

static inline void setFrameWithSize(UIView *view, float width, float height){
    CGRect rect = view.frame;
    rect.size.width = width;
    rect.size.height = height;
    view.frame = rect;
}

static inline void setCenterWithX(UIView *view, float x){
    view.center = CGPointMake(x, view.center.y);
}

static inline void setCenterWithY(UIView *view, float y){
    view.center = CGPointMake(view.center.x, y);
}

#endif
