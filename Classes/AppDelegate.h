//
//  AppDelegate.h
//  FreeFlight
//
//  Created by Mykonos on 16/10/09.
//  Copyright Parrot SA 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef ENABLE_TVOUT       
#import <MediaPlayer/MediaPlayer.h>
#endif
#import "ARDrone.h"
#import "MenuController.h"

@class EAGLView;

@interface AppDelegate : NSObject <UIApplicationDelegate, ARDroneProtocolIn> 
{
	UIWindow *window;
	BOOL was_in_game;
	
	MenuController *menuContoller;
	ARDrone *drone;
	EAGLView *glView;
	
	
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet MenuController *menuController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@end
