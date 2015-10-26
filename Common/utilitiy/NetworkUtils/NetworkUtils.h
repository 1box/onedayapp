//
//  NetworkUtils.h
//  Drawus
//
//  Created by Tianhang Yu on 12-3-30.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

BOOL KMNetworkConnected(void);		// 当前网络是否联通的
BOOL KMNetworkWiFiConnected(void);	// 是否是通过wifi链接的
BOOL SSNetowrkWWANConnected(void);	// 是否是通过蜂窝网链接的

/**
 *@brief 两个特殊函数，这个将有queue使用
 *       注意回调函数要线程安全处理。
 */
void KMNetworkStartNotifier(void);
void KMNetworkStopNotifier(void);
