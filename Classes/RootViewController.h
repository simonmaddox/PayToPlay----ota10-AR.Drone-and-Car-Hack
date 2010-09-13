//
//  RootViewController.h
//  CarClient
//
//  Created by Simon Maddox on 08/09/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXSocket.h"

enum {
	None,
	Forward,
	Backwards,
	RightForward,
	LeftForward,
	RightBackwards,
	LeftBackwards,
	Right,
	Left
} typedef Direction;

@interface RootViewController : UIViewController <UIAccelerometerDelegate, UITextFieldDelegate> {
	LXSocket *socket;
	
	UITextField *host;
	UITextField *port;
	UITextField *interval;
	
	UIButton *toggleControl;

	NSTimer *paywallTimer;
	
}

@property (nonatomic, retain) LXSocket *socket;

@property (nonatomic, retain) IBOutlet UITextField *host;
@property (nonatomic, retain) IBOutlet UITextField *port;
@property (nonatomic, retain) IBOutlet UITextField *interval;

@property (nonatomic, retain) IBOutlet UIButton *toggleControl;
@property (nonatomic, retain) NSTimer *paywallTimer;

- (IBAction) toggleCarControl;

- (BOOL) createSocketForHost:(NSString *) theHost;
- (void) closeSocket;

- (void) sendDirection:(Direction) direction;

- (void) beginCountingForMinutes:(NSNumber *) seconds;

- (IBAction) playWithCar:(UIButton *) sender;
- (void) loadDrone;

@end