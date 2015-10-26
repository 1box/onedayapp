//
//  KMMathUtilities.h
//  OneDay
//
//  Created by Kimimaro on 13-5-13.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#ifndef OneDay_KMMathUtilities_h
#define OneDay_KMMathUtilities_h

static inline int roundNumberFloor(float seed) {
    
    int count = 0;
    while (abs(seed) > 10) {
        seed /= 10;
        count ++;
    }
    
    int ret = floorf(seed);
    while (count > 0) {
        ret *= 10;
        count --;
    }
    
    return ret;
}

static inline int roundNumberCeil(float seed) {
    
    int count = 0;
    while (abs(seed) > 10) {
        seed /= 10;
        count ++;
    }
    
    int ret = floorf(seed);
    while (count > 0) {
        ret *= 10;
        count --;
    }
    
    return ret;
}

#endif
