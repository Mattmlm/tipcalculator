//
//  ViewController.m
//  Tip Calculator
//
//  Created by admin on 8/13/15.
//  Copyright (c) 2015 mattmo. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "TipCalculatedCollectionViewCell.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField * billTotalField;
@property (nonatomic, weak) IBOutlet UIButton * clearButton;
@property (nonatomic, weak) IBOutlet UIButton * settingsButton;
@property (nonatomic, weak) IBOutlet UICollectionView * tipCalculatedCollectionView;

@property BOOL isDefaultLoaded;

@end

@implementation ViewController

#pragma mark - UIViewController cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.billTotalField.delegate = self;
    self.tipCalculatedCollectionView.delegate = self;
    self.tipCalculatedCollectionView.dataSource = self;
    UINib *tipCellNib = [UINib nibWithNibName:@"TipCalculatedCollectionViewCell" bundle:nil];
    [self.tipCalculatedCollectionView registerNib:tipCellNib forCellWithReuseIdentifier:@"tipCell"];
    
    [self.navigationController setNavigationBarHidden:YES];

    // Make keyboard show
    [self.billTotalField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self loadDefaultTip];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate protocol methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text containsString:@"."]) {
        
    }
    if ([string isEqualToString:@"."] && [textField.text containsString:@"."]) {
        return NO;
    } else {
        [self updateTipCalculations:[textField.text stringByReplacingCharactersInRange:range withString:string]];
        return YES;
    }
}

#pragma mark - UICollectionViewDelegate protocol methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tipCell" forIndexPath:indexPath];
    TipCalculatedCollectionViewCell * tipCell = nil;
    if ([cell isKindOfClass:[TipCalculatedCollectionViewCell class]]) {
        tipCell = (TipCalculatedCollectionViewCell *) cell;
    }
    if(tipCell) {
        tipCell.tipPercentage = [NSNumber numberWithInteger:indexPath.row];
        [tipCell updateCell:[self.billTotalField.text doubleValue]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 3.5, self.tipCalculatedCollectionView.frame.size.height);
}

#pragma mark - IBAction

- (IBAction)clearButtonPressed:(id)sender {
    [self.billTotalField setText:@""];
    [self updateTipCalculations:@""];
}

#pragma mark - Helpers

- (void) recordLastTipPercentageSettings {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.billTotalField.text forKey:kLastBillTotal];
    
    [defaults setObject:[NSNumber numberWithInteger:[self centerTipPercentageIndexPath].row] forKey:kLastTipPercentage];
}

- (NSIndexPath *) centerTipPercentageIndexPath {
    NSArray * visibleCells = [self.tipCalculatedCollectionView visibleCells];
    CGFloat centerX = self.tipCalculatedCollectionView.contentOffset.x + [UIScreen mainScreen].bounds.size.width/2;
    CGRect centerRect = CGRectMake(centerX, self.tipCalculatedCollectionView.frame.size.height / 2, 1, 1);
    for (UICollectionViewCell * cell in visibleCells) {
        BOOL isCellCenter = CGRectIntersectsRect(centerRect, cell.frame);
        if (isCellCenter) {
            return [self.tipCalculatedCollectionView indexPathForCell:cell];
        }
    }
    return nil;
}

- (void) updateTipCalculations:(NSString *)newBillValue {
    NSArray * cellsToUpdate = [self.tipCalculatedCollectionView visibleCells];
    for (UICollectionViewCell * cell in cellsToUpdate) {
        if ([cell isKindOfClass:[TipCalculatedCollectionViewCell class]]) {
            TipCalculatedCollectionViewCell * tipCell = (TipCalculatedCollectionViewCell *)cell;
            [tipCell updateCell:[newBillValue doubleValue]];
        }
    }
}

- (void) loadDefaultTip {
    if (!self.isDefaultLoaded) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        NSDate * lastDate = (NSDate *)[defaults objectForKey:kLastCloseDate];
        NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:lastDate];
        
        NSIndexPath * tipPercentageToScrollToIndexPath = nil;
        if (timeDiff > 600) {
            tipPercentageToScrollToIndexPath = [NSIndexPath indexPathForRow:[defaults integerForKey:kTipDefaultPercentage] inSection:0];
            [self.tipCalculatedCollectionView scrollToItemAtIndexPath:tipPercentageToScrollToIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        } else {
            tipPercentageToScrollToIndexPath = [NSIndexPath indexPathForRow:[defaults integerForKey:kLastTipPercentage] inSection:0];
            [self.tipCalculatedCollectionView scrollToItemAtIndexPath:tipPercentageToScrollToIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            [self.billTotalField setText:[defaults objectForKey:kLastBillTotal]];
        }
        self.isDefaultLoaded = YES;
    }
}

@end
