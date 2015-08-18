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

@property (nonatomic, weak) IBOutlet UIButton * settingsButton;
@property (nonatomic, weak) IBOutlet UITextField * billTotalField;
@property (nonatomic, weak) IBOutlet UIButton * clearButton;
@property (nonatomic, weak) IBOutlet UIView * numberPeopleView;
@property (nonatomic, weak) IBOutlet UILabel * numberPeopleLabel;
@property (nonatomic, weak) IBOutlet UICollectionView * tipCalculatedCollectionView;

@property (nonatomic, strong) NSIndexPath * tipPercentageToScrollToIndexPath;

@end

@implementation ViewController

#pragma mark - UIViewController cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.billTotalField.delegate = self;
    self.tipCalculatedCollectionView.delegate = self;
    self.tipCalculatedCollectionView.dataSource = self;
    UINib *tipCellNib = [UINib nibWithNibName:[TipCalculatedCollectionViewCell nibName] bundle:nil];
    [self.tipCalculatedCollectionView registerNib:tipCellNib forCellWithReuseIdentifier:[TipCalculatedCollectionViewCell reuseIdentifier]];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNumberPeople:)];
    UISwipeGestureRecognizer * swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNumberPeople:)];
    UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNumberPeople:)];
    UISwipeGestureRecognizer * swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNumberPeople:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [self.numberPeopleView addGestureRecognizer:swipeRight];
    [self.numberPeopleView addGestureRecognizer:swipeUp];
    [self.numberPeopleView addGestureRecognizer:swipeLeft];
    [self.numberPeopleView addGestureRecognizer:swipeDown];
    
    // Make keyboard show
    [self.billTotalField becomeFirstResponder];
    
    self.tipPercentageToScrollToIndexPath = nil;
    [self loadLatestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.billTotalField becomeFirstResponder];
    [self loadDefaultData];
    [self clearLatestData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tipCalculatedCollectionView scrollToItemAtIndexPath:self.tipPercentageToScrollToIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
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
        [self updateTipCalculations:[textField.text stringByReplacingCharactersInRange:range withString:string] withSplit:self.numberPeopleLabel.text];
        return YES;
    }
}

#pragma mark - UICollectionViewDataSource protocol methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TipCalculatedCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    TipCalculatedCollectionViewCell * tipCell = nil;
    if ([cell isKindOfClass:[TipCalculatedCollectionViewCell class]]) {
        tipCell = (TipCalculatedCollectionViewCell *) cell;
    }
    if(tipCell) {
        tipCell.tipPercentage = [NSNumber numberWithInteger:indexPath.row];
        [tipCell updateCell:[self.billTotalField.text doubleValue] withSplit:[self.numberPeopleLabel.text intValue]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 2.0, self.tipCalculatedCollectionView.frame.size.height);
}

#pragma mark - IBAction

- (IBAction)clearButtonPressed:(id)sender {
    [self.billTotalField setText:@""];
    [self.numberPeopleLabel setText:@"1"];
    [self updateTipCalculations:@"" withSplit:@"1"];
}

- (void)handleSwipeNumberPeople:(UISwipeGestureRecognizer *)swipe {
    int numberOfPeople = [self.numberPeopleLabel.text intValue];
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight || swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        [self.numberPeopleLabel setText:[NSString stringWithFormat:@"%d", numberOfPeople + 1]];
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft || swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        if (numberOfPeople > 1) {
            [self.numberPeopleLabel setText:[NSString stringWithFormat:@"%d", numberOfPeople - 1]];
        }
    }
    [self updateTipCalculations:self.billTotalField.text withSplit:self.numberPeopleLabel.text];
}

#pragma mark - Helpers

- (void) recordLastTipPercentageSettings {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.billTotalField.text forKey:kLastBillTotal];
    
    [defaults setInteger:[self centerTipPercentageIndexPath].row forKey:kLastTipPercentage];
    
    [defaults setObject:self.numberPeopleLabel.text forKey:kLastBillSplitNumber];
    [defaults synchronize];
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

- (void) updateTipCalculations:(NSString *)newBillValue withSplit:(NSString *)numberOfPeople {
    NSArray * cellsToUpdate = [self.tipCalculatedCollectionView visibleCells];
    int people = [numberOfPeople intValue];
    for (UICollectionViewCell * cell in cellsToUpdate) {
        if ([cell isKindOfClass:[TipCalculatedCollectionViewCell class]]) {
            TipCalculatedCollectionViewCell * tipCell = (TipCalculatedCollectionViewCell *)cell;
            [tipCell updateCell:[newBillValue doubleValue] withSplit:people];
        }
    }
}

- (void) loadLatestData {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate * lastDate = (NSDate *)[defaults objectForKey:kLastCloseDate];
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:lastDate];
    
    NSInteger lastTipPercentage = [defaults integerForKey:kLastTipPercentage];
    NSString * lastBillTotal = [defaults objectForKey:kLastBillTotal];
    NSString * lastBillSplitNumber = [defaults stringForKey:kLastBillSplitNumber];
    
    // If less than 10 minutes have passed and something has been recorded, set bill total, number of people to split by, and tip percentage to what was last present
    if (timeDiff < 600 && lastTipPercentage && lastBillTotal && lastBillSplitNumber) {
        self.tipPercentageToScrollToIndexPath = [NSIndexPath indexPathForRow:lastTipPercentage inSection:0];
        [self.billTotalField setText:lastBillTotal];
        [self.numberPeopleLabel setText:lastBillSplitNumber];
    }
}

- (void) loadDefaultData {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastTipPercentage = [defaults integerForKey:kLastTipPercentage];
    NSString * lastBillTotal = [defaults objectForKey:kLastBillTotal];
    NSString * lastBillSplitNumber = [defaults stringForKey:kLastBillSplitNumber];
    
    if (!lastTipPercentage && !lastBillTotal && !lastBillSplitNumber) {
        // Load default percentage from settings
        NSNumber * tipPercentage = [defaults objectForKey:kTipPercentageDefault];
        // Default is 15 if it hasn't already been set
        if (!tipPercentage) {
            tipPercentage = @15;
        }
        self.tipPercentageToScrollToIndexPath = [NSIndexPath indexPathForRow:[tipPercentage integerValue] inSection:0];
        
        // Load default number of people to split bill by
        NSString * billSplitNumberDefault = [defaults stringForKey:kBillSplitNumberDefault];
        if (!billSplitNumberDefault) {
            billSplitNumberDefault = @"1";
        }
        [self.numberPeopleLabel setText:billSplitNumberDefault];
        [self updateTipCalculations:self.billTotalField.text withSplit:billSplitNumberDefault];
    }
}

- (void) clearLatestData {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    // Clear last recorded numbers
    [defaults removeObjectForKey:kLastBillTotal];
    [defaults removeObjectForKey:kLastTipPercentage];
    [defaults removeObjectForKey:kLastBillSplitNumber];
    [defaults synchronize];
}

@end
