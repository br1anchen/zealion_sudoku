//
//  SudokuAppDelegate.m
//  Sudoku
//
//  Created by Kwang on 11/05/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SudokuAppDelegate.h"
#import "SudokuViewController.h"
#import "MainMenuViewController.h"
#import "GameOptionInfo.h"
#import "SudokuEngine.h"
#import "MKStoreManager.h"


@implementation SudokuAppDelegate

@synthesize window;
//@synthesize viewController;
@synthesize navigationController;
@synthesize viewMainMenuController;
@synthesize m_nGameType, m_nLevel;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[MKStoreManager sharedManager];
	
	g_GameOptionInfo = [[GameOptionInfo alloc] init];
	g_pSudokuEngine = new CSudokuEngine();
//	[g_GameOptionInfo loadPicturePackInfo];
//	[g_GameOptionInfo savePicturePackInfo];
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
	navigationController.navigationBarHidden = YES;
    [self.window addSubview:[navigationController view]];
    [self.window makeKeyAndVisible];
	
	[self buyPackPictureState];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[g_GameOptionInfo saveData];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
//    [viewController release];
	delete g_pSudokuEngine;
	[g_GameOptionInfo release];
	[navigationController release];
	[viewMainMenuController release];
    [window release];
    [super dealloc];
}

-(void) buyPackPictureState {
	for (int i = 0; i < BUY_PICCOUNT; i ++) {
		BOOL bBuy = [MKStoreManager featurePurchased:i];
        //kgh-test
//        if (i < 1)
//            bBuy = YES;
		[g_GameOptionInfo setBuyPicState:i buy:bBuy];
	}
    [g_GameOptionInfo initEnablePackCount];
}

-(void) playSoundEffect:(int)kind {
	[self stopSoundEffect];
	NSString* str = [NSString stringWithFormat:@"click%d", kind];
	NSString *path = [[NSBundle mainBundle] pathForResource:str ofType:@"wav"];
	NSURL *url = [NSURL fileURLWithPath:path];
	NSError *error = nil;
	m_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error: (NSError**)&error];
	if (error != nil)
	{
		m_audioPlayer = nil;
		return;
	}
//	m_audioPlayer.delegate = self;
	[m_audioPlayer play];
	
}
-(void) stopSoundEffect {
	if (m_audioPlayer != nil) {
		[m_audioPlayer stop];
		[m_audioPlayer release];
		m_audioPlayer = nil;
	}	
}

@end
