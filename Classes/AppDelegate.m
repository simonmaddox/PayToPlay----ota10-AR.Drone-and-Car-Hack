//
//  AppDelegate.m
//  FreeFlight
//
//  Created by Mykonos on 16/10/09.
//  Copyright Parrot SA 2009. All rights reserved.
//
#import "AppDelegate.h"
#import "EAGLView.h"
#import "MenuUpdater.h"

#import "PayPal.h"
#import "PayPalContext.h"

@interface AppDelegate (private)
- (void) disableDetection;
@end

@implementation AppDelegate
@synthesize window;
@synthesize menuController;
@synthesize navigationController;

- (void) disableDetection
{
	ARDroneNavigationData data;
	[drone navigationData:&data];
	if(data.detection_type != ARDRONE_CAMERA_NONE)
	{
		ARDRONE_CAMERA_DETECTION_PARAM camParam;
		camParam.tag_size = 0;
		camParam.camera_type = ARDRONE_CAMERA_NONE;		
		NSLog(@"Disable detection\n");
		[drone executeCommandIn:ARDRONE_COMMAND_CAMERA_DETECTION withParameter:(void *)&camParam fromSender:nil];
	}
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{	
	NSLog(@"app did finish launching");
	application.idleTimerDisabled = YES;
	
	
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];
	
	//Initialize the PayPal Library in a separate thread so the Pizza application is not blocked
	[NSThread detachNewThreadSelector:@selector(initializePayPalMEP) toTarget:self withObject:nil];
}

- (void) loadDrone
{
	menuController = [[MenuController alloc] init];
	menuController.delegate = self;
	NSLog(@"menu controller view %@", menuController.view);
	
	// Setup the ARDrone 
	ARDroneHUDConfiguration hudconfiguration = {YES, NO};
	drone = [[ARDrone alloc] initWithFrame:menuController.view.frame withState:NO withDelegate:nil withHUDConfiguration:&hudconfiguration];
	[drone setScreenOrientationRight:YES];
	
	// Setup the OpenGL view
	glView = [[EAGLView alloc] initWithFrame:CGRectMake(menuController.view.frame.origin.x, menuController.view.frame.origin.y, menuController.view.frame.size.height, menuController.view.frame.size.width)];
	[glView changeState:NO];
	[glView setDrone:drone];
	
	was_in_game = NO;
	[navigationController setViewControllers:[NSArray array]];
	[navigationController.view removeFromSuperview];
	self.navigationController = nil;
	[menuController.view addSubview:glView];
	[menuController.view addSubview:drone.view];	
	
	[window addSubview:menuController.view];
    [window makeKeyAndVisible];
	
	CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
	menuController.view.transform = transform;
	
	// Repositions and resizes the view.
	CGRect contentRect = CGRectMake(-80, -80, 480, 320);
	menuController.view.bounds = contentRect;
}

-(void)initializePayPalMEP
{
	//Initialize the PayPal Library on the Sandbox server
	[PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_NONE];
}

- (void)changeState:(BOOL)inGame
{
	was_in_game = inGame;
	if(inGame)
		[drone setScreenOrientationRight:([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight)];
	
	[glView changeState:inGame];
	[drone changeState:inGame];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// Become inactive
	if(was_in_game)
	{
		[drone changeState:NO];
		[glView changeState:NO];
	}
	else
	{
		[menuController changeState:NO];
	}
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	if(was_in_game)
	{
		[drone changeState:YES];
		[glView changeState:YES];
	}
	else
	{
		[menuController changeState:YES];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{	
	if(was_in_game)
	{
		[drone changeState:NO];
		[glView changeState:NO];
	}
	else
	{
		[menuController changeState:NO];
	}
}

- (void)executeCommandIn:(ARDRONE_COMMAND_IN)commandId withParameter:(void*)parameter fromSender:(id)sender
{
	
}

- (BOOL)checkState
{
	BOOL result = NO;
	
	if(was_in_game)
	{
		result = [drone checkState];
	}
	else
	{
		//result = [menuController checkState];
	}
	
	return result;
}

@end
