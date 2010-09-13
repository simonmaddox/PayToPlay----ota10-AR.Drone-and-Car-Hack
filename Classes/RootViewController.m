//
//  RootViewController.m
//  CarClient
//
//  Created by Simon Maddox on 08/09/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import "RootViewController.h"
#import "PaymentViewController.h"

#define theFilter 0.1
#define threshold 0.2

#define host1 @"192.168.1.10"
#define host2 @"192.168.1.11"

#define portConnect 23
#define intervalSend 30

// drone
#import "EAGLView.h"
#import "MenuUpdater.h"

@implementation RootViewController

@synthesize socket;

@synthesize host, port, interval;
@synthesize toggleControl;
@synthesize paywallTimer;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
		
	PaymentViewController *payment = [[PaymentViewController alloc] init];
	[payment setDelegate:self];
	[self.navigationController presentModalViewController:payment animated:NO];
	[payment release];
}

- (IBAction) playWithCar:(UIButton *) sender
{
	NSString *currentHost = nil;
	
	if ([sender tag] == 1){
		currentHost = host1;
	} else if ([sender tag] == 2){
		currentHost = host2;
	}
	
	
	if ([self createSocketForHost:currentHost] == NO){
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to connect to %@:%d", [self.host text], [[self.port text] intValue]] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
		[alert show];
		self.socket = nil;
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	//UIAccelerationValue rollingX = (acceleration.x * theFilter) + (rollingX * (1.0 - theFilter)); // not used
	
    UIAccelerationValue rollingY = (acceleration.y * theFilter) + (rollingY * (1.0 - theFilter));
	
    UIAccelerationValue rollingZ = (acceleration.z * theFilter) + (rollingZ * (1.0 - theFilter));
	
	//float accelX = acceleration.x - rollingX; // not used
	float accelY = acceleration.y - rollingY;
	float accelZ = acceleration.z - rollingZ;
	
	Direction currentDirection = None;
	
	if (accelZ > threshold){
		currentDirection = Backwards;
	} else if (accelZ < -threshold){
		currentDirection = Forward;
	}
	
	if (accelY > threshold){
		if (currentDirection != None){
			if (currentDirection == Forward){
				currentDirection = RightForward;
			} else {
				currentDirection = RightBackwards;
			}
		} else {
			currentDirection = Right;
		}
	} else if (accelY < -threshold){
		if (currentDirection != None){
			if (currentDirection == Forward){
				currentDirection = LeftForward;
			} else {
				currentDirection = LeftBackwards;
			}
		} else {
			currentDirection = Left;
		}
	}
	
	if (currentDirection != None){
		[self sendDirection:currentDirection];
	}
}

- (BOOL) createSocketForHost:(NSString *) theHost
{
	self.socket = [[LXSocket alloc] init];
	
	if ([self.socket connect:theHost port:portConnect] == NO) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to connect to %@:%d", [self.host text], [[self.port text] intValue]] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
		[alert show];
		self.socket = nil;
		return NO;
	}
		
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.03];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		
	return YES;
}

- (void) sendDirection:(Direction) direction
{
	NSLog(@"Sending: %d", direction);
	[self.socket sendString:[NSString stringWithFormat:@"%d\n", direction]];
}

- (void) closeSocket
{
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	self.socket = nil;
	self.paywallTimer = nil;
}

- (IBAction) toggleCarControl
{
	/*if (!controlling){
		if ([self createSocket]){
			controlling = YES;
			[self.toggleControl setTitle:@"Stop" forState:UIControlStateNormal];
			
		}
	} else {
		[self closeSocket];
		controlling = NO;
		[self.toggleControl setTitle:@"Start" forState:UIControlStateNormal];
	}*/
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	[self toggleCarControl];
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[self closeSocket];
	
	self.host = nil;
	self.port = nil;
	self.interval = nil;
	
	self.toggleControl = nil;
	self.paywallTimer = nil;

}

- (void) beginCountingForMinutes:(NSNumber *) seconds
{
	self.paywallTimer = [NSTimer scheduledTimerWithTimeInterval:([seconds intValue]) target:self selector:@selector(endGame) userInfo:nil repeats:NO];
}

- (void) loadDrone
{
	AppDelegate *delegate = [(AppDelegate *)[UIApplication sharedApplication] delegate];
	[delegate loadDrone];
}

- (void) endGame
{
	[self closeSocket];
	
	PaymentViewController *payment = [[PaymentViewController alloc] init];
	[payment setDelegate:self];
	[self.navigationController presentModalViewController:payment animated:YES];
	[payment release];
}

- (void)dealloc {
    [super dealloc];
}

@end

