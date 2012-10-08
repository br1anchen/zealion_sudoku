//
//  SudokuAppDelegate.h
//  Sudoku
//
//  Created by Kwang on 11/05/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@class SudokuViewController;
@class MainMenuViewController;


#define APPDELEGATE		((SudokuAppDelegate*)([UIApplication sharedApplication].delegate))

#define MAX_STAGE	25

@interface SudokuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
//    SudokuViewController *viewController;
	UINavigationController* navigationController;
	MainMenuViewController* viewMainMenuController;
	
	AVAudioPlayer*				m_audioPlayer;
	
	int		m_nGameType;
	int		m_nLevel;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet SudokuViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet MainMenuViewController *viewMainMenuController;
@property (nonatomic) int m_nGameType;
@property (nonatomic) int m_nLevel;

-(void) playSoundEffect:(int)kind;
-(void) stopSoundEffect;
-(void) buyPackPictureState;

@end

