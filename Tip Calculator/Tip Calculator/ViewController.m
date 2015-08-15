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

#pragma mark - Helpers

- (void) updateTipCalculations:(NSString *)newBillValue {
    NSArray * cellsToUpdate = [self.tipCalculatedCollectionView visibleCells];
    for (UICollectionViewCell * cell in cellsToUpdate) {
        if ([cell isKindOfClass:[TipCalculatedCollectionViewCell class]]) {
            TipCalculatedCollectionViewCell * tipCell = (TipCalculatedCollectionViewCell *)cell;
            [tipCell updateCell:[newBillValue doubleValue]];
        }
    }
}

@end
