//
//  PaymentViewController.m
//  CarClient
//
//  Created by Simon Maddox on 11/09/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import "PaymentViewController.h"


@implementation PaymentViewController

@synthesize timeSlots, picker, delegate, choose, droneTimeSlots;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.timeSlots = [NSArray arrayWithObjects:@"1 Minute - £2", @"5 Minutes - £4", @"10 minutes - £6", @"10 seconds - 40p", nil];
	self.droneTimeSlots = [NSArray arrayWithObjects:@"Full Battery - £20", @"Half Battery - £10", @"Quarter Battery - £6", nil];
	
	UIButton *button = [[PayPal getInstance] getPayButton:self buttonType:BUTTON_278x43 startCheckOut:@selector(payWithPayPal) PaymentType:SERVICE withLeft:20 withTop:80];	
	[self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.timeSlots = nil;
	self.picker = nil;
	
	self.choose = nil;
	self.droneTimeSlots = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction) playerChanged
{
	[self.picker reloadComponent:0];
}

-(void)payWithPayPal {
	//Once the user clicks the 'Pay with PayPal' button:
	
	//Keep a local variable so we can easily access the PayPal object
	PayPal *ppMEP = [PayPal getInstance];
	[ppMEP DisableShipping];
	
	//Calling 'enableDynamicAmountUpdate' allows us to modify the shipping fee after the user chooses a shipping address.
	//The method that gets called is 'AdjustAmounts', which we have below
	[ppMEP enableDynamicAmountUpdate];
	
	//If the payment has a fee and the user is allowed to decide who pays it, defaults the fee to be "recipient pays fee"
	[ppMEP feePaidByReceiver];
	
	//This lets us default the user's email address. If we already know the user's email, we can automatically enter it into the username
	//field on the login page. If the user has previously logged in a a username is saved, that will be displayed instead of whatever
	//is passed into this method.
	[ppMEP SetSenderEmailorPhone:@"sender@paypal.com"];
	
	//Defines our payment object
	PayPalMEPPayment *payment = [[PayPalMEPPayment alloc] init];
	
	//Sets the payment currency
	payment.paymentCurrency = @"GBP";
	
	//Sets the payment amount. We make sure it only has 2 decimal places
	
	NSNumber *price = [NSNumber numberWithInt:[picker selectedRowInComponent:0] + 1];
	
	if ([choose selectedSegmentIndex] == 0){
		if ([picker selectedRowInComponent:0] == 3){
			[price release];
			price = nil;
			
			price = [NSNumber numberWithFloat:0.2];
		}
	} else {
		[price release];
		price = nil;
		
		NSInteger newPrice = 0;
		
		switch ([picker selectedRowInComponent:0]) {
			case 0:
				newPrice = 10;
				break;
			case 1:
				newPrice = 5;
				break;
			case 2:
				newPrice = 3;
				break;
			default:
				break;
		}
		
		price = [NSNumber numberWithInt:newPrice];
	}
	
	payment.paymentAmount = [NSString stringWithFormat:@"%.2f", 2 * [price floatValue]];
	
	//Sets the item description that will be displayed to the user to the description we defined earlier
	payment.itemDesc = [self.timeSlots objectAtIndex:[picker selectedRowInComponent:0]];
	
	//Sets the recipient for the payment -- this would be the PayPal account we want the money sent to 
	payment.recipient = @"ota@simonmaddox.com";
	
	//Sets the tax amount. We can modify this after the user picks an address through the 'AdjustAmounts' method,
	//because we called the 'enableDynamicAmountUpdate' method
	payment.taxAmount = [NSString stringWithFormat:@"%.2f",0.00];
	
	//Sets the shipping amount. We can modify this after the user picks an address through the 'AdjustAmounts' method.
	payment.shippingAmount = [NSString stringWithFormat:@"%.2f",0.00];
	
	//Sets the merchant name that will be displayed to the user at the top of the PayPal Library window
	payment.merchantName = @"OTA Raceways";
	
	//Starts the checkout
	[ppMEP Checkout:payment];
	[payment release];
}



-(void)paymentSuccess:(NSString const *)transactionID
{
	NSInteger seconds = 0;
	
	switch ([picker selectedRowInComponent:0]) {
		case 0:
			seconds = 1 * 60;
			break;
		case 1:
			seconds = 5 * 60;
			break;
		case 2:
			seconds = 10 * 60;
			break;
		case 3:
			seconds = 10;
			break;
		default:
			break;
	}
	
	if ([choose selectedSegmentIndex] == 0){
		[delegate performSelector:@selector(beginCountingForMinutes:) withObject:[NSNumber numberWithInt:seconds]];
	} else {
		[delegate performSelector:@selector(loadDrone)];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)paymentCanceled
{

}
-(void)paymentFailed:(PAYPAL_FAILURE)errorType
{
	//If the payment failed, show the user an error message. We could use the 'errorType' value to let the user know more details about the error
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order failed" 
													message:@"Your order failed. Touch \"Pay with PayPal\" to try again." 
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if ([choose selectedSegmentIndex] == 0){
		return [self.timeSlots count];
	} else {
		return [self.droneTimeSlots count];
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if ([choose selectedSegmentIndex] == 0){
		return [self.timeSlots objectAtIndex:row];
	} else {
		return [self.droneTimeSlots objectAtIndex:row];
	}
}

@end
