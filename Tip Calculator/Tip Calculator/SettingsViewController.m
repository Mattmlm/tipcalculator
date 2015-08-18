//
//  SettingsViewController.m
//  Tip Calculator
//
//  Created by admin on 8/13/15.
//  Copyright (c) 2015 mattmo. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet UILabel * percentageSymbolLabel;
@property (nonatomic, weak) IBOutlet UITextField * percentageField;
@property (nonatomic, weak) IBOutlet UITextField * numberOfPeopleField;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.percentageField.delegate = self;
    self.numberOfPeopleField.delegate = self;
    
    // If user taps outside of keyboard, text fields should be deselected
    UITapGestureRecognizer * deselectTextFieldTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deselectTextField:)];
    [self.view addGestureRecognizer:deselectTextFieldTapGesture];
    
    // If user taps percentage label, this should select the percentage field
    UITapGestureRecognizer * selectPercentageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPercentageField:)];
    [self.percentageSymbolLabel addGestureRecognizer:selectPercentageTapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(kMainColorGreen)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self loadDefaultValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate protocol methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([textField isEqual:self.percentageField]) {
        NSInteger newDefaultPercentage = [self.percentageField.text integerValue];
        
        // Tip percentage should be within 0 and 100
        if (newDefaultPercentage > 100) {
            newDefaultPercentage = 100;
        } else if (newDefaultPercentage < 0) {
            newDefaultPercentage = 0;
        }
        [defaults setInteger:newDefaultPercentage forKey:kTipPercentageDefault];
    } else if ([textField isEqual:self.numberOfPeopleField]) {
        NSString * newDefaultBillSplitNumberText = self.numberOfPeopleField.text;
        NSInteger newDefaultBillSplitNumber = [newDefaultBillSplitNumberText integerValue];
        
        // Number of people to split the bill by should never be less than 1
        if (newDefaultBillSplitNumber < 1) {
            newDefaultBillSplitNumberText = @"1";
        }
        [defaults setObject:newDefaultBillSplitNumberText forKey:kBillSplitNumberDefault];
    }
}

#pragma mark - Gesture Handlers

- (void)selectPercentageField:(UITapGestureRecognizer *) tap {
    NSLog(@"selectPercentageField");
    [self.percentageField becomeFirstResponder];
}
- (void)deselectTextField:(UITapGestureRecognizer *)tap {
    NSLog(@"deselectTextField");
    [self.percentageField resignFirstResponder];
    [self.numberOfPeopleField resignFirstResponder];
}

#pragma mark - Helpers

- (void)loadDefaultValues {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSInteger defaultPercentage = [defaults integerForKey:kTipPercentageDefault];
    NSString * billSplitNumberDefault = [defaults stringForKey:kBillSplitNumberDefault];
    if (!billSplitNumberDefault) {
        billSplitNumberDefault = @"1";
    }
    [self.percentageField setText:[NSString stringWithFormat:@"%ld", (long)defaultPercentage]];
    [self.numberOfPeopleField setText:billSplitNumberDefault];
}

@end
