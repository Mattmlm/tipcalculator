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

@property BOOL isDefaultLoaded;

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
    
    UISwipeGestureRecognizer * swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNumberPeople:)];
    UISwipeGestureRecognizer * swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNumberPeople:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [self.numberPeopleView addGestureRecognizer:swipeUp];
    [self.numberPeopleView addGestureRecognizer:swipeDown];
    
    // Make keyboard show
    [self.billTotalField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.billTotalField becomeFirstResponder];
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
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        [self.numberPeopleLabel setText:[NSString stringWithFormat:@"%d", numberOfPeople + 1]];
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
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

- (void) loadDefaultTip {
    if (!self.isDefaultLoaded) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        NSDate * lastDate = (NSDate *)[defaults objectForKey:kLastCloseDate];
        NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:lastDate];
        
        // Set up default tip percentage
        NSIndexPath * tipPercentageToScrollToIndexPath = nil;
        
        if (timeDiff > 600) {
            // If more than 10 minutes have passed, use 15% or whatever value is in settings
            NSInteger tipPercentage = [defaults integerForKey:kTipDefaultPercentage];
            if (tipPercentage == 0) {
                tipPercentage = 15;
            }
            tipPercentageToScrollToIndexPath = [NSIndexPath indexPathForRow:tipPercentage inSection:0];
        } else {
            // If less than 10 minutes have passed, set bill total, number of people to split by, and tip percentage to what was last present
            tipPercentageToScrollToIndexPath = [NSIndexPath indexPathForRow:[defaults integerForKey:kLastTipPercentage] inSection:0];
            [self.billTotalField setText:[defaults objectForKey:kLastBillTotal]];
            [self.numberPeopleLabel setText:[defaults stringForKey:kLastBillSplitNumber]];
        }
        [self.tipCalculatedCollectionView scrollToItemAtIndexPath:tipPercentageToScrollToIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        self.isDefaultLoaded = YES;
    }
}

@end
