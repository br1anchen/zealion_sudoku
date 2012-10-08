//
//  MainMenuViewController.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SudokuAppDelegate.h"
#import "OptionViewController.h"
#import "ClassicViewController.h"
#import "PictureViewController.h"
#import "StageViewController.h"
#import "GameOptionInfo.h"
#import "GameViewController.h"
#import "HelpViewController.h"


@implementation MainMenuViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//	[self.navigationController setNavigationBarHidden:YES animated:NO];
	SudokuAppDelegate* delegate = [UIApplication sharedApplication].delegate;
	delegate.navigationController.navigationBarHidden = YES;
    [super viewDidLoad];
}

// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated {
	g_GameOptionInfo.m_bGameState = FALSE;
	[super viewWillAppear:animated];
	self.title = @"Menu";
    if ([self isMustDownload])
        [self startDownloadPack];
//	SudokuAppDelegate* delegate = [UIApplication sharedApplication].delegate;
//	delegate.navigationController.navigationBarHidden = YES;	
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	m_btnResume.enabled = g_GameOptionInfo.m_bEnableResume;
//	SudokuAppDelegate* delegate = [UIApplication sharedApplication].delegate;
//	delegate.navigationController.navigationBarHidden = YES;	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [m_btnResume release];
    [m_alertMain release];
    [m_activityIndicator release];
    [super dealloc];
}

-(IBAction) onPlay:(id)sender {
	[self setTitle:@"Back"];
	PictureViewController* controller;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		controller = [[PictureViewController alloc] initWithNibName:@"PictureViewController_iPhone" bundle:nil];
	}
	else {
		controller = [[PictureViewController alloc] initWithNibName:@"PictureViewController_iPad" bundle:nil];
	}
	
	g_GameOptionInfo.m_nGameType = GAME_PUZZLE;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}
-(IBAction) onResumeGame:(id)sender {
	[self setTitle:@"Back"];
	g_GameOptionInfo.m_bResumeGame = TRUE;
	[g_GameOptionInfo loadGameResume];
	int nParam;
	if (g_GameOptionInfo.m_nGameType == GAME_CLASSIC)
		nParam = g_GameOptionInfo.m_nLevel;
	else
		nParam = g_GameOptionInfo.m_nSelectedPack;
	[g_GameOptionInfo createProblem:g_GameOptionInfo.m_nGameType param:nParam];
	GameViewController* controller = [[GameViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];	
}
-(IBAction) onClassicSudoku:(id)sender {
	[self setTitle:@"Back"];
	ClassicViewController* controller;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		controller = [[ClassicViewController alloc] initWithNibName:@"ClassicViewController_iPhone" bundle:nil];
	}
	else {
		controller = [[ClassicViewController alloc] initWithNibName:@"ClassicViewController_iPad" bundle:nil];
	}
	
	g_GameOptionInfo.m_nGameType = GAME_CLASSIC;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}
-(IBAction) onPictureSudoku:(id)sender {
	[self setTitle:@"Back"];
	PictureViewController* controller;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		controller = [[PictureViewController alloc] initWithNibName:@"PictureViewController_iPhone" bundle:nil];
	}
	else {
		controller = [[PictureViewController alloc] initWithNibName:@"PictureViewController_iPad" bundle:nil];
	}
	
	g_GameOptionInfo.m_nGameType = GAME_PICTURE;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}
-(IBAction) onOption:(id)sender {
	OptionViewController* controller;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		controller = [[OptionViewController alloc] initWithNibName:@"OptionViewController_iPhone" bundle:nil];
	}
	else {
		controller = [[OptionViewController alloc] initWithNibName:@"OptionViewController_iPad" bundle:nil];
	}

	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}
-(IBAction) onHelp:(id)sender {
	HelpViewController* controller;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		controller = [[HelpViewController alloc] initWithNibName:@"HelpViewController_iPhone" bundle:nil];
	}
	else {
		controller = [[HelpViewController alloc] initWithNibName:@"HelpViewController_iPad" bundle:nil];
	}
    
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}
-(BOOL) isMustDownload {
    BOOL bRet = NO;
    for (int i = 0; i < BUY_PICCOUNT; i ++) {
        if ([g_GameOptionInfo getBuyPicState:i] == NO)
            continue;
        if ([g_GameOptionInfo getDownloadPackState:i] == NO) {
            bRet = YES;
            break;
        }
    }
    return bRet;
}
#define SERVER_URL  @"http://youarebacon.com/filebase"
-(void) downloadPack {
    //NSString* strFileName;
    //NSString* strUrl;
    //NSString* strPath;
    int pack;
//    UIImage* image;
    BOOL bSuccess = NO;
    for (int i = 0; i < BUY_PICCOUNT; i ++) {
        if ([g_GameOptionInfo getBuyPicState:i] == NO)
            continue;
        if ([g_GameOptionInfo getDownloadPackState:i] == NO) {
            bSuccess = YES;
            pack = DEFAULT_PICCOUNT+i;
//            for (int j = 0; j < MAX_STAGE; j ++) {
//                strFileName = [NSString stringWithFormat:@"%@%02d.jpg", [g_GameOptionInfo getPackName:pack], j+1];
//                strUrl = [NSString stringWithFormat:@"%@/%@/%@", SERVER_URL, [g_GameOptionInfo getDirPackName:pack], strFileName];
//                NSLog(@"%@", strUrl);
//                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
//                strPath = [g_GameOptionInfo getFilePathWithFileName:strFileName];
//                [g_GameOptionInfo deleteFile:strPath];
//                BOOL bRet = [data writeToFile:strPath atomically:YES];
//                if (bRet == NO) {
//                    bSuccess = NO;
//                    break;
//                }
////                image = [UIImage imageWithData:data];
////                [image 
//            }
            if (bSuccess)
                [g_GameOptionInfo setDownloadPackState:i download:YES];
        }
    }
    [self endDownloadPack];
}

- (void) startDownloadPack {
    self.view.userInteractionEnabled = NO;
    if (m_alertMain==nil) {
        m_alertMain = [[UIAlertView alloc] initWithTitle:@"Downloading Package\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    }
	[m_alertMain show];
	
    if (m_activityIndicator==nil) {
        m_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            m_activityIndicator.center = CGPointMake(150, 85);
        else
            m_activityIndicator.center = CGPointMake(380, 240);
        [m_alertMain addSubview:m_activityIndicator];
    }
	
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	[m_activityIndicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(downloadPack) userInfo:nil repeats:NO];
    
}
- (void) endDownloadPack {
    self.view.userInteractionEnabled = YES;
	[m_activityIndicator stopAnimating];
	[m_alertMain dismissWithClickedButtonIndex:0 animated:YES];
    //    [m_alertMain release];
    //    m_alertMain = nil;
    [g_GameOptionInfo initEnablePackCount];
}

@end
