//
//  Constants.h
//  Tip Calculator
//
//  Created by admin on 8/13/15.
//  Copyright (c) 2015 mattmo. All rights reserved.
//

#ifndef Tip_Calculator_Constants_h
#define Tip_Calculator_Constants_h

/*
 *Colors
 */

#define kMainColorGreen 0x73F6C7
#define kBackgroundColorGreen2 0x61C882

// HELPER METHODS
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/* 
 * User Default Keys
 */

// Default settings
#define kTipDefaultPercentage @"tipPercentageDefault"

// Record Settings when app is killed
#define kLastCloseDate @"lastCloseDate"
#define kLastBillTotal @"lastBillTotal"
#define kLastTipPercentage @"lastTipPercentage"
#define kLastBillSplitNumber @"lastBillSplitNumber"

#endif
