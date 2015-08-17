//
//  TipCalculatedCollectionViewCell.m
//  Tip Calculator
//
//  Created by admin on 8/13/15.
//  Copyright (c) 2015 mattmo. All rights reserved.
//

#import "TipCalculatedCollectionViewCell.h"

@interface TipCalculatedCollectionViewCell()

@property (nonatomic, weak) IBOutlet UILabel * currencyTipLabel;
@property (nonatomic, weak) IBOutlet UILabel * currencyTotalLabel;
@property (nonatomic, weak) IBOutlet UILabel * totalCalculatedLabel;
@property (nonatomic, weak) IBOutlet UILabel * tipCalculatedLabel;
@property (nonatomic, weak) IBOutlet UILabel * tipPercentageLabel;

@end

@implementation TipCalculatedCollectionViewCell

static NSString * const nibName = @"TipCalculatedCollectionViewCell";
static NSString * const reuseIdentifier = @"tipCell";

+ (NSString *)nibName {
    return nibName;
}

+ (NSString *)reuseIdentifier {
    return reuseIdentifier;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    
}

- (void)updateCell:(double)billTotal withSplit:(int)numberOfPeople {
    double tipCalculated = [self.tipPercentage doubleValue] * 0.01 * billTotal / numberOfPeople;
    double totalCalculated = ([self.tipPercentage doubleValue] * 0.01 + 1) * billTotal / numberOfPeople;
    [self.currencyTipLabel setText:@"+ $"];
    [self.currencyTotalLabel setText:@"$"];
    [self.tipPercentageLabel setText:[NSString stringWithFormat:@"%@%%", self.tipPercentage]];
    [self.tipCalculatedLabel setText:[NSString stringWithFormat:@"%0.02f,", tipCalculated]];
    [self.totalCalculatedLabel setText:[NSString stringWithFormat:@"%0.02f", totalCalculated]];
}

@end