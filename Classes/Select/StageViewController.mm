//
//  StageViewController.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StageViewController.h"
#import "SudokuAppDelegate.h"
#import "GameOptionInfo.h"
#import "MainMenuViewController.h"
#import "GameViewController.h"
#import "ImageManipulator.h"

#define kTagKeyIcon 

@implementation StageViewController

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
    [super viewDidLoad];
	
	UIImage* img = [[UIImage imageNamed:SHImageString(@"Choose_Pcp_back", @"png")] retain];
	UIImageView* bgView = [[UIImageView alloc] initWithImage:img];
	[self.view addSubview:bgView];
	[img release];
	[bgView release];
	
	//	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	// Add the Insert button
	UIBarButtonItem *menuButton= [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"Menu", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(menuAction:)] autorelease];
	
	self.navigationItem.rightBarButtonItem = menuButton;
	//	[self.navigationItem.leftBarButtonItem = self.editButtonItem;
	//	self.navigationController.navigationIte
}

- (void)viewWillAppear:(BOOL)animated {
	m_bHideNavBar = NO;
    if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE)
        self.title = @"Puzzudoku";
    else
        self.title = @"Picture Puzzle";
	g_GameOptionInfo.m_bGameState = FALSE;
	[super viewWillAppear:animated];
	for (int i = 0; i < MAX_STAGE; i ++) {
		UIView* btn = [self.view viewWithTag:i];
		if ([btn isKindOfClass:[UIButton class]]) {
			[btn removeFromSuperview];
			//[btn release];
		}
	}
	[self createStageButtons];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (m_bHideNavBar)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	//	[self.navigationController setNavigationBarHidden:YES animated:YES];
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
    [super dealloc];
}

-(void) createStageButtons {
	UIImage* imgBtn = [[UIImage imageNamed:SHImageString(@"Choose_pic_nor", @"png")] retain];;
	//NSString* strPack = [NSString stringWithFormat:@"Choose_pic%02d", g_GameOptionInfo.m_nSelectedPack+1];
	///UIImage* imgPack = [[UIImage imageNamed:SHImageString(strPack, @"png")] retain];;
	CGFloat x, y, w = imgBtn.size.width, h = imgBtn.size.height;
	CGFloat startX = 97, startY = 234, offsetX = 7, offsetY = 16;
	CGFloat fontsize = 48;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		startX = 42;
		startY = 100;
		offsetX = 4, offsetY = 12;
		fontsize = 22;
	}
	for (int i = 0; i < MAX_STAGE; i ++) {
		x = startX + (w+offsetX)*(i%5);
		y = startY + (h+offsetY)*(i/5);
		UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
		button.backgroundColor = [UIColor clearColor];
		[button setBackgroundImage:imgBtn forState:UIControlStateNormal];
		int btnState;
		if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE)
			btnState = [g_GameOptionInfo getPuzzlePackProblemState:g_GameOptionInfo.m_nSelectedPack stage:i];
		else
			btnState = [g_GameOptionInfo getPicturePackProblemState:g_GameOptionInfo.m_nSelectedPack stage:i];

		switch (btnState) {
			case PROBLEM_LOCK:
			{
				UIImage* imgKey = [[UIImage imageNamed:SHImageString(@"key", @"png")] retain];
				UIImageView* imgKeyView = [[UIImageView alloc] initWithImage:imgKey];
				imgKeyView.center = CGPointMake(w/2, h/2);
				[button addSubview:imgKeyView];
				[imgKey release];
				[imgKeyView release];
			}
				break;
			case PROBLEM_UNLOCK:
			{
				button.titleLabel.font = [UIFont systemFontOfSize:fontsize];
				[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
				[button setTitle:[NSString stringWithFormat:@"%d", i+1] forState:UIControlStateNormal];
			}
				break;
			case PROBLEM_SOLVED: 
			{
				UIImage* imgPack = [self getStageImage:i];
				[button setBackgroundImage:imgPack forState:UIControlStateNormal];
			}
				break;
			default:
				break;
		}
		button.tag = i;
		[button addTarget:self action:@selector(onStage:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];		
		[button release];
	}
	[imgBtn release];
//	[imgPack release];
//	[imgPackView release];
//	[imgKeyView release];
}
-(void) changeBtnImage {
	
}
-(UIButton*) createButton:(CGPoint)pos imageNormal:(NSString*)strNormal imagePress:(NSString*)strPress {
//	UIImage* imgNormal = [UIImage imageNamed:strNormal];
//	UIImage
//	UIButton* btn = [[
	return nil;
}
-(void) onStage:(id)sender {
	UIButton* btn = (UIButton*)sender;
	int tag = btn.tag;
	int nProblemState;
	if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE)
		nProblemState = [g_GameOptionInfo getPuzzlePackProblemState:g_GameOptionInfo.m_nSelectedPack stage:tag];
	else
		nProblemState = [g_GameOptionInfo getPicturePackProblemState:g_GameOptionInfo.m_nSelectedPack stage:tag];
	if (nProblemState == PROBLEM_LOCK)
		return;
	
	
	self.title = @"Back";
	g_GameOptionInfo.m_nSelectedStage = tag;
	[g_GameOptionInfo createProblem:g_GameOptionInfo.m_nGameType param:tag];
	GameViewController* controller = [[GameViewController alloc] init];
	//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
	//		controller = [[GameViewController alloc] initWithNibName:@"GameViewController_iPhone" bundle:nil];
	//	}
	//	else {
	//		return;
	//	}
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
	
}

-(void) menuAction:(id)sender {
	m_bHideNavBar = YES;
	SudokuAppDelegate* delegate = [UIApplication sharedApplication].delegate;
	[self.navigationController popToViewController:delegate.viewMainMenuController animated:TRUE];
}

-(UIImage*) getStageImage:(int)stage {
	UIImage* img;
	UIImage* imgPack;
	NSString* strPack;
	if (g_GameOptionInfo.m_nSelectedPack < PICTURE_COUNT) {
//        strPack = [NSString stringWithFormat:@"%@%02d.jpg", [g_GameOptionInfo getPackName:g_GameOptionInfo.m_nSelectedPack], stage+1];
        strPack = [g_GameOptionInfo getPackImageFilePath:g_GameOptionInfo.m_nSelectedPack stage:stage];
//		switch (g_GameOptionInfo.m_nSelectedPack) {
//			case PICTURE_CITY:
//				strPack = [NSString stringWithFormat:@"city%02d.png", stage+1];
//				break;
//			case PICTURE_NATURE:
//				strPack = [NSString stringWithFormat:@"Nature%02d.png", stage+1];
//				break;
//			case PICTURE_ART:
//				strPack = [NSString stringWithFormat:@"art%02d.png", stage+1];
//				break;
//			default:
//				break;
//		}
//		imgPack = [[UIImage imageNamed:strPack] retain];
        imgPack = [[UIImage alloc] initWithContentsOfFile:strPack];
		img = [ImageManipulator makeRoundCornerImage:imgPack :100 :100];
		[imgPack release];
	}
	else {
		strPack = [NSString stringWithFormat:@"Choose_pic%02d", g_GameOptionInfo.m_nSelectedPack+1];
		img = [[UIImage imageNamed:SHImageString(strPack, @"png")] retain];;
	}
	return [img autorelease];
}
@end
