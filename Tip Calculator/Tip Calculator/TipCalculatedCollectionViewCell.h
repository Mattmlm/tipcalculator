//
//  TipCalculatedCollectionViewCell.h
//  Tip Calculator
//
//  Created by admin on 8/13/15.
//  Copyright (c) 2015 mattmo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipCalculatedCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSNumber * tipPercentage;

- (void)updateCell:(double)billTotal;

@end
