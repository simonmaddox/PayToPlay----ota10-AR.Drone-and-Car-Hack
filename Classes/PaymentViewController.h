//
//  PaymentViewController.h
//  CarClient
//
//  Created by Simon Maddox on 11/09/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPal.h"
#import "AppDelegate.h"
#import "MEPAmounts.h"
#import "MEPAddress.h"
#import "PayPalMEPPayment.h"
#import "RootViewController.h"

@interface PaymentViewController : UIViewController <PayPalMEPDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	NSArray *timeSlots;
	NSArray *droneTimeSlots;
	UIPickerView *picker;
	id delegate;
	UISegmentedControl *choose;
}

@property (nonatomic, retain) NSArray *timeSlots;
@property (nonatomic, retain) NSArray *droneTimeSlots;

@property (nonatomic, retain) IBOutlet UIPickerView *picker;

@property (nonatomic, retain) IBOutlet UISegmentedControl *choose;

@property (nonatomic, assign) id delegate;

- (IBAction) playerChanged;

@end
